import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firebase_service.dart';

/// Saves announcements to Firestore (works on Spark plan, no Cloud Functions).
class AnnouncementService {
  AnnouncementService._();
  static final AnnouncementService instance = AnnouncementService._();

  Future<void> publish({
    required String coopId,
    required String adminUid,
    required String title,
    required String body,
  }) async {
    await FirebaseService.instance.cooperativesCollection
        .doc(coopId)
        .collection('announcements')
        .add({
      'title': title,
      'body': body,
      'createdBy': adminUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
