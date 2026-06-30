import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../firebase/firebase_service.dart';
import 'notification_prefs.dart';

const _channelId = 'coop_default';
const _dueReminderId1 = 1001;
const _dueReminderId2 = 1002;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.notification?.title}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final NotificationPrefsStore _prefsStore = NotificationPrefsStore();
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      'Cooperative Alerts',
      description: 'Deposits, due reminders, and updates',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _requestPermissions();
    _setupFcmForeground();
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final uid = FirebaseService.instance.currentUser?.uid;
      if (uid == null || token.isEmpty) return;
      try {
        await FirebaseService.instance.usersCollection.doc(uid).set(
          {
            'fcmToken': token,
            'fcmUpdatedAt': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('FCM token refresh save failed: $e');
      }
    });

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await FirebaseMessaging.instance.requestPermission();
  }

  void _setupFcmForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      showLocal(
        title: notification.title ?? 'Cooperative',
        body: notification.body ?? '',
      );
    });
  }

  Future<NotificationPrefs> loadPrefs() => _prefsStore.load();

  Future<void> savePrefs(NotificationPrefs prefs) async {
    await _prefsStore.save(prefs);
    if (!prefs.enabled || !prefs.dueReminders) {
      await cancelDueReminders();
    }
  }

  Future<void> registerFcmToken(String uid) async {
    if (kIsWeb) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      await FirebaseService.instance.usersCollection.doc(uid).set(
        {
          'fcmToken': token,
          'fcmUpdatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      debugPrint('FCM token saved for $uid');
    } catch (e) {
      debugPrint('FCM token save failed: $e');
    }
  }

  Future<void> showLocal({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb) return;
    final prefs = await loadPrefs();
    if (!prefs.enabled) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Cooperative Alerts',
        channelDescription: 'Deposits, due reminders, and updates',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _local.show(id, title, body, details);
  }

  Future<void> showDepositRecorded({
    required int amount,
    required int receiptSerial,
    String? memberName,
  }) async {
    final prefs = await loadPrefs();
    if (!prefs.enabled) return;

    final title = memberName != null
        ? 'Deposit recorded — $memberName'
        : 'Deposit recorded';
    final body = 'Amount: $amount BDT · Receipt #$receiptSerial';
    await showLocal(
      title: title,
      body: body,
      id: receiptSerial % 100000,
    );
  }

  Future<void> scheduleDueReminders({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    final prefs = await loadPrefs();
    if (!prefs.enabled || !prefs.dueReminders) return;

    await cancelDueReminders();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Cooperative Alerts',
        channelDescription: 'Deposits, due reminders, and updates',
        importance: Importance.defaultImportance,
      ),
    );

    for (final entry in [
      (_dueReminderId1, 10),
      (_dueReminderId2, 20),
    ]) {
      final scheduled = _nextMonthly(entry.$2, 10, 0);
      await _local.zonedSchedule(
        entry.$1,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }

  tz.TZDateTime _nextMonthly(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        day,
        hour,
        minute,
      );
    }
    return scheduled;
  }

  Future<void> cancelDueReminders() async {
    if (kIsWeb) return;
    await _local.cancel(_dueReminderId1);
    await _local.cancel(_dueReminderId2);
  }

  Future<void> onMemberSessionStarted({
    required String uid,
    required String dueReminderTitle,
    required String dueReminderBody,
  }) async {
    await registerFcmToken(uid);
    await scheduleDueReminders(
      title: dueReminderTitle,
      body: dueReminderBody,
    );
  }

  Future<void> onAdminSessionStarted({required String uid}) async {
    await registerFcmToken(uid);
    await cancelDueReminders();
  }
}
