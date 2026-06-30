import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const _webFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyB0GIqmb22q3r--k-SFJpDm4qEPJ-XDfRs',
  authDomain: 'coop-app-firebase.firebaseapp.com',
  projectId: 'coop-app-firebase',
  storageBucket: 'coop-app-firebase.firebasestorage.app',
  messagingSenderId: '522044625756',
  appId: '1:522044625756:web:a0592821b7c0bfc842a799',
);

class FirebaseService {
  static const secondaryAppName = 'MemberProvisioner';

  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _auth!;
  }

  Future<void> initialize() async {
    if (kIsWeb) {
      await Firebase.initializeApp(options: _webFirebaseOptions);
    } else {
      await Firebase.initializeApp();
    }

    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    if (!kIsWeb) {
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  bool get isAuthenticated {
    final user = auth.currentUser;
    return user != null && !user.isAnonymous;
  }

  User? get currentUser => auth.currentUser;

  Future<void> signOut() async {
    await auth.signOut();
  }

  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get cooperativesCollection =>
      firestore.collection('cooperatives');

  DocumentReference<Map<String, dynamic>> cooperativeDoc(String coopId) =>
      cooperativesCollection.doc(coopId);

  CollectionReference<Map<String, dynamic>> membersCollection(String coopId) =>
      cooperativeDoc(coopId).collection('members');

  CollectionReference<Map<String, dynamic>> depositsCollection(String coopId) =>
      cooperativeDoc(coopId).collection('deposits');

  DocumentReference<Map<String, dynamic>> settingsDoc(String coopId) =>
      cooperativeDoc(coopId).collection('settings').doc('default');

  // Legacy single-tenant collections (read-only during migration)
  DocumentReference<Map<String, dynamic>> get legacyCooperativeMetaDoc =>
      firestore.collection('_meta').doc('cooperative');

  CollectionReference<Map<String, dynamic>> get legacyMembersCollection =>
      firestore.collection('members');

  CollectionReference<Map<String, dynamic>> get legacyDepositsCollection =>
      firestore.collection('deposits');

  CollectionReference<Map<String, dynamic>> get legacyOrganizationsCollection =>
      firestore.collection('organizations');

  CollectionReference<Map<String, dynamic>> get legacySettingsCollection =>
      firestore.collection('settings');

  Future<FirebaseAuth> get secondaryAuth async {
    final app = await _getOrInitSecondaryApp();
    return FirebaseAuth.instanceFor(app: app);
  }

  Future<FirebaseApp> _getOrInitSecondaryApp() async {
    try {
      return Firebase.app(secondaryAppName);
    } catch (_) {
      if (kIsWeb) {
        return Firebase.initializeApp(
          name: secondaryAppName,
          options: _webFirebaseOptions,
        );
      }
      return Firebase.initializeApp(name: secondaryAppName);
    }
  }
}
