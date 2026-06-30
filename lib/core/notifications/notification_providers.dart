import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_prefs.dart';
import 'notification_service.dart';

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>((ref) {
  return NotificationPrefsNotifier();
});

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  NotificationPrefsNotifier() : super(const NotificationPrefs()) {
    _load();
  }

  final _service = NotificationService.instance;

  Future<void> _load() async {
    state = await _service.loadPrefs();
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await _service.savePrefs(state);
  }

  Future<void> setDueReminders(bool value) async {
    state = state.copyWith(dueReminders: value);
    await _service.savePrefs(state);
    if (value && state.enabled) {
      await _service.scheduleDueReminders(
        title: 'Monthly due reminder',
        body: 'Check your due amount in the app',
      );
    } else {
      await _service.cancelDueReminders();
    }
  }
}
