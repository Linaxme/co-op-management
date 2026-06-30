import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase/firebase_service.dart';
import 'notification_service.dart';

/// Listens to Firestore for new announcements and deposits (Spark plan friendly).
class FirestoreNotificationListener {
  FirestoreNotificationListener._();
  static final FirestoreNotificationListener instance =
      FirestoreNotificationListener._();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _announcementSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _depositSub;
  bool _announcementsReady = false;
  bool _depositListenerReady = false;
  final Set<String> _knownDepositUuids = {};

  Future<void> start({
    required String coopId,
    String? memberUuid,
    required bool isMember,
  }) async {
    if (kIsWeb) return;
    await stop();

    _announcementSub = FirebaseService.instance.cooperativesCollection
        .doc(coopId)
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(15)
        .snapshots()
        .listen((snap) => _onAnnouncements(snap));

    if (isMember && memberUuid != null) {
      _depositSub = FirebaseService.instance.depositsCollection(coopId)
          .where('memberUuid', isEqualTo: memberUuid)
          .snapshots()
          .listen((snap) => _onDeposits(snap));
    }
  }

  Future<void> _onAnnouncements(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    if (!_announcementsReady) {
      _announcementsReady = true;
      var maxMs = prefs.getInt('last_announcement_ms') ?? 0;
      for (final doc in snap.docs) {
        final ms = _createdMs(doc.data());
        if (ms > maxMs) maxMs = ms;
      }
      await prefs.setInt('last_announcement_ms', maxMs);
      return;
    }

    final lastSeenMs = prefs.getInt('last_announcement_ms') ?? 0;

    for (final change in snap.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      final data = change.doc.data();
      if (data == null) continue;

      final createdMs = _createdMs(data);
      if (createdMs <= lastSeenMs) continue;

      final title = data['title'] as String? ?? 'Announcement';
      final body = data['body'] as String? ?? '';
      await NotificationService.instance.showLocal(title: title, body: body);
      await prefs.setInt('last_announcement_ms', createdMs);
    }
  }

  int _createdMs(Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      return createdAt.millisecondsSinceEpoch;
    }
    if (createdAt is String) {
      return DateTime.tryParse(createdAt)?.millisecondsSinceEpoch ?? 0;
    }
    return 0;
  }

  Future<void> _onDeposits(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    if (!_depositListenerReady) {
      for (final doc in snap.docs) {
        final uuid = doc.data()['uuid'] as String?;
        if (uuid != null) _knownDepositUuids.add(uuid);
      }
      _depositListenerReady = true;
      return;
    }

    for (final change in snap.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      final data = change.doc.data();
      if (data == null) continue;

      final uuid = data['uuid'] as String?;
      if (uuid == null || _knownDepositUuids.contains(uuid)) continue;
      _knownDepositUuids.add(uuid);

      final amount = (data['amount'] as num?)?.toInt() ?? 0;
      final receipt = (data['receiptSerial'] as num?)?.toInt() ?? 0;
      await NotificationService.instance.showDepositRecorded(
        amount: amount,
        receiptSerial: receipt,
      );
    }
  }

  Future<void> stop() async {
    await _announcementSub?.cancel();
    await _depositSub?.cancel();
    _announcementSub = null;
    _depositSub = null;
    _announcementsReady = false;
    _depositListenerReady = false;
    _knownDepositUuids.clear();
  }
}
