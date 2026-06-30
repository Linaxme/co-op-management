import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase/sync_service.dart';
import '../core/providers.dart';
import '../l10n/app_localizations.dart';

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncServiceProvider).syncStatus;
});

class SyncStatusChip extends ConsumerWidget {
  final VoidCallback? onTap;

  const SyncStatusChip({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);
    final l10n = AppLocalizations.of(context)!;
    final status = statusAsync.value ?? SyncStatus.offline;

    final (label, icon, color) = switch (status) {
      SyncStatus.synced => (l10n.syncStatusSynced, Icons.cloud_done, Colors.green),
      SyncStatus.syncing => (l10n.syncStatusSyncing, Icons.cloud_sync, Colors.blue),
      SyncStatus.connecting => (l10n.syncStatusConnecting, Icons.cloud_queue, Colors.orange),
      SyncStatus.error => (l10n.syncStatusError, Icons.cloud_off, Colors.red),
      SyncStatus.offline => (l10n.syncStatusOffline, Icons.cloud_off, Colors.grey),
    };

    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap ??
          () {
            ref.read(syncServiceProvider).forceSync();
          },
    );
  }
}
