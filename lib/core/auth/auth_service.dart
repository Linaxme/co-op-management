import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../firebase/firebase_service.dart';
import '../firebase/models.dart';
import '../utils/coop_short_name.dart';
import '../utils/phone_utils.dart';
import 'auth_session.dart';
import 'member_auth_email.dart';

class AuthService {
  AuthService(this._firebase);

  final FirebaseService _firebase;
  static const _coopCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  FirebaseAuth get _auth => _firebase.auth;
  FirebaseFirestore get _firestore => _firebase.firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AuthSession> resolveSession(User? user) async {
    if (user == null) return AuthSession.unauthenticated;

    if (user.isAnonymous) {
      await _auth.signOut();
      return AuthSession.unauthenticated;
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    var userDoc = await userRef.get();
    if (!userDoc.exists) {
      await _auth.signOut();
      return AuthSession.unauthenticated;
    }

    var data = userDoc.data()!;
    var role = data['role'] as String?;
    var coopId = data['coopId'] as String?;
    var coopCode = data['coopCode'] as String?;

    if (coopId == null || coopId.isEmpty) {
      if (role == 'admin') {
        final migrated = await _migrateLegacyAdminIfNeeded(
          uid: user.uid,
          userData: data,
        );
        if (migrated != null) {
          coopId = migrated.coopId;
          coopCode = migrated.coopCode;
        } else {
          final refreshed = await userRef.get();
          coopId = refreshed.data()?['coopId'] as String?;
          coopCode = refreshed.data()?['coopCode'] as String?;
          if (coopId != null && coopId.isNotEmpty) {
            await ensureLegacyDataMigrated(coopId);
          }
        }
      } else if (role == 'member') {
        final memberUuid = data['memberUuid'] as String?;
        if (memberUuid != null && memberUuid.isNotEmpty) {
          final resolved = await _resolveCoopForLegacyMember(memberUuid);
          if (resolved != null) {
            coopId = resolved.coopId;
            coopCode = resolved.coopCode;
            await userRef.update({
              'coopId': coopId,
              if (coopCode != null) 'coopCode': coopCode,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    }

    if (coopId == null || coopId.isEmpty) {
      await _auth.signOut();
      return AuthSession.unauthenticated;
    }

    if (role == 'admin') {
      if (coopCode == null) {
        coopCode = await _loadCoopCode(coopId);
      }
      return AuthSession(
        user: user,
        role: UserRole.admin,
        coopId: coopId,
        coopCode: coopCode,
      );
    }

    if (role == 'member') {
      final memberUuid = data['memberUuid'] as String?;
      if (memberUuid == null || memberUuid.isEmpty) {
        await _auth.signOut();
        return AuthSession.unauthenticated;
      }
      if (coopCode == null) {
        coopCode = await _loadCoopCode(coopId);
      }
      return AuthSession(
        user: user,
        role: UserRole.member,
        memberUuid: memberUuid,
        coopId: coopId,
        coopCode: coopCode,
      );
    }

    await _auth.signOut();
    return AuthSession.unauthenticated;
  }

  Future<AuthSession> signUpCooperative({
    required String organizationName,
    required String organizationAddress,
    required String organizationShortName,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }
    if (organizationName.trim().isEmpty || organizationAddress.trim().isEmpty) {
      throw AuthException('Organization name and address are required');
    }

    final shortName = CoopShortName.normalize(organizationShortName);
    final shortNameError = CoopShortName.validationError(organizationShortName);
    if (shortNameError != null) {
      throw AuthException(_shortNameErrorMessage(shortNameError));
    }
    if (!await isShortNameAvailable(shortName)) {
      throw AuthException('This short name is already taken');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final uid = credential.user!.uid;
      final coopId = const Uuid().v4();
      final coopCode = await _generateUniqueCoopCode();
      final now = DateTime.now().toIso8601String();

      final batch = _firestore.batch();

      batch.set(_firestore.collection('users').doc(uid), {
        'role': 'admin',
        'email': trimmedEmail,
        'coopId': coopId,
        'coopCode': coopCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(_firebase.cooperativeDoc(coopId), {
        'adminUid': uid,
        'coopCode': coopCode,
        'shortName': shortName,
        'name': organizationName.trim(),
        'address': organizationAddress.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': now,
      });

      batch.set(_firebase.settingsDoc(coopId), {
        'defaultReceivedBy': 'Admin',
        'receiptPrefix': 'RCPT',
        'nextReceiptSerial': 1,
        'language': 'en',
        'themeMode': 'system',
        'defaultMemberPassword': '123456',
        'memberShowCoopTotalCollection': true,
        'memberShowCoopTotalDue': true,
        'memberShowDueMembersList': true,
        'memberShowCoopCurrentMonth': true,
        'updatedAt': now,
      });

      await batch.commit();

      return AuthSession(
        user: credential.user,
        role: UserRole.admin,
        coopId: coopId,
        coopCode: coopCode,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('signUpCooperative failed: ${e.code}');
      throw AuthException(_authErrorMessage(e));
    } on FirebaseException catch (e) {
      debugPrint('signUpCooperative firestore failed: ${e.code}');
      await _auth.signOut();
      throw AuthException('Failed to set up cooperative. Please try again.');
    }
  }

  Future<AuthSession> signInAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final session = await resolveSession(credential.user);
      if (!session.isAdmin) {
        await _auth.signOut();
        throw AuthException('Not authorized as admin');
      }
      return session;
    } on FirebaseAuthException catch (e) {
      debugPrint('Admin sign in failed: ${e.code}');
      throw AuthException(_authErrorMessage(e));
    }
  }

  Future<AuthSession> signInMember({
    required String phone,
    required String password,
    String? shortName,
    String? coopCode,
  }) async {
    final normalized = PhoneUtils.normalizeForLogin(phone);
    if (normalized == null) {
      throw AuthException('Invalid phone number');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    final trimmedShort = shortName != null && shortName.trim().isNotEmpty
        ? CoopShortName.normalize(shortName)
        : '';
    final trimmedCode = coopCode?.trim().toUpperCase() ?? '';

    try {
      String? coopId;

      if (trimmedShort.isNotEmpty) {
        final lookup = await lookupCooperativeByShortName(trimmedShort);
        if (lookup == null) {
          throw AuthException('Invalid organization short name');
        }
        coopId = lookup.coopId;
      } else if (trimmedCode.isNotEmpty) {
        final coopSnap = await _firebase.cooperativesCollection
            .where('coopCode', isEqualTo: trimmedCode)
            .limit(1)
            .get();
        if (coopSnap.docs.isEmpty) {
          throw AuthException('Invalid cooperative code');
        }
        coopId = coopSnap.docs.first.id;
      } else {
        return await _signInMemberLegacy(
          normalized: normalized,
          password: password,
        );
      }

      final memberEmail = MemberAuthEmail.fromPhone(normalized, coopId);
      final credential = await _auth.signInWithEmailAndPassword(
        email: memberEmail,
        password: password,
      );
      final session = await resolveSession(credential.user);
      if (!session.isMember) {
        await _auth.signOut();
        throw AuthException('Invalid phone or password');
      }
      return session;
    } on FirebaseAuthException catch (e) {
      debugPrint('Member sign in failed: ${e.code}');
      if (trimmedShort.isEmpty && trimmedCode.isEmpty) {
        try {
          return await _signInMemberLegacy(
            normalized: normalized,
            password: password,
          );
        } catch (_) {
          // fall through
        }
      }
      throw AuthException('Invalid phone, password, or organization');
    }
  }

  Future<CooperativeLookup?> lookupCooperativeByShortName(String shortName) async {
    final normalized = CoopShortName.normalize(shortName);
    if (CoopShortName.validationError(normalized) != null) return null;

    final snap = await _firebase.cooperativesCollection
        .where('shortName', isEqualTo: normalized)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;
    final data = doc.data();
    return CooperativeLookup(
      coopId: doc.id,
      name: data['name'] as String? ?? '',
      shortName: data['shortName'] as String? ?? normalized,
      logoPath: data['logoPath'] as String?,
    );
  }

  Future<bool> isShortNameAvailable(
    String shortName, {
    String? excludeCoopId,
  }) async {
    final normalized = CoopShortName.normalize(shortName);
    if (CoopShortName.validationError(normalized) != null) return false;

    final snap = await _firebase.cooperativesCollection
        .where('shortName', isEqualTo: normalized)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return true;
    if (excludeCoopId != null && snap.docs.first.id == excludeCoopId) {
      return true;
    }
    return false;
  }

  String _shortNameErrorMessage(String code) {
    switch (code) {
      case 'too_short':
        return 'Short name must be at least 2 characters';
      case 'too_long':
        return 'Short name must be at most 12 characters';
      default:
        return 'Short name may only contain letters and numbers';
    }
  }

  Future<AuthSession> _signInMemberLegacy({
    required String normalized,
    required String password,
  }) async {
    final legacyEmail = MemberAuthEmail.legacyFromPhone(normalized);
    final credential = await _auth.signInWithEmailAndPassword(
      email: legacyEmail,
      password: password,
    );
    final session = await resolveSession(credential.user);
    if (!session.isMember) {
      await _auth.signOut();
      throw AuthException('Invalid phone or password');
    }
    return session;
  }

  Future<String?> getCurrentUserCoopId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['coopId'] as String?;
  }

  Future<void> provisionMemberLogin({
    required String memberUuid,
    required String phoneNormalized,
    required String password,
    String? coopId,
  }) async {
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    final resolvedCoopId = coopId ?? await getCurrentUserCoopId();
    if (resolvedCoopId == null || resolvedCoopId.isEmpty) {
      throw AuthException('Not signed in as admin');
    }

    final coopDoc = await _firebase.cooperativeDoc(resolvedCoopId).get();
    final coopCode = coopDoc.data()?['coopCode'] as String?;

    final email = MemberAuthEmail.fromPhone(phoneNormalized, resolvedCoopId);
    final secondaryAuth = await _firebase.secondaryAuth;

    try {
      final memberUid = await _createOrUpdateMemberAuthUser(
        secondaryAuth: secondaryAuth,
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(memberUid).set({
        'role': 'member',
        'memberUuid': memberUuid,
        'phoneNormalized': phoneNormalized,
        'email': email,
        'coopId': resolvedCoopId,
        if (coopCode != null) 'coopCode': coopCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      debugPrint('provisionMemberLogin failed: ${e.code} ${e.message}');
      throw AuthException(_memberProvisionErrorMessage(e));
    } on FirebaseException catch (e) {
      debugPrint('provisionMemberLogin firestore failed: ${e.code}');
      throw AuthException('Failed to save member login');
    }
  }

  Future<({String coopId, String coopCode})?> _migrateLegacyAdminIfNeeded({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    if (userData['role'] != 'admin') return null;

    final metaDoc = await _firebase.legacyCooperativeMetaDoc.get();
    if (!metaDoc.exists) {
      debugPrint('Legacy migration: no _meta/cooperative doc');
      return null;
    }

    try {
      final meta = metaDoc.data()!;
      final coopId = const Uuid().v4();
      final coopCode = await _generateUniqueCoopCode();
      final now = DateTime.now().toIso8601String();

      var name = meta['organizationName'] as String? ?? 'My Cooperative';
      var address = '';
      final orgs = await _firebase.legacyOrganizationsCollection.get();
      if (orgs.docs.isNotEmpty) {
        final od = orgs.docs.first.data();
        name = od['name'] as String? ?? name;
        address = od['address'] as String? ?? '';
      }

      await _firestore.runTransaction((tx) async {
        tx.set(_firebase.cooperativeDoc(coopId), {
          'adminUid': uid,
          'coopCode': coopCode,
          'name': name,
          'address': address,
          'migratedFromLegacy': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': now,
        });
        tx.update(_firestore.collection('users').doc(uid), {
          'coopId': coopId,
          'coopCode': coopCode,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      await _copyLegacyFirestoreDataToCoop(coopId);

      debugPrint('Legacy admin migrated to coop $coopId ($coopCode)');
      return (coopId: coopId, coopCode: coopCode);
    } on FirebaseException catch (e) {
      debugPrint('Legacy migration failed: ${e.code} ${e.message}');
      return null;
    }
  }

  /// Copies root-level Firestore data into cooperatives/{coopId}/…
  Future<void> _copyLegacyFirestoreDataToCoop(String coopId) async {
    try {
      final legacyMembers = await _firebase.legacyMembersCollection.get();
      for (final doc in legacyMembers.docs) {
        await _firebase
            .membersCollection(coopId)
            .doc(doc.id)
            .set(doc.data(), SetOptions(merge: true));
      }

      final legacyDeposits = await _firebase.legacyDepositsCollection.get();
      for (final doc in legacyDeposits.docs) {
        await _firebase
            .depositsCollection(coopId)
            .doc(doc.id)
            .set(doc.data(), SetOptions(merge: true));
      }

      final legacySettings = await _firebase.legacySettingsCollection.get();
      if (legacySettings.docs.isNotEmpty) {
        await _firebase
            .settingsDoc(coopId)
            .set(legacySettings.docs.first.data(), SetOptions(merge: true));
      }

      debugPrint(
        'Legacy copy: ${legacyMembers.docs.length} members, '
        '${legacyDeposits.docs.length} deposits',
      );
    } on FirebaseException catch (e) {
      debugPrint('Legacy data copy failed: ${e.code} ${e.message}');
    }
  }

  /// If cooperative subcollections are empty but legacy root data exists, copy it.
  Future<void> ensureLegacyDataMigrated(String coopId) async {
    if (coopId.isEmpty) return;
    try {
      final coopMembers = await _firebase.membersCollection(coopId).limit(1).get();
      if (coopMembers.docs.isNotEmpty) return;

      final legacyMembers = await _firebase.legacyMembersCollection.limit(1).get();
      if (legacyMembers.docs.isEmpty) return;

      debugPrint('ensureLegacyDataMigrated: copying legacy data to $coopId');
      await _copyLegacyFirestoreDataToCoop(coopId);
    } on FirebaseException catch (e) {
      debugPrint('ensureLegacyDataMigrated failed: ${e.code}');
    }
  }

  Future<({String coopId, String? coopCode})?> _resolveCoopForLegacyMember(
    String memberUuid,
  ) async {
    final coops = await _firebase.cooperativesCollection.get();
    for (final coop in coops.docs) {
      final memberSnap = await _firebase
          .membersCollection(coop.id)
          .where('uuid', isEqualTo: memberUuid)
          .limit(1)
          .get();
      if (memberSnap.docs.isNotEmpty) {
        return (
          coopId: coop.id,
          coopCode: coop.data()['coopCode'] as String?,
        );
      }
    }

    // Legacy data not yet migrated — check root members collection
    final legacyMember = await _firebase.legacyMembersCollection
        .where('uuid', isEqualTo: memberUuid)
        .limit(1)
        .get();
    if (legacyMember.docs.isEmpty) return null;

    final metaDoc = await _firebase.legacyCooperativeMetaDoc.get();
    if (!metaDoc.exists) return null;

    final migratedCoops = await _firebase.cooperativesCollection
        .where('migratedFromLegacy', isEqualTo: true)
        .limit(1)
        .get();
    if (migratedCoops.docs.isNotEmpty) {
      final coop = migratedCoops.docs.first;
      return (
        coopId: coop.id,
        coopCode: coop.data()['coopCode'] as String?,
      );
    }

    return null;
  }

  Future<String?> _loadCoopCode(String coopId) async {
    final doc = await _firebase.cooperativeDoc(coopId).get();
    return doc.data()?['coopCode'] as String?;
  }

  Future<String> _createOrUpdateMemberAuthUser({
    required FirebaseAuth secondaryAuth,
    required String email,
    required String password,
  }) async {
    User? memberUser;

    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      memberUser = credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;

      try {
        final credential = await secondaryAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        memberUser = credential.user;
        await memberUser!.updatePassword(password);
      } on FirebaseAuthException {
        throw AuthException(
          'This phone already has a login with a different password',
        );
      }
    }

    if (memberUser == null) {
      throw AuthException('Failed to create member login');
    }

    final uid = memberUser.uid;
    await secondaryAuth.signOut();
    return uid;
  }

  Future<void> resetMemberPassword({
    required String memberUuid,
    required String password,
    required String currentDefaultPassword,
    String? coopId,
  }) async {
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    final resolvedCoopId = coopId ?? await getCurrentUserCoopId();
    if (resolvedCoopId == null) {
      throw AuthException('Not signed in as admin');
    }

    var userSnap = await _firestore
        .collection('users')
        .where('memberUuid', isEqualTo: memberUuid)
        .where('role', isEqualTo: 'member')
        .where('coopId', isEqualTo: resolvedCoopId)
        .limit(1)
        .get();

    if (userSnap.docs.isEmpty) {
      userSnap = await _firestore
          .collection('users')
          .where('memberUuid', isEqualTo: memberUuid)
          .where('role', isEqualTo: 'member')
          .limit(1)
          .get();
    }

    if (userSnap.docs.isEmpty) {
      throw AuthException('Member login not found');
    }

    final email = userSnap.docs.first.data()['email'] as String?;
    if (email == null || email.isEmpty) {
      throw AuthException('Member login not found');
    }

    final secondaryAuth = await _firebase.secondaryAuth;
    try {
      final credential = await secondaryAuth.signInWithEmailAndPassword(
        email: email,
        password: currentDefaultPassword,
      );
      await credential.user!.updatePassword(password);
      await secondaryAuth.signOut();
    } on FirebaseAuthException {
      await secondaryAuth.signOut();
      throw AuthException(
        'Cannot reset password — member may have changed it already',
      );
    }
  }

  Future<void> changeOwnPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw AuthException('Not signed in');
    }
    if (newPassword.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      debugPrint('changeOwnPassword failed: ${e.code}');
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw AuthException('Current password is incorrect');
      }
      throw AuthException('Failed to change password');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> _generateUniqueCoopCode() async {
    final rng = Random.secure();
    for (var attempt = 0; attempt < 20; attempt++) {
      final code = List.generate(
        6,
        (_) => _coopCodeChars[rng.nextInt(_coopCodeChars.length)],
      ).join();
      final snap = await _firebase.cooperativesCollection
          .where('coopCode', isEqualTo: code)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return code;
    }
    throw AuthException('Could not generate cooperative code. Try again.');
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _memberProvisionErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid phone number for login';
      case 'weak-password':
        return 'Default password must be at least 6 characters';
      default:
        return 'Failed to create member login';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
