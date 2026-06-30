import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/app_db.dart';
import '../../core/providers.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/format_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/org_header_card.dart';
import '../../widgets/sync_status_chip.dart';

class MemberDashboardScreen extends ConsumerWidget {
  final String memberUuid;
  const MemberDashboardScreen({super.key, required this.memberUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(_memberDashboardProvider(memberUuid));
    final recentDepositsAsync = ref.watch(_cooperativeRecentDepositsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: SyncStatusChip(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_memberDashboardProvider(memberUuid));
          ref.invalidate(_cooperativeRecentDepositsProvider);
        },
        child: statsAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (err, st) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 200,
                  child: Center(child: Text(l10n.errorLoadingData)),
                ),
              ],
            );
          },
          data: (data) {
            final member = data.member;
            final showCoopCollection = data.settings.memberShowCoopTotalCollection;
            final showCoopDue = data.settings.memberShowCoopTotalDue;
            final showCoopCurrentMonth = data.settings.memberShowCoopCurrentMonth;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (data.org != null)
                  OrgHeaderCard(
                    name: data.org!.name,
                    address: data.org!.address,
                    logoPath: data.org!.logoPath,
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(l10n.failedToLoadOrganization),
                    ),
                  ),
                if (member != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(member.name),
                      subtitle: Text(member.memberIdNumber),
                      trailing: Text(
                        formatCurrencyCompact(member.monthlyAmount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
                if (showCoopCurrentMonth) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentMonth(
                                monthKeyToName(data.currentMonthKey)),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _MetricCard(
                                  title: l10n.collection,
                                  value: formatCurrencyCompact(
                                      data.coopCurrentMonthCollection),
                                  icon: Icons.payments_outlined,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricCard(
                                  title: l10n.due,
                                  value: formatCurrencyCompact(
                                      data.coopCurrentMonthDue),
                                  icon: Icons.warning_amber,
                                  color: data.coopCurrentMonthDue > 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (showCoopCollection || showCoopDue) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.cooperativeSummary,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (showCoopCollection)
                        Expanded(
                          child: _MetricCard(
                            title: l10n.totalCollection,
                            value: formatCurrencyCompact(data.coopTotalCollection),
                            icon: Icons.savings_outlined,
                            color: Colors.teal,
                          ),
                        ),
                      if (showCoopCollection && showCoopDue)
                        const SizedBox(width: 12),
                      if (showCoopDue)
                        Expanded(
                          child: _MetricCard(
                            title: l10n.totalDue,
                            value: formatCurrencyCompact(data.coopTotalDue),
                            icon: Icons.payments_outlined,
                            color: data.coopTotalDue > 0
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: l10n.myTotalPaid,
                        value: formatCurrencyCompact(data.totalPaid),
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: l10n.myDue,
                        value: formatCurrencyCompact(data.totalDue),
                        icon: Icons.warning_amber,
                        color: data.totalDue > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.recentCooperativeDeposits,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                recentDepositsAsync.when(
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (err, st) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(l10n.errorLoadingData),
                      ),
                    );
                  },
                  data: (recentDeposits) {
                    if (recentDeposits.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(l10n.noDeposits),
                        ),
                      );
                    }

                    return Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3, child: Text(l10n.date)),
                                Expanded(
                                    flex: 5, child: Text(l10n.members)),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    l10n.amount,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          ...recentDeposits.map(
                            (d) => _CooperativeDepositRow(deposit: d),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 70),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MemberDashboardData {
  final Member? member;
  final OrganizationData? org;
  final SettingsData settings;
  final int totalPaid;
  final int totalDue;
  final int coopTotalCollection;
  final int coopTotalDue;
  final String currentMonthKey;
  final int coopCurrentMonthCollection;
  final int coopCurrentMonthDue;

  _MemberDashboardData({
    required this.member,
    required this.org,
    required this.settings,
    required this.totalPaid,
    required this.totalDue,
    required this.coopTotalCollection,
    required this.coopTotalDue,
    required this.currentMonthKey,
    required this.coopCurrentMonthCollection,
    required this.coopCurrentMonthDue,
  });
}

final _cooperativeRecentDepositsProvider = StreamProvider<List<Deposit>>((ref) {
  return coopScopedStream(
    ref,
    () => ref.watch(repoProvider).watchLastDeposits(limit: 5),
  );
});

final _memberDashboardProvider =
    FutureProvider.family<_MemberDashboardData, String>((ref, memberUuid) async {
  final repo = ref.read(repoProvider);
  final now = DateTime.now();
  final curMonthKey = monthKey(now);
  final dueStart = duePeriodStart();

  final member = await repo.getMemberByUuid(memberUuid);
  final org = await repo.watchOrganization().first;
  final settings = await repo.getSettings();
  final deposits = await repo.watchMemberDeposits(memberUuid).first;
  final due = await repo.dueForOneMember(
    memberUuid: memberUuid,
    start: dueStart,
    endInclusive: now,
  );

  var totalPaid = 0;
  for (final d in deposits.where((d) => d.deletedAt == null)) {
    totalPaid += d.amount;
  }

  final coopTotalCollection = await repo.totalCollectionAllTime();
  final coopCurrentMonthCollection =
      await repo.collectionForMonth(curMonthKey);
  final dueSummary = await repo.dueSummaryAllMembers(
    start: dueStart,
    endInclusive: now,
  );
  final currentMonthDueSummary = await repo.dueSummaryAllMembers(
    start: DateTime(now.year, now.month, 1),
    endInclusive: now,
  );

  return _MemberDashboardData(
    member: member,
    org: org,
    settings: settings,
    totalPaid: totalPaid,
    totalDue: due['totalDue'] as int? ?? 0,
    coopTotalCollection: coopTotalCollection,
    coopTotalDue: dueSummary['totalDue'] as int? ?? 0,
    currentMonthKey: curMonthKey,
    coopCurrentMonthCollection: coopCurrentMonthCollection,
    coopCurrentMonthDue: currentMonthDueSummary['totalDue'] as int? ?? 0,
  );
});

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _CooperativeDepositRow extends ConsumerWidget {
  final Deposit deposit;
  const _CooperativeDepositRow({required this.deposit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = DateFormat('yyyy-MM-dd');
    return FutureBuilder<Member?>(
      future: ref.read(repoProvider).getMemberByUuid(deposit.memberUuid),
      builder: (context, snap) {
        final memberName = snap.data?.name ?? 'Unknown';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(df.format(deposit.date))),
              Expanded(
                flex: 5,
                child: Text(memberName, overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  formatCurrencyCompact(deposit.amount),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
