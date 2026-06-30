import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/admin_route_guard.dart';
import '../../core/providers.dart';
import '../../widgets/confirmation_dialog.dart';
import 'package:intl/intl.dart';
import '../../core/utils/format_utils.dart';
import '../../l10n/app_localizations.dart';

final trashedMembersProvider = StreamProvider((ref) => ref.watch(repoProvider).watchTrashedMembers());
final trashedDepositsProvider = StreamProvider((ref) => ref.watch(repoProvider).watchTrashedDeposits());

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen>
    with AdminRouteGuard {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.trash),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(AppLocalizations.of(context)!.members), icon: const Icon(Icons.people_alt_outlined)),
                ButtonSegment(value: 1, label: Text(AppLocalizations.of(context)!.deposits), icon: const Icon(Icons.receipt_long)),
              ],
              selected: {tab},
              onSelectionChanged: (s) => setState(() => tab = s.first),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: tab == 0 ? const _MembersTrash() : const _DepositsTrash(),
          ),
        ],
      ),
    );
  }
}

class _MembersTrash extends ConsumerWidget {
  const _MembersTrash();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trashedMembersProvider);
    return async.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noDeletedMembers));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final m = items[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('ID: ${m.memberIdNumber}  |  Monthly: ${formatCurrencyCompact(m.monthlyAmount)}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.restore,
                      icon: const Icon(Icons.restore),
                      onPressed: () => ref.read(repoProvider).restoreMember(m.uuid),
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.permanentDelete,
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () async {
                        final ok = await showConfirmationDialog(
                          context: context,
                          title: AppLocalizations.of(context)!.permanentDelete,
                          message: AppLocalizations.of(context)!.deleteMemberConfirm('member'),
                          confirmText: AppLocalizations.of(context)!.permanentDelete,
                        );
                        if (!ok) return;
                        await ref.read(repoProvider).permanentlyDeleteMember(m.uuid);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${AppLocalizations.of(context)!.error}: ')),
    );
  }
}

class _DepositsTrash extends ConsumerWidget {
  const _DepositsTrash();

  String _formatReceiptNumber(int receiptSerial, [String prefix = 'RCPT']) {
    final serialStr = receiptSerial.toString();
    if (serialStr.length >= 14) {
      // Date/time based serial: Format as YYYY-MM-DD-HHMMSS
      final year = serialStr.substring(0, 4);
      final month = serialStr.substring(4, 6);
      final day = serialStr.substring(6, 8);
      final time = serialStr.substring(8, 14);
      return '$prefix-$year$month$day-$time';
    } else {
      // Fallback for old format (backward compatibility)
      return '$prefix-${receiptSerial.toString().padLeft(4, '0')}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trashedDepositsProvider);
    final df = DateFormat('yyyy-MM-dd');
    return async.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noDeletedDeposits));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final d = items[i];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                title: Text(formatCurrencyCompact(d.amount)),
                subtitle: Text('Member: ${d.memberUuid}\nMonth: ${df.format(d.date)}  •  ${_formatReceiptNumber(d.receiptSerial, 'RCPT')}'),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.restore,
                      icon: const Icon(Icons.restore),
                      onPressed: () => ref.read(repoProvider).restoreDeposit(d.uuid),
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.permanentDelete,
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () async {
                        final ok = await showConfirmationDialog(
                          context: context,
                          title: AppLocalizations.of(context)!.permanentDelete,
                          message: AppLocalizations.of(context)!.deleteMemberConfirm('deposit'),
                          confirmText: AppLocalizations.of(context)!.permanentDelete,
                        );
                        if (!ok) return;
                        await ref.read(repoProvider).permanentlyDeleteDeposit(d.uuid);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${AppLocalizations.of(context)!.error}: ')),
    );
  }
}

