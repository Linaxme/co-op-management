import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_session.dart';
import '../db/app_db.dart';
import '../notifications/notification_service.dart';
import 'firebase_service.dart';
import 'member_photo_storage.dart';
import 'organization_image_storage.dart';
import 'models.dart';

class SyncService {
  final AppDb _db;
  final FirebaseService _firebase;
  final Connectivity _connectivity;
  final MemberPhotoStorage _photoStorage;
  final OrganizationImageStorage _orgImageStorage;

  SyncService(
    this._db,
    this._firebase,
    this._connectivity, [
    MemberPhotoStorage? photoStorage,
    OrganizationImageStorage? orgImageStorage,
  ])  : _photoStorage = photoStorage ?? MemberPhotoStorage(),
        _orgImageStorage = orgImageStorage ?? OrganizationImageStorage() {
    _initConnectivity();
  }

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;
  Timer? _syncTimer;
  Timer? _syncDebounce;
  final List<StreamSubscription<dynamic>> _realtimeSubscriptions = [];
  AuthSession _session = AuthSession.unauthenticated;

  void setSession(AuthSession session) {
    _session = session;
  }

  bool get _isAdmin => _session.isAdmin;
  String? get _coopId => _session.coopId;

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  void _initConnectivity() {
    if (kIsWeb) {
      // connectivity_plus is unreliable in browsers — Firestore needs network anyway.
      _isOnline = true;
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectivity);
      return;
    }
    _connectivity.checkConnectivity().then(_updateConnectivity);
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    if (kIsWeb) {
      _isOnline = results.isEmpty ||
          results.any((result) => result != ConnectivityResult.none);
      if (!_isOnline) _isOnline = true;
    } else {
      _isOnline = results.any((result) => result != ConnectivityResult.none);
    }

