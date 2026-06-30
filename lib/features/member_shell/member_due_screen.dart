import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_db.dart';
import '../../core/providers.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/format_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';

class MemberDueScreen extends ConsumerWidget {
  final String memberUuid;
  const MemberDueScreen({super.key, required this.memberUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final pageAsync = ref.watch(_memberDuePageProvider(memberUuid));

    return pageAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.dueReport)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(l10n.dueReport)),
        body: Center(child: Text(l10n.errorLoadingData)),
      ),
      data: (data) {
        final showAllDueTab = data.settings.memberShowDueMembersList;
        final tabCount = showAllDueTab ? 2 : 1;

        return DefaultTabController(
          length: tabCount,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.dueReport),
              bottom: TabBar(
                tabs: [
                  Tab(text: l10n.myDue),
                  if (showAllDueTab)
                    Tab(text: isBn ? 'সমিতির বকেয়া' : 'All Members Due'),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(_memberDuePageProvider(memberUuid));
                await ref.read(_memberDuePageProvider(memberUuid).future);
              },
              child: TabBarView(
                children: [
                  _MyDueTab(myDue: data.myDue, l10n: l10n),
                  if (showAllDueTab)
                    _AllMembersDueTab(
                      coopTotalDue: data.coopTotalDue,
                      membersWithDue: data.membersWithDue,
                      l10n: l10n,
                      isBn: isBn,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MemberDuePageData {
  final SettingsData settings;
  final Map<String, dynamic> myDue;
  final int coopTotalDue;
  final List<Map<String, dynamic>> membersWithDue;

  _MemberDuePageData({
    required this.settings,
    required this.myDue,
    required this.coopTotalDue,
    required this.membersWithDue,
  });
}

final _memberDuePageProvider =
    FutureProvider.family<_MemberDuePageData, String>((ref, memberUuid) async {
  final repo = ref.read(repoProvider);
  final now = DateTime.now();
  final dueStart = duePeriodStart();
  final settings = await repo.getSettings();
  final myDue = await repo.dueForOneMember(
    memberUuid: memberUuid,
    start: dueStart,
    endInclusive: now,
  );
  final dueSummary = await repo.dueSummaryAllMembers(
    start: dueStart,
    endInclusive: now,
  );
  final allMemberDues =
      (dueSummary['members'] as List).cast<Map<String, dynamic>>();
  final membersWithDue = allMemberDues
      .where((entry) => (entry['totalDue'] as int) > 0)
      .toList();

  return _MemberDuePageData(
    settings: settings,
    myDue: myDue,
    coopTotalDue: dueSummary['totalDue'] as int? ?? 0,
    membersWithDue: membersWithDue,
  );
});

class _MyDueTab extends StatelessWidget {
  final Map<String, dynamic> myDue;
  final AppLocalizations l10n;

  const _MyDueTab({required this.myDue, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final totalDue = myDue['totalDue'] as int? ?? 0;
    final dueMonths = (myDue['dueMonths'] as Map<String, int>?) ?? {};
    final member = myDue['member'];

    if (dueMonths.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: EmptyState(
              icon: Icons.check_circle_outline,
              title: l10n.noDueAmount,
              message: l10n.allMembersUpToDate,
            ),
          ),
        ],
      );
    }

    final keys = dueMonths.keys.toList()..sort();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.warning_amber,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (member != null)
                        Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      Text(
                        '${l10n.totalDue}: ${formatCurrencyCompact(totalDue)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.due, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: keys.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final mk = keys[i];
              final amount = dueMonths[mk]!;
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                title: Text(monthKeyToName(mk)),
                subtitle: Text(mk),
                trailing: Text(
                  formatCurrencyCompact(amount),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 70),
      ],
    );
  }
}

class _AllMembersDueTab extends StatelessWidget {
  final int coopTotalDue;
  final List<Map<String, dynamic>> membersWithDue;
  final AppLocalizations l10n;
  final bool isBn;

  const _AllMembersDueTab({
    required this.coopTotalDue,
    required this.membersWithDue,
    required this.l10n,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.groups_outlined,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${l10n.totalDue}: ${formatCurrencyCompact(coopTotalDue)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isBn ? 'বকেয়া সদস্যদের তালিকা' : 'Members with Due',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (membersWithDue.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(l10n.allMembersUpToDate),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(flex: 5, child: Text(l10n.members)),
                      Expanded(
                        flex: 3,
                        child: Text(
                          l10n.totalDue,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...membersWithDue.map((entry) {
                  final m = entry['member'] as Member;
                  final due = entry['totalDue'] as int;
                  return ListTile(
                    dense: true,
                    title: Text(m.name),
                    subtitle: Text(m.memberIdNumber),
                    trailing: Text(
                      formatCurrencyCompact(due),
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 70),
      ],
    );
  }
}
