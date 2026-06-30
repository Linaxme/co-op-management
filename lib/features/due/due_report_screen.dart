import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/utils/format_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/empty_state.dart';
import '../../l10n/app_localizations.dart';

class DueReportScreen extends ConsumerWidget {
  const DueReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dueReport),
        actions: [
          IconButton(
            onPressed: () => context.push('/trash'),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: AppLocalizations.of(context)!.trash,
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(repoProvider).dueSummaryAllMembers(
              start: DateTime(2025, 1, 1),
              endInclusive: now,
            ),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final totalDue = snap.data!['totalDue'] as int;
          final members =
              (snap.data!['members'] as List).cast<Map<String, dynamic>>();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${AppLocalizations.of(context)!.totalDue}: ${formatCurrencyCompact(totalDue)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (members.isEmpty)
                EmptyState(
                  icon: Icons.check_circle_outline,
                  title: AppLocalizations.of(context)!.noDueMembers,
                  message: AppLocalizations.of(context)!.allMembersUpToDate,
                ),
              if (members.isNotEmpty)
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final m = members[i];
                      final member = m['member'];
                      final total = m['totalDue'] as int;
                      final dueMonths = (m['dueMonths'] as Map<String, int>);
                      final keys = dueMonths.keys.toList()..sort();
                      return ListTile(
                        title:
                            Text('${member.name} (${member.memberIdNumber})'),
                        subtitle: keys.isEmpty
                            ? Text(AppLocalizations.of(context)!.noDue,
                                style: const TextStyle(color: Colors.green))
                            : Text(
                                'Months: ${keys.length} (${keys.take(3).map((k) => monthKeyToName(k)).join(', ')}${keys.length > 3 ? '...' : ''})'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatCurrencyCompact(total),
                              style: TextStyle(
                                color: total > 0
                                    ? Colors.red.shade700
                                    : Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          // Navigate to member detail screen to see full due list
                          context.push('/member/${member.uuid}');
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 70),
            ],
          );
        },
      ),
    );
  }
}