    if (!wasOnline && _isOnline) {
      _syncStatusController.add(SyncStatus.connecting);
      syncAll();
    } else if (wasOnline && !_isOnline) {
      _syncStatusController.add(SyncStatus.offline);
    }
  }

  bool get _canSync =>
      _isOnline && _firebase.isAuthenticated && _coopId != null;

  static bool _isPlaceholderOrg(OrganizationData org) {
    return org.name == 'My Cooperative Society' &&
        org.address == 'Address here' &&
        (org.logoPath == null || org.logoPath!.trim().isEmpty) &&
        (org.signaturePath == null || org.signaturePath!.trim().isEmpty);
  }

  Future<void> _applyFirestoreOrganization(
    OrganizationData? localOrg,
    FirestoreOrganization firestoreOrg,
  ) async {
    if (localOrg == null) {
      await _db.into(_db.organization).insert(OrganizationCompanion.insert(
        name: firestoreOrg.name,
        shortName: Value(firestoreOrg.shortName),
        address: firestoreOrg.address,
        logoPath: Value(firestoreOrg.logoPath),
        signaturePath: Value(firestoreOrg.signaturePath),
        updatedAt: firestoreOrg.updatedAt,
      ));
      return;
    }

    await _db.update(_db.organization).replace(localOrg.copyWith(
      name: firestoreOrg.name,
      shortName: Value(firestoreOrg.shortName),
      address: firestoreOrg.address,
      logoPath: Value(firestoreOrg.logoPath),
      signaturePath: Value(firestoreOrg.signaturePath),
      updatedAt: firestoreOrg.updatedAt,
    ));
  }

  Future<void> _applyFirestoreSettings(
    SettingsData? localSettings,
    FirestoreSettings firestoreSetting,
    String coopId, {
    bool preserveDevicePrefs = false,
  }) async {
    if (localSettings == null) {
      await _db.into(_db.settings).insert(SettingsCompanion.insert(
        defaultReceivedBy: firestoreSetting.defaultReceivedBy,
        receiptPrefix: Value(firestoreSetting.receiptPrefix),
        nextReceiptSerial: Value(firestoreSetting.nextReceiptSerial),
        language: Value(firestoreSetting.language),
        themeMode: Value(firestoreSetting.themeMode),
        defaultMemberPassword: Value(firestoreSetting.defaultMemberPassword),
        memberShowCoopTotalCollection:
            Value(firestoreSetting.memberShowCoopTotalCollection),
        memberShowCoopTotalDue: Value(firestoreSetting.memberShowCoopTotalDue),
        memberShowDueMembersList:
            Value(firestoreSetting.memberShowDueMembersList),
        memberShowCoopCurrentMonth:
            Value(firestoreSetting.memberShowCoopCurrentMonth),
        tenantCoopId: Value(coopId),
        updatedAt: firestoreSetting.updatedAt,
      ));
      return;
    }

    await _db.update(_db.settings).replace(localSettings.copyWith(
      defaultReceivedBy: firestoreSetting.defaultReceivedBy,
      receiptPrefix: firestoreSetting.receiptPrefix,
      nextReceiptSerial: firestoreSetting.nextReceiptSerial,
      language: preserveDevicePrefs
          ? localSettings.language
          : firestoreSetting.language,
      themeMode: preserveDevicePrefs
          ? localSettings.themeMode
          : firestoreSetting.themeMode,
      defaultMemberPassword: firestoreSetting.defaultMemberPassword,
      memberShowCoopTotalCollection:
          firestoreSetting.memberShowCoopTotalCollection,
      memberShowCoopTotalDue: firestoreSetting.memberShowCoopTotalDue,
      memberShowDueMembersList: firestoreSetting.memberShowDueMembersList,
      memberShowCoopCurrentMonth: firestoreSetting.memberShowCoopCurrentMonth,
      tenantCoopId: Value(coopId),
      updatedAt: firestoreSetting.updatedAt,
    ));
  }

  void _scheduleSyncAll() {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 400), () {
      if (_canSync) syncAll();
    });
  }

  Future<void> syncAll() async {
    if (!_canSync) {
      _syncStatusController.add(SyncStatus.offline);
      return;
    }

    try {
      _syncStatusController.add(SyncStatus.syncing);

      Set<String> memberDepositUuidsBefore = {};
      if (_session.isMember && _session.memberUuid != null) {
        final rows = await (_db.select(_db.deposits)
              ..where(
                (d) =>
                    d.memberUuid.equals(_session.memberUuid!) &
                    d.deletedAt.isNull(),
              ))
            .get();
        memberDepositUuidsBefore = rows.map((d) => d.uuid).toSet();
      }

      if (_isAdmin) {
        await _ensureLegacyFirestoreCopied(_coopId!);
      }

      // Organization + settings first so branding is available before member data.
      await syncOrganization();
      await syncSettings();
      await Future.wait([
        syncMembers(),
        syncDeposits(),
      ]);

      await _notifyNewMemberDeposits(memberDepositUuidsBefore);

      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      debugPrint('Sync failed: $e');
      _syncStatusController.add(SyncStatus.error);
    }
  }

  Future<void> syncMembers() async {
    final coopId = _coopId!;
    final localMembers = await _db.select(_db.members).get();
    var firestoreMembers = await _firebase.membersCollection(coopId).get();
    if (firestoreMembers.docs.isEmpty && _isAdmin) {
      firestoreMembers = await _pullLegacyMembersIntoCoop(coopId);
    }

    for (final doc in firestoreMembers.docs) {
      final firestoreMember = FirestoreMember.fromFirestore(doc);
      final localMember = localMembers
          .where((m) => m.uuid == firestoreMember.uuid)
          .firstOrNull;

      if (localMember == null) {
        try {
          await _db.into(_db.members).insert(MembersCompanion.insert(
            uuid: firestoreMember.uuid,
            memberIdNumber: firestoreMember.memberIdNumber,
            name: firestoreMember.name,
            phone: Value(firestoreMember.phone),
            phoneNormalized: Value(firestoreMember.phoneNormalized),
            pinHash: Value(firestoreMember.pinHash),
            address: Value(firestoreMember.address),
            nidNumber: Value(firestoreMember.nidNumber),
            photoPath: Value(firestoreMember.photoPath),
            monthlyAmount: firestoreMember.monthlyAmount,
            isActive: Value(firestoreMember.isActive),
            canCollectDeposits: Value(firestoreMember.canCollectDeposits),
            deletedAt: Value(firestoreMember.deletedAt),
            createdAt: firestoreMember.createdAt,
            updatedAt: firestoreMember.updatedAt,
          ));
        } catch (e) {
          debugPrint('Sync insert member ${firestoreMember.uuid} failed: $e');
        }
      } else if (firestoreMember.updatedAt.isAfter(localMember.updatedAt)) {
        await _db.update(_db.members).replace(localMember.copyWith(
          name: firestoreMember.name,
          phone: Value(firestoreMember.phone),
          phoneNormalized: Value(firestoreMember.phoneNormalized),
          pinHash: Value(firestoreMember.pinHash),
          address: Value(firestoreMember.address),
          nidNumber: Value(firestoreMember.nidNumber),
          photoPath: Value(firestoreMember.photoPath),
          monthlyAmount: firestoreMember.monthlyAmount,
          isActive: firestoreMember.isActive,
          canCollectDeposits: firestoreMember.canCollectDeposits,
          deletedAt: Value(firestoreMember.deletedAt),
          createdAt: firestoreMember.createdAt,
          updatedAt: firestoreMember.updatedAt,
        ));
      }
    }

    if (!_isAdmin) {
      try {
        await _pushOwnMemberRecord(localMembers, firestoreMembers);
      } catch (e) {
        debugPrint('Member profile push skipped (server-managed): $e');
      }
      return;
    }

    for (final localMember in localMembers) {
      var member = localMember;
      final uploadedPhoto = await _photoStorage.uploadIfLocal(
        coopId: coopId,
        memberUuid: member.uuid,
        photoPath: member.photoPath,
      );
      if (uploadedPhoto != null && uploadedPhoto != member.photoPath) {
        final now = DateTime.now();
        await (_db.update(_db.members)..where((m) => m.uuid.equals(member.uuid)))
            .write(
          MembersCompanion(
            photoPath: Value(uploadedPhoto),
            updatedAt: Value(now),
          ),
        );
        member = member.copyWith(
          photoPath: Value(uploadedPhoto),
          updatedAt: now,
        );
      }

      final firestoreDoc = firestoreMembers.docs
          .where((doc) => doc['uuid'] == member.uuid)
          .firstOrNull;

      if (firestoreDoc == null) {
        await _firebase.membersCollection(coopId).add(member.toJson());
      } else {
        final firestoreMember = FirestoreMember.fromFirestore(firestoreDoc);
        if (member.updatedAt.isAfter(firestoreMember.updatedAt)) {
          await firestoreDoc.reference.update(member.toJson());
        }
      }
    }
  }

  Future<void> syncDeposits() async {
    final coopId = _coopId!;
    final localDeposits = await _db.select(_db.deposits).get();
    var firestoreDeposits = await _firebase.depositsCollection(coopId).get();
    if (firestoreDeposits.docs.isEmpty && _isAdmin) {
      firestoreDeposits = await _pullLegacyDepositsIntoCoop(coopId);
    }

    for (final doc in firestoreDeposits.docs) {
      final firestoreDeposit = FirestoreDeposit.fromFirestore(doc);
      final localDeposit = localDeposits
          .where((d) => d.uuid == firestoreDeposit.uuid)
          .firstOrNull;

      if (localDeposit == null) {
        await _db.into(_db.deposits).insert(DepositsCompanion.insert(
          uuid: firestoreDeposit.uuid,
          memberUuid: firestoreDeposit.memberUuid,
          date: firestoreDeposit.date,
          monthKey: firestoreDeposit.monthKey,
          amount: firestoreDeposit.amount,
          reason: Value(firestoreDeposit.reason),
          method: firestoreDeposit.method,
          receivedBy: firestoreDeposit.receivedBy,
          receiptSerial: firestoreDeposit.receiptSerial,
          receiptPdfPath: Value(firestoreDeposit.receiptPdfPath),
          deletedAt: Value(firestoreDeposit.deletedAt),
          createdAt: firestoreDeposit.createdAt,
          updatedAt: firestoreDeposit.updatedAt,
        ));
      } else if (firestoreDeposit.updatedAt.isAfter(localDeposit.updatedAt)) {
        await _db.update(_db.deposits).replace(localDeposit.copyWith(
          memberUuid: firestoreDeposit.memberUuid,
          date: firestoreDeposit.date,
          monthKey: firestoreDeposit.monthKey,
          amount: firestoreDeposit.amount,
          reason: Value(firestoreDeposit.reason),
          method: firestoreDeposit.method,
          receivedBy: firestoreDeposit.receivedBy,
          receiptSerial: firestoreDeposit.receiptSerial,
          receiptPdfPath: Value(firestoreDeposit.receiptPdfPath),
          deletedAt: Value(firestoreDeposit.deletedAt),
          createdAt: firestoreDeposit.createdAt,
          updatedAt: firestoreDeposit.updatedAt,
        ));
      }
    }

    if (!_isAdmin && !await _memberCanCollectDeposits()) return;

    for (final localDeposit in localDeposits) {
      final firestoreDoc = firestoreDeposits.docs
          .where((doc) => doc['uuid'] == localDeposit.uuid)
          .firstOrNull;

      if (firestoreDoc == null) {
        await _firebase.depositsCollection(coopId).add(localDeposit.toJson());
      } else {
        final firestoreDeposit = FirestoreDeposit.fromFirestore(firestoreDoc);
        if (localDeposit.updatedAt.isAfter(firestoreDeposit.updatedAt)) {
          await firestoreDoc.reference.update(localDeposit.toJson());
        }
      }
    }
  }

  Future<void> syncOrganization() async {
    final coopId = _coopId!;
    await _db.ensureSchemaReady();
    final localOrg = await _db.select(_db.organization).getSingleOrNull();
    var coopDoc = await _firebase.cooperativeDoc(coopId).get();

    if (!coopDoc.exists && _isAdmin) {
      final legacyOrgs = await _firebase.legacyOrganizationsCollection.get();
      final metaDoc = await _firebase.legacyCooperativeMetaDoc.get();
      if (legacyOrgs.docs.isNotEmpty || metaDoc.exists) {
        final od = legacyOrgs.docs.isNotEmpty
            ? legacyOrgs.docs.first.data()
            : <String, dynamic>{};
        final meta = metaDoc.data() ?? <String, dynamic>{};
        await _firebase.cooperativeDoc(coopId).set({
          'name': od['name'] ?? meta['organizationName'] ?? 'My Cooperative',
          'address': od['address'] ?? '',
          'migratedFromLegacy': true,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
        coopDoc = await _firebase.cooperativeDoc(coopId).get();
      }
    }

    if (coopDoc.exists) {
      final firestoreOrg = FirestoreOrganization.fromFirestore(coopDoc);
      final shouldPullFromServer = !_isAdmin ||
          localOrg == null ||
          _isPlaceholderOrg(localOrg) ||
          firestoreOrg.updatedAt.isAfter(localOrg.updatedAt);

      if (shouldPullFromServer) {
        await _applyFirestoreOrganization(localOrg, firestoreOrg);
      } else if (localOrg.updatedAt.isAfter(firestoreOrg.updatedAt) && _isAdmin) {
        final pushedOrg = await _prepareOrganizationImagesForSync(coopId, localOrg);
        await coopDoc.reference.update(pushedOrg.toJson());
      }
    } else if (localOrg != null && _isAdmin) {
      final pushedOrg = await _prepareOrganizationImagesForSync(coopId, localOrg);
      await _firebase.cooperativeDoc(coopId).set(pushedOrg.toJson());
    }
  }

  Future<OrganizationData> _prepareOrganizationImagesForSync(
    String coopId,
    OrganizationData org,
  ) async {
    final logo = await _orgImageStorage.uploadLogo(
      coopId: coopId,
      path: org.logoPath,
    );
    final signature = await _orgImageStorage.uploadSignature(
      coopId: coopId,
      path: org.signaturePath,
    );
    if (logo == org.logoPath && signature == org.signaturePath) {
      return org;
    }

    final now = DateTime.now();
    await (_db.update(_db.organization)..where((o) => o.id.equals(org.id))).write(
      OrganizationCompanion(
        logoPath: Value(logo),
        signaturePath: Value(signature),
        updatedAt: Value(now),
      ),
    );
    return org.copyWith(
      logoPath: Value(logo),
      signaturePath: Value(signature),
      updatedAt: now,
    );
  }

  Future<void> syncSettings() async {
    final coopId = _coopId!;
    final localSettings = await _db.select(_db.settings).getSingleOrNull();
    var settingsDoc = await _firebase.settingsDoc(coopId).get();

    if (!settingsDoc.exists && _isAdmin) {
      final legacySettings = await _firebase.legacySettingsCollection.get();
      if (legacySettings.docs.isNotEmpty) {
        await _firebase
            .settingsDoc(coopId)
            .set(legacySettings.docs.first.data(), SetOptions(merge: true));
        settingsDoc = await _firebase.settingsDoc(coopId).get();
      }
    }

    if (settingsDoc.exists) {
      final firestoreSetting = FirestoreSettings.fromFirestore(settingsDoc);
      final shouldPullFromServer = !_isAdmin ||
          localSettings == null ||
          firestoreSetting.updatedAt.isAfter(localSettings.updatedAt);

      if (shouldPullFromServer) {
        await _applyFirestoreSettings(
          localSettings,
          firestoreSetting,
          coopId,
          preserveDevicePrefs: !_isAdmin,
        );
      } else if (localSettings.updatedAt.isAfter(firestoreSetting.updatedAt) &&
          _isAdmin) {
        await settingsDoc.reference.update(localSettings.toJson());
      }
    } else if (localSettings != null && _isAdmin) {
      await _firebase.settingsDoc(coopId).set(localSettings.toJson());
    }
  }

  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) {
      if (_canSync) syncAll();
    });
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Listen to Firestore changes and refresh local Drift cache.
  void startRealtimeSync() {
    stopRealtimeSync();
    final coopId = _coopId;
    if (coopId == null || !_firebase.isAuthenticated) return;

    _realtimeSubscriptions.add(
      _firebase.cooperativeDoc(coopId).snapshots().listen(
        (_) => _scheduleSyncAll(),
        onError: (e) => debugPrint('Org realtime sync error: $e'),
      ),
    );
    _realtimeSubscriptions.add(
      _firebase.settingsDoc(coopId).snapshots().listen(
        (_) => _scheduleSyncAll(),
        onError: (e) => debugPrint('Settings realtime sync error: $e'),
      ),
    );
    _realtimeSubscriptions.add(
      _firebase.membersCollection(coopId).snapshots().listen(
        (_) => _scheduleSyncAll(),
        onError: (e) => debugPrint('Members realtime sync error: $e'),
      ),
    );
    _realtimeSubscriptions.add(
      _firebase.depositsCollection(coopId).snapshots().listen(
        (_) => _scheduleSyncAll(),
        onError: (e) => debugPrint('Deposits realtime sync error: $e'),
      ),
    );
  }

  void stopRealtimeSync() {
    for (final sub in _realtimeSubscriptions) {
      sub.cancel();
    }
    _realtimeSubscriptions.clear();
    _syncDebounce?.cancel();
    _syncDebounce = null;
  }

  Future<void> forceSync() => syncAll();

  Future<void> _ensureLegacyFirestoreCopied(String coopId) async {
    try {
      final coopMembers =
          await _firebase.membersCollection(coopId).limit(1).get();
      if (coopMembers.docs.isNotEmpty) return;

      final legacyMembers =
          await _firebase.legacyMembersCollection.limit(1).get();
      if (legacyMembers.docs.isEmpty) return;

      debugPrint('Sync: copying legacy Firestore data into coop $coopId');
      await _pullLegacyMembersIntoCoop(coopId);
      await _pullLegacyDepositsIntoCoop(coopId);

      final legacySettings = await _firebase.legacySettingsCollection.get();
      if (legacySettings.docs.isNotEmpty) {
        await _firebase
            .settingsDoc(coopId)
            .set(legacySettings.docs.first.data(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Legacy Firestore copy during sync failed: $e');
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _pullLegacyMembersIntoCoop(
    String coopId,
  ) async {
    final legacy = await _firebase.legacyMembersCollection.get();
    for (final doc in legacy.docs) {
      await _firebase
          .membersCollection(coopId)
          .doc(doc.id)
          .set(doc.data(), SetOptions(merge: true));
    }
    return _firebase.membersCollection(coopId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _pullLegacyDepositsIntoCoop(
    String coopId,
  ) async {
    final legacy = await _firebase.legacyDepositsCollection.get();
    for (final doc in legacy.docs) {
      await _firebase
          .depositsCollection(coopId)
          .doc(doc.id)
          .set(doc.data(), SetOptions(merge: true));
    }
    return _firebase.depositsCollection(coopId).get();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    stopPeriodicSync();
    stopRealtimeSync();
    _syncStatusController.close();
  }

  Future<void> _notifyNewMemberDeposits(Set<String> knownBefore) async {
    if (kIsWeb || !_session.isMember || _session.memberUuid == null) return;

    final deposits = await (_db.select(_db.deposits)
          ..where(
            (d) =>
                d.memberUuid.equals(_session.memberUuid!) &
                d.deletedAt.isNull(),
          ))
        .get();

    for (final d in deposits) {
      if (knownBefore.contains(d.uuid)) continue;
      await NotificationService.instance.showDepositRecorded(
        amount: d.amount,
        receiptSerial: d.receiptSerial,
      );
    }
  }

  Future<bool> _memberCanCollectDeposits() async {
    final memberUuid = _session.memberUuid;
    if (memberUuid == null) return false;
    final member = await (_db.select(_db.members)
          ..where((m) => m.uuid.equals(memberUuid)))
        .getSingleOrNull();
    return member?.canCollectDeposits ?? false;
  }

  Future<void> _pushOwnMemberRecord(
    List<Member> localMembers,
    QuerySnapshot<Map<String, dynamic>> firestoreMembers,
  ) async {
    final coopId = _coopId!;
    final memberUuid = _session.memberUuid;
    if (memberUuid == null) return;

    var member = localMembers.where((m) => m.uuid == memberUuid).firstOrNull;
    if (member == null) return;
    final uuid = member.uuid;

    final uploadedPhoto = await _photoStorage.uploadIfLocal(
      coopId: coopId,
      memberUuid: uuid,
      photoPath: member.photoPath,
    );
    if (uploadedPhoto != null && uploadedPhoto != member.photoPath) {
      final now = DateTime.now();
      await (_db.update(_db.members)..where((m) => m.uuid.equals(uuid)))
          .write(
        MembersCompanion(
          photoPath: Value(uploadedPhoto),
          updatedAt: Value(now),
        ),
      );
      member = member.copyWith(
        photoPath: Value(uploadedPhoto),
        updatedAt: now,
      );
    }

    final firestoreDoc = firestoreMembers.docs
        .where((doc) => doc['uuid'] == memberUuid)
        .firstOrNull;
    if (firestoreDoc == null) return;

    final firestoreMember = FirestoreMember.fromFirestore(firestoreDoc);
    if (member.updatedAt.isAfter(firestoreMember.updatedAt)) {
      await firestoreDoc.reference.update(member.toJson());
    }
  }
}

enum SyncStatus {
  offline,
  connecting,
  syncing,
  synced,
  error,
}

extension MemberExtension on Member {
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'memberIdNumber': memberIdNumber,
      'name': name,
      'phone': phone,
      'phoneNormalized': phoneNormalized,
      if (pinHash != null) 'pinHash': pinHash,
      'address': address,
      'nidNumber': nidNumber,
      'photoPath': photoPath,
      'monthlyAmount': monthlyAmount,
      'isActive': isActive,
      'canCollectDeposits': canCollectDeposits,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

extension DepositExtension on Deposit {
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'memberUuid': memberUuid,
      'date': date.toIso8601String(),
      'monthKey': monthKey,
      'amount': amount,
      'reason': reason,
      'method': method,
      'receivedBy': receivedBy,
      'receiptSerial': receiptSerial,
      'receiptPdfPath': receiptPdfPath,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

extension OrganizationExtension on OrganizationData {
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (shortName != null && shortName!.isNotEmpty) 'shortName': shortName,
      'address': address,
      'logoPath': logoPath,
      'signaturePath': signaturePath,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

extension SettingsExtension on SettingsData {
  Map<String, dynamic> toJson() {
    return {
      'defaultReceivedBy': defaultReceivedBy,
      'receiptPrefix': receiptPrefix,
      'nextReceiptSerial': nextReceiptSerial,
      'language': language,
      'themeMode': themeMode,
      'defaultMemberPassword': defaultMemberPassword,
      'memberShowCoopTotalCollection': memberShowCoopTotalCollection,
      'memberShowCoopTotalDue': memberShowCoopTotalDue,
      'memberShowDueMembersList': memberShowDueMembersList,
      'memberShowCoopCurrentMonth': memberShowCoopCurrentMonth,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
