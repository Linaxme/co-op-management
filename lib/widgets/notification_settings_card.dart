import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../core/notifications/notification_providers.dart';

class NotificationSettingsCard extends ConsumerWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.watch(notificationPrefsProvider);

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.notifications),
            subtitle: Text(l10n.notificationsSubtitle),
            value: prefs.enabled,
            onChanged: (v) =>
                ref.read(notificationPrefsProvider.notifier).setEnabled(v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(l10n.dueReminders),
            subtitle: Text(l10n.dueRemindersSubtitle),
            value: prefs.dueReminders,
            onChanged: prefs.enabled
                ? (v) => ref
                    .read(notificationPrefsProvider.notifier)
                    .setDueReminders(v)
                : null,
          ),
        ],
      ),
    );
  }
}
