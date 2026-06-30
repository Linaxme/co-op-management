import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefs {
  final bool enabled;
  final bool dueReminders;

  const NotificationPrefs({
    this.enabled = true,
    this.dueReminders = true,
  });

  NotificationPrefs copyWith({bool? enabled, bool? dueReminders}) {
    return NotificationPrefs(
      enabled: enabled ?? this.enabled,
      dueReminders: dueReminders ?? this.dueReminders,
    );
  }
}

class NotificationPrefsStore {
  static const _keyEnabled = 'notifications_enabled';
  static const _keyDueReminders = 'due_reminders_enabled';

  Future<NotificationPrefs> load() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPrefs(
      enabled: prefs.getBool(_keyEnabled) ?? true,
      dueReminders: prefs.getBool(_keyDueReminders) ?? true,
    );
  }

  Future<void> save(NotificationPrefs prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyEnabled, prefs.enabled);
    await sp.setBool(_keyDueReminders, prefs.dueReminders);
  }
}
