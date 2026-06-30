import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class PushNotificationApi {
  PushNotificationApi._();
  static final PushNotificationApi instance = PushNotificationApi._();

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  Future<AnnouncementResult> sendAnnouncement({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Push announcements require the mobile app');
    }

    final callable = _functions.httpsCallable('sendCoopAnnouncement');
    final result = await callable.call<Map<String, dynamic>>({
      'title': title,
      'body': body,
    });

    final data = result.data;
    return AnnouncementResult(
      sent: (data['sent'] as num?)?.toInt() ?? 0,
      failed: (data['failed'] as num?)?.toInt() ?? 0,
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class AnnouncementResult {
  final int sent;
  final int failed;
  final int total;

  const AnnouncementResult({
    required this.sent,
    required this.failed,
    required this.total,
  });
}
