import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/db/app_db.dart';
import '../../core/firebase/firebase_service.dart';
import '../../core/firebase/models.dart';
import '../../core/utils/date_utils.dart';
import 'coop_calculations.dart';
import 'backup_codec.dart';
import 'backup_import_result.dart';
import 'firestore_mappers.dart';
import '../../core/utils/phone_utils.dart';

/// Web: reads and writes cooperative data directly in Firestore (no local sync).
class FirestoreCoopRepository {
  final Ref _ref;
  final FirebaseService _firebase;

  FirestoreCoopRepository(this._ref, this._firebase);

  String? get _coopId => _ref.read(authSessionProvider).coopId;
  bool get _isAdmin => _ref.read(authSessionProvider).isAdmin;

  void _requireCoopId() {
    if (_coopId == null) {
      throw StateError('Not signed in to a cooperative');
    }
  }

  // ---------- Device prefs (theme / language on web) ----------
  static const _prefLanguage = 'web_language';
  static const _prefThemeMode = 'web_theme_mode';

  Future<String?> _readPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _writePref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<SettingsData> _mergeDevicePrefs(FirestoreSettings fs) async {
    final lang = await _readPref(_prefLanguage);
    final theme = await _readPref(_prefThemeMode);
    return settingsFromFirestore(
      fs,
      tenantCoopId: _coopId,
      languageOverride: lang,
      themeModeOverride: theme,
    );
  }

  SettingsData _defaultSettings() {
    return SettingsData(
      id: 1,
      defaultReceivedBy: 'Admin',
      receiptPrefix: 'RCPT',
      nextReceiptSerial: 1,
      language: 'en',
      themeMode: 'system',
      defaultMemberPassword: '123456',
      memberShowCoopTotalCollection: true,
      memberShowCoopTotalDue: true,
      memberShowDueMembersList: true,
      memberShowCoopCurrentMonth: true,
      tenantCoopId: _coopId,
      updatedAt: DateTime.now(),
    );
  }

  // ---------- Organization / Settings ----------
  Stream<OrganizationData> watchOrganization() {
    _requireCoopId();
    final coopId = _coopId!;
    return _firebase.cooperativeDoc(coopId).snapshots().map((snap) {
      if (!snap.exists) {
        return OrganizationData(
          id: 1,
          name: '',
          address: '',
          updatedAt: DateTime.now(),
        );
      }
      return organizationFromFirestore(
        FirestoreOrganization.fromFirestore(snap),
      );
    });
  }

  Stream<SettingsData> watchSettings() {
    _requireCoopId();
    final coopId = _coopId!;
    return _firebase.settingsDoc(coopId).snapshots().asyncMap((snap) async {
      if (!snap.exists) {
        final lang = await _readPref(_prefLanguage);
        final theme = await _readPref(_prefThemeMode);
        return _defaultSettings().copyWith(
          language: lang ?? 'en',
          themeMode: theme ?? 'system',
        );
      }
      return _mergeDevicePrefs(FirestoreSettings.fromFirestore(snap));
    });
  }

  Future<SettingsData> getSettings() => watchSettings().first;

  Future<int> generateReceiptSerialFromDateTime(DateTime dateTime) async {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return int.parse('$year$month$day$hour$minute$second');
  }

  Future<int> nextReceiptSerialAndIncrement() =>
      generateReceiptSerialFromDateTime(DateTime.now());

  Future<void> updateOrganization({
    required String name,
    required String address,
    String? shortName,
    String? logoPath,
    String? signaturePath,
  }) async {
    _requireCoopId();
    final now = DateTime.now();
    await _firebase.cooperativeDoc(_coopId!).set({
      'name': name,
      'address': address,
      if (shortName != null && shortName.isNotEmpty) 'shortName': shortName,
      'logoPath': logoPath,
      'signaturePath': signaturePath,
      'updatedAt': now.toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> updateSettings({
    required String defaultReceivedBy,
    required String receiptPrefix,
    String? language,
    String? defaultMemberPassword,
    bool? memberShowCoopTotalCollection,
    bool? memberShowCoopTotalDue,
    bool? memberShowDueMembersList,
    bool? memberShowCoopCurrentMonth,
  }) async {
    _requireCoopId();
    if (!_isAdmin) return;
    final snap = await _firebase.settingsDoc(_coopId!).get();
    final existing = snap.exists
        ? FirestoreSettings.fromFirestore(snap)
        : FirestoreSettings(
            id: 'default',
            defaultReceivedBy: defaultReceivedBy,
            receiptPrefix: receiptPrefix,
            nextReceiptSerial: 1,
            language: 'en',
            themeMode: 'system',
            defaultMemberPassword: '123456',
            memberShowCoopTotalCollection: true,
            memberShowCoopTotalDue: true,
            memberShowDueMembersList: true,
            memberShowCoopCurrentMonth: true,
            updatedAt: DateTime.now(),
          );

    final updated = {
      'defaultReceivedBy': defaultReceivedBy,
      'receiptPrefix': receiptPrefix,
      'nextReceiptSerial': existing.nextReceiptSerial,
      'language': language ?? existing.language,
      'themeMode': existing.themeMode,
      'defaultMemberPassword':
          defaultMemberPassword ?? existing.defaultMemberPassword,
      'memberShowCoopTotalCollection': memberShowCoopTotalCollection ??
          existing.memberShowCoopTotalCollection,
      'memberShowCoopTotalDue':
          memberShowCoopTotalDue ?? existing.memberShowCoopTotalDue,
      'memberShowDueMembersList':
          memberShowDueMembersList ?? existing.memberShowDueMembersList,
      'memberShowCoopCurrentMonth': memberShowCoopCurrentMonth ??
          existing.memberShowCoopCurrentMonth,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _firebase.settingsDoc(_coopId!).set(updated, SetOptions(merge: true));
  }

  Future<void> updateLanguage(String language) async {
    await _writePref(_prefLanguage, language);
  }

  Future<void> updateThemeMode(String themeMode) async {
    await _writePref(_prefThemeMode, themeMode);
  }

  // ---------- Members ----------
  Stream<List<Member>> _membersStream({bool trashed = false}) {
    _requireCoopId();
    final coopId = _coopId!;
    Query<Map<String, dynamic>> query = _firebase.membersCollection(coopId);
    return query.snapshots().map((snap) {
      final list = snap.docs.map((d) => memberFromFirestore(
            FirestoreMember.fromFirestore(d),
          ));
      final filtered = list.where((m) {
        final isTrashed = m.deletedAt != null;
        return trashed ? isTrashed : m.deletedAt == null && m.isActive;
      }).toList();
      filtered.sort((a, b) => a.memberIdNumber.compareTo(b.memberIdNumber));
      return filtered;
    });
  }

  Stream<List<Member>> watchActiveMembers({String? query}) {
    final trimmed = query?.trim().toLowerCase();
    return _membersStream().map((members) {
      if (trimmed == null || trimmed.isEmpty) return members;
      return members
          .where((m) =>
              m.name.toLowerCase().contains(trimmed) ||
              m.memberIdNumber.toLowerCase().contains(trimmed) ||
              (m.phone ?? '').toLowerCase().contains(trimmed))
          .toList();
    });
  }

  Stream<List<Member>> watchTrashedMembers() => _membersStream(trashed: true);

  Future<List<Member>> _fetchAllMembers({bool includeTrashed = true}) async {
    _requireCoopId();
    Query<Map<String, dynamic>> query =
        _firebase.membersCollection(_coopId!);
    final snap = await query.get();
    return snap.docs
        .map((d) => memberFromFirestore(FirestoreMember.fromFirestore(d)))
        .where((m) => includeTrashed || m.deletedAt == null)
        .toList();
  }

  Future<List<Member>> getAllMembers({bool includeTrashed = false}) async {
    return _fetchAllMembers(includeTrashed: includeTrashed);
  }

  Future<List<Deposit>> getAllDeposits({
    bool includeTrashed = false,
    String? memberUuid,
  }) async {
    _requireCoopId();
    Query<Map<String, dynamic>> query =
        _firebase.depositsCollection(_coopId!);
    if (memberUuid != null) {
      query = query.where('memberUuid', isEqualTo: memberUuid);
    }
    final snap = await query.get();
    final list = snap.docs
        .map((d) => depositFromFirestore(FirestoreDeposit.fromFirestore(d)))
        .where((d) => includeTrashed || d.deletedAt == null)
        .toList();
    return list;
  }

  Future<Member?> getMemberByUuid(String uuid) async {
    _requireCoopId();
    final snap = await _firebase
        .membersCollection(_coopId!)
        .where('uuid', isEqualTo: uuid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return memberFromFirestore(FirestoreMember.fromFirestore(snap.docs.first));
  }

  Future<Member?> getMemberByPhoneNormalized(String phoneNormalized) async {
    _requireCoopId();
    final snap = await _firebase
        .membersCollection(_coopId!)
        .where('phoneNormalized', isEqualTo: phoneNormalized)
        .limit(5)
        .get();
    for (final doc in snap.docs) {
      final m = memberFromFirestore(FirestoreMember.fromFirestore(doc));
      if (m.deletedAt == null) return m;
    }
    return null;
  }

  Future<bool> isPhoneTaken(String phoneNormalized, {String? excludeUuid}) async {
    final m = await getMemberByPhoneNormalized(phoneNormalized);
    if (m == null) return false;
    if (excludeUuid != null && m.uuid == excludeUuid) return false;
    return true;
  }

  Future<DocumentReference<Map<String, dynamic>>?> _memberDocByUuid(
    String uuid,
  ) async {
    _requireCoopId();
    final snap = await _firebase
        .membersCollection(_coopId!)
        .where('uuid', isEqualTo: uuid)
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first.reference;
  }

  Future<void> addMember({
    required String uuid,
    required String memberIdNumber,
    required String name,
    String? phone,
    String? phoneNormalized,
    String? address,
    String? nidNumber,
    String? photoPath,
    required int monthlyAmount,
    bool canCollectDeposits = false,
  }) async {
    _requireCoopId();
    if (!_isAdmin) return;
    final now = DateTime.now();
    await _firebase.membersCollection(_coopId!).add({
      'uuid': uuid,
      'memberIdNumber': memberIdNumber,
      'name': name,
      'phone': phone,
      'phoneNormalized': phoneNormalized,
      'address': address,
      'nidNumber': nidNumber,
      'photoPath': photoPath,
      'monthlyAmount': monthlyAmount,
      'isActive': true,
      'canCollectDeposits': canCollectDeposits,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> updateMember({
    required String uuid,
    String? memberIdNumber,
    String? name,
    String? phone,
    String? phoneNormalized,
    String? address,
    String? nidNumber,
    String? photoPath,
    int? monthlyAmount,
    bool? canCollectDeposits,
  }) async {
    final ref = await _memberDocByUuid(uuid);
    if (ref == null) return;
    final now = DateTime.now();
    final data = <String, dynamic>{'updatedAt': now.toIso8601String()};
    if (memberIdNumber != null) data['memberIdNumber'] = memberIdNumber;
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (phoneNormalized != null) data['phoneNormalized'] = phoneNormalized;
    if (address != null) data['address'] = address;
    if (nidNumber != null) data['nidNumber'] = nidNumber;
    if (photoPath != null) data['photoPath'] = photoPath;
    if (monthlyAmount != null) data['monthlyAmount'] = monthlyAmount;
    if (canCollectDeposits != null) {
      data['canCollectDeposits'] = canCollectDeposits;
    }
    await ref.update(data);
  }

  Future<void> softDeleteMember(String uuid) async {
    final ref = await _memberDocByUuid(uuid);
    if (ref == null) return;
    final now = DateTime.now();
    await ref.update({
      'deletedAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> restoreMember(String uuid) async {
    final ref = await _memberDocByUuid(uuid);
    if (ref == null) return;
    final now = DateTime.now();
    await ref.update({
      'deletedAt': null,
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> permanentlyDeleteMember(String uuid) async {
    final ref = await _memberDocByUuid(uuid);
    if (ref == null) return;
    final deposits = await _firebase
        .depositsCollection(_coopId!)
        .where('memberUuid', isEqualTo: uuid)
        .get();
    for (final d in deposits.docs) {
      await d.reference.delete();
    }
    await ref.delete();
  }

  // ---------- Deposits ----------
  Stream<List<Deposit>> _depositsStream({String? memberUuid, bool trashed = false}) {
    _requireCoopId();
    final coopId = _coopId!;
    Query<Map<String, dynamic>> query = _firebase.depositsCollection(coopId);
    if (memberUuid != null) {
      query = query.where('memberUuid', isEqualTo: memberUuid);
    }
    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => depositFromFirestore(FirestoreDeposit.fromFirestore(d)))
          .where((d) => trashed ? d.deletedAt != null : d.deletedAt == null)
          .toList()
        ..sort((a, b) {
          final byDate = b.date.compareTo(a.date);
          return byDate != 0 ? byDate : b.uuid.compareTo(a.uuid);
        });
      return list;
    });
  }

  Future<List<Deposit>> _fetchAllDeposits({String? memberUuid}) async {
    return getAllDeposits(includeTrashed: false, memberUuid: memberUuid);
  }

  Stream<List<Deposit>> watchLastDeposits({int limit = 5}) {
    return _depositsStream().map((d) => d.take(limit).toList());
  }

  Stream<List<Deposit>> watchMemberDeposits(String memberUuid) =>
      _depositsStream(memberUuid: memberUuid);

  Stream<List<Deposit>> watchRecentDepositsForMember(
    String memberUuid, {
    int limit = 5,
  }) =>
      watchMemberDeposits(memberUuid).map((d) => d.take(limit).toList());

  Stream<List<Deposit>> watchTrashedDeposits() =>
      _depositsStream(trashed: true);

  Future<Deposit?> getDepositByUuid(String uuid) async {
    _requireCoopId();
    final snap = await _firebase
        .depositsCollection(_coopId!)
        .where('uuid', isEqualTo: uuid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return depositFromFirestore(FirestoreDeposit.fromFirestore(snap.docs.first));
  }

  Future<DocumentReference<Map<String, dynamic>>?> _depositDocByUuid(
    String uuid,
  ) async {
    _requireCoopId();
    final snap = await _firebase
        .depositsCollection(_coopId!)
        .where('uuid', isEqualTo: uuid)
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first.reference;
  }

  Future<void> updateDepositReceiptPath(String depositUuid, String path) async {
    final ref = await _depositDocByUuid(depositUuid);
    if (ref == null) return;
    await ref.update({
      'receiptPdfPath': path,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<String>> checkExistingDepositsForMonths({
    required String memberUuid,
    required List<String> monthKeys,
    String? excludeDepositUuid,
  }) async {
    if (monthKeys.isEmpty) return [];
    final deposits = await _fetchAllDeposits(memberUuid: memberUuid);
    final filtered = excludeDepositUuid != null
        ? deposits.where((d) => d.uuid != excludeDepositUuid)
        : deposits;

    final existing = <String>{};
    for (final d in filtered) {
      existing.addAll(parseDepositMonths(d.reason, d.monthKey));
    }
    return monthKeys.where(existing.contains).toList();
  }

  Future<void> addDeposit({
    required String uuid,
    required String memberUuid,
    required DateTime date,
    required int amount,
    String? reason,
    required String method,
    required String receivedBy,
    required int receiptSerial,
    String? monthKeyOverride,
  }) async {
    _requireCoopId();
    if (!_isAdmin) return;
    final now = DateTime.now();
    final resolvedMonthKey = monthKeyOverride ?? monthKey(date);
    await _firebase.depositsCollection(_coopId!).add({
      'uuid': uuid,
      'memberUuid': memberUuid,
      'date': date.toIso8601String(),
      'monthKey': resolvedMonthKey,
      'amount': amount,
      'reason': reason,
      'method': method,
      'receivedBy': receivedBy,
      'receiptSerial': receiptSerial,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> updateDeposit({
    required String uuid,
    DateTime? date,
    int? amount,
    String? reason,
    String? method,
    String? receivedBy,
    String? monthKeyOverride,
  }) async {
    final ref = await _depositDocByUuid(uuid);
    if (ref == null) return;
    final data = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (date != null) {
      data['date'] = date.toIso8601String();
      data['monthKey'] = monthKeyOverride ?? monthKey(date);
    } else if (monthKeyOverride != null) {
      data['monthKey'] = monthKeyOverride;
    }
    if (amount != null) data['amount'] = amount;
    if (reason != null) data['reason'] = reason;
    if (method != null) data['method'] = method;
    if (receivedBy != null) data['receivedBy'] = receivedBy;
    await ref.update(data);
  }

  Future<void> softDeleteDeposit(String uuid) async {
    final ref = await _depositDocByUuid(uuid);
    if (ref == null) return;
    final now = DateTime.now();
    await ref.update({
      'deletedAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> restoreDeposit(String uuid) async {
    final ref = await _depositDocByUuid(uuid);
    if (ref == null) return;
    await ref.update({
      'deletedAt': null,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> permanentlyDeleteDeposit(String uuid) async {
    final ref = await _depositDocByUuid(uuid);
    if (ref == null) return;
    await ref.delete();
  }

  // ---------- Reports ----------
  Future<int> totalCollectionAllTime() async {
    final deposits = await _fetchAllDeposits();
    return totalCollectionFromDeposits(deposits);
  }

  Future<int> collectionForMonth(String mKey) async {
    final deposits = await _fetchAllDeposits();
    return collectionForMonthFromDeposits(deposits, mKey);
  }

  Future<Map<String, int>> collectionByMonth() async {
    final deposits = await _fetchAllDeposits();
    return collectionByMonthFromDeposits(deposits);
  }

  Future<int> collectionForYear(int year) async {
    final map = await collectionByMonthForYear(year);
    return map.values.fold<int>(0, (a, b) => a + b);
  }

  Future<Map<String, int>> collectionByMonthForYear(int year) async {
    final deposits = await _fetchAllDeposits();
    return collectionByMonthForYearFromDeposits(deposits, year);
  }

  Future<Map<String, dynamic>> dueSummaryAllMembers({
    required DateTime start,
    required DateTime endInclusive,
  }) async {
    final members = await _fetchAllMembers(includeTrashed: false);
    final deposits = await _fetchAllDeposits();
    return dueSummaryFromData(
      members: members,
      deposits: deposits,
      start: start,
      endInclusive: endInclusive,
    );
  }

  Future<Map<String, dynamic>> dueForOneMember({
    required String memberUuid,
    required DateTime start,
    required DateTime endInclusive,
  }) async {
    final member = await getMemberByUuid(memberUuid);
    if (member == null) {
      return {'totalDue': 0, 'dueMonths': <String, int>{}};
    }
    final deposits = await _fetchAllDeposits(memberUuid: memberUuid);
    return dueForOneMemberFromData(
      member: member,
      deposits: deposits,
      start: start,
      endInclusive: endInclusive,
    );
  }

  Future<List<Map<String, dynamic>>> getPaidMembersForMonth(
    String monthKey,
  ) async {
    final members = await _fetchAllMembers(includeTrashed: false);
    final deposits = await _fetchAllDeposits();
    final result = <Map<String, dynamic>>[];
    for (final m in members) {
      final paid = collectionForMonthFromDeposits(
        deposits.where((d) => d.memberUuid == m.uuid).toList(),
        monthKey,
      );
      result.add({
        'member': m,
        'paid': paid,
        'expected': m.monthlyAmount,
      });
    }
    return result.where((r) => (r['paid'] as int) > 0).toList();
  }

  Future<List<Map<String, dynamic>>> getUnpaidMembersForMonth(
    String monthKey,
  ) async {
    final members = await _fetchAllMembers(includeTrashed: false);
    final deposits = await _fetchAllDeposits();
    final result = <Map<String, dynamic>>[];
    for (final m in members) {
      final paid = collectionForMonthFromDeposits(
        deposits.where((d) => d.memberUuid == m.uuid).toList(),
        monthKey,
      );
      final due = m.monthlyAmount - paid;
      if (due > 0) {
        result.add({
          'member': m,
          'paid': paid,
          'expected': m.monthlyAmount,
          'due': due,
        });
      }
    }
    return result;
  }

  Future<String> exportToJson() async {
    _requireCoopId();
    if (!_isAdmin) {
      throw StateError('Only admins can export backups');
    }
    final org = await watchOrganization().first;
    final settings = await getSettings();
    final members = await getAllMembers(includeTrashed: true);
    final deposits = await getAllDeposits(includeTrashed: true);
    return BackupCodec.encode(
      org: org,
      settings: settings,
      members: members,
      deposits: deposits,
    );
  }

  Future<BackupImportResult> importFromJson(String jsonData) async {
    _requireCoopId();
    if (!_isAdmin) {
      throw StateError('Only admins can import backups');
    }

    final backupData = BackupCodec.decode(jsonData);
    final stats = <String, int>{
      'members': 0,
      'membersMerged': 0,
      'deposits': 0,
      'depositsMerged': 0,
      'membersFailed': 0,
      'depositsFailed': 0,
      'loginsProvisioned': 0,
      'loginsFailed': 0,
      'loginsSkipped': 0,
    };
    final membersToProvision = <({String uuid, String? phoneNormalized})>[];

    if (backupData.containsKey('organization')) {
      await _importOrganization(
        backupData['organization'] as Map<String, dynamic>,
      );
    }

    if (backupData.containsKey('settings')) {
      await _importSettings(backupData['settings'] as Map<String, dynamic>);
    }

    if (backupData.containsKey('members')) {
      final membersList = backupData['members'] as List<dynamic>;
      for (final memberData in membersList) {
        final m = memberData as Map<String, dynamic>;
        final uuid = m['uuid'] as String;
        final phone = m['phone'] as String?;
        final loginPhone = PhoneUtils.resolveMemberLoginPhone(
          phone,
          m['phoneNormalized'] as String?,
        );
        final phoneNormalized =
            await _phoneNormalizedForImport(uuid, loginPhone);

        membersToProvision.add((uuid: uuid, phoneNormalized: loginPhone));

        final existing = await getMemberByUuid(uuid);
        final saved = await _upsertMemberFromBackup(
          m: m,
          uuid: uuid,
          phone: phone,
          phoneNormalized: phoneNormalized,
          existing: existing != null,
        );
        if (saved == _UpsertResult.inserted) {
          stats['members'] = stats['members']! + 1;
        } else if (saved == _UpsertResult.merged) {
          stats['membersMerged'] = stats['membersMerged']! + 1;
        } else {
          stats['membersFailed'] = stats['membersFailed']! + 1;
        }
      }
    }

    if (backupData.containsKey('deposits')) {
      final depositsList = backupData['deposits'] as List<dynamic>;
      final newDeposits = <Map<String, dynamic>>[];
      final depositsToMerge = <Map<String, dynamic>>[];

      for (final depositData in depositsList) {
        final d = depositData as Map<String, dynamic>;
        final uuid = d['uuid'] as String;
        final existing = await getDepositByUuid(uuid);
        final payload = _depositPayloadFromBackup(d, uuid);
        if (existing != null) {
          depositsToMerge.add(payload);
        } else {
          newDeposits.add(payload);
        }
      }

      try {
        stats['deposits'] = await _batchInsertDocuments(
          _firebase.depositsCollection(_coopId!),
          newDeposits,
        );
      } catch (e) {
        debugPrint('Batch deposit import failed: $e');
        stats['depositsFailed'] =
            (stats['depositsFailed'] ?? 0) + newDeposits.length;
      }

      for (final payload in depositsToMerge) {
        final uuid = payload['uuid'] as String;
        final saved = await _upsertDepositFromBackup(
          d: payload,
          uuid: uuid,
          existing: true,
        );
        if (saved == _UpsertResult.merged) {
          stats['depositsMerged'] = stats['depositsMerged']! + 1;
        } else {
          stats['depositsFailed'] = stats['depositsFailed']! + 1;
        }
      }
    }

    return BackupImportResult(
      stats: stats,
      membersToProvision: membersToProvision,
    );
  }

  Future<void> _importOrganization(Map<String, dynamic> orgData) async {
    await updateOrganization(
      name: orgData['name'] as String,
      address: orgData['address'] as String,
      shortName: orgData['shortName'] as String?,
      logoPath: orgData['logoPath'] as String?,
      signaturePath: orgData['signaturePath'] as String?,
    );
  }

  Future<void> _importSettings(Map<String, dynamic> settingsData) async {
    final language = settingsData['language'] as String? ?? 'en';
    final themeMode = settingsData['themeMode'] as String? ?? 'system';
    await updateSettings(
      defaultReceivedBy: settingsData['defaultReceivedBy'] as String,
      receiptPrefix: settingsData['receiptPrefix'] as String,
      language: language,
      defaultMemberPassword: settingsData['defaultMemberPassword'] as String?,
      memberShowCoopTotalCollection:
          settingsData['memberShowCoopTotalCollection'] as bool?,
      memberShowCoopTotalDue: settingsData['memberShowCoopTotalDue'] as bool?,
      memberShowDueMembersList:
          settingsData['memberShowDueMembersList'] as bool?,
      memberShowCoopCurrentMonth:
          settingsData['memberShowCoopCurrentMonth'] as bool?,
    );
    await updateLanguage(language);
    await updateThemeMode(themeMode);
    await _firebase.settingsDoc(_coopId!).set({
      'nextReceiptSerial': BackupCodec.asInt(settingsData['nextReceiptSerial']),
      'themeMode': themeMode,
      'updatedAt': DateTime.parse(settingsData['updatedAt'] as String)
          .toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<String?> _phoneNormalizedForImport(
    String uuid,
    String? resolved,
  ) async {
    if (resolved == null) return null;
    if (await isPhoneTaken(resolved, excludeUuid: uuid)) {
      debugPrint(
        'Phone $resolved already used; importing member $uuid without normalized phone',
      );
      return null;
    }
    return resolved;
  }

  Future<_UpsertResult> _upsertMemberFromBackup({
    required Map<String, dynamic> m,
    required String uuid,
    required String? phone,
    required String? phoneNormalized,
    required bool existing,
  }) async {
    final data = <String, dynamic>{
      'uuid': uuid,
      'memberIdNumber': m['memberIdNumber'] as String,
      'name': m['name'] as String,
      'phone': phone,
      'phoneNormalized': phoneNormalized,
      'address': m['address'],
      'nidNumber': m['nidNumber'],
      'photoPath': m['photoPath'],
      'monthlyAmount': BackupCodec.asInt(m['monthlyAmount']),
      'isActive': m['isActive'] as bool? ?? true,
      'canCollectDeposits': m['canCollectDeposits'] as bool? ?? false,
      'deletedAt': m['deletedAt'] != null
          ? DateTime.parse(m['deletedAt'] as String).toIso8601String()
          : null,
      'createdAt': DateTime.parse(m['createdAt'] as String).toIso8601String(),
      'updatedAt': DateTime.parse(m['updatedAt'] as String).toIso8601String(),
    };

    try {
      if (existing) {
        final ref = await _memberDocByUuid(uuid);
        if (ref == null) return _UpsertResult.failed;
        await ref.set(data, SetOptions(merge: true));
        return _UpsertResult.merged;
      }
      await _firebase.membersCollection(_coopId!).add(data);
      return _UpsertResult.inserted;
    } catch (e) {
      if (phoneNormalized != null) {
        try {
          data['phoneNormalized'] = null;
          if (existing) {
            final ref = await _memberDocByUuid(uuid);
            if (ref == null) return _UpsertResult.failed;
            await ref.set(data, SetOptions(merge: true));
            return _UpsertResult.merged;
          }
          await _firebase.membersCollection(_coopId!).add(data);
          return _UpsertResult.inserted;
        } catch (e2) {
          debugPrint('Failed to import member $uuid: $e2');
          return _UpsertResult.failed;
        }
      }
      debugPrint('Failed to import member $uuid: $e');
      return _UpsertResult.failed;
    }
  }

  Future<_UpsertResult> _upsertDepositFromBackup({
    required Map<String, dynamic> d,
    required String uuid,
    required bool existing,
  }) async {
    final data = _depositPayloadFromBackup(d, uuid);

    try {
      if (existing) {
        final ref = await _depositDocByUuid(uuid);
        if (ref == null) return _UpsertResult.failed;
        await ref.set(data, SetOptions(merge: true));
        return _UpsertResult.merged;
      }
      await _firebase.depositsCollection(_coopId!).add(data);
      return _UpsertResult.inserted;
    } catch (e) {
      debugPrint(
        'Failed to import deposit $uuid (member ${d['memberUuid']}): $e',
      );
      return _UpsertResult.failed;
    }
  }

  Map<String, dynamic> _depositPayloadFromBackup(
    Map<String, dynamic> d,
    String uuid,
  ) {
    return {
      'uuid': uuid,
      'memberUuid': d['memberUuid'] as String,
      'date': DateTime.parse(d['date'] as String).toIso8601String(),
      'monthKey': d['monthKey'] as String,
      'amount': BackupCodec.asInt(d['amount']),
      'reason': d['reason'],
      'method': d['method'] as String,
      'receivedBy': d['receivedBy'] as String,
      'receiptSerial': BackupCodec.asInt(d['receiptSerial']),
      'receiptPdfPath': d['receiptPdfPath'],
      'deletedAt': d['deletedAt'] != null
          ? DateTime.parse(d['deletedAt'] as String).toIso8601String()
          : null,
      'createdAt': DateTime.parse(d['createdAt'] as String).toIso8601String(),
      'updatedAt': DateTime.parse(d['updatedAt'] as String).toIso8601String(),
    };
  }

  static const _batchWriteLimit = 400;

  Future<int> _batchInsertDocuments(
    CollectionReference<Map<String, dynamic>> collection,
    List<Map<String, dynamic>> documents,
  ) async {
    if (documents.isEmpty) return 0;

    var inserted = 0;
    for (var start = 0; start < documents.length; start += _batchWriteLimit) {
      final batch = _firebase.firestore.batch();
      final end = start + _batchWriteLimit > documents.length
          ? documents.length
          : start + _batchWriteLimit;
      for (var i = start; i < end; i++) {
        batch.set(collection.doc(), documents[i]);
      }
      await batch.commit();
      inserted += end - start;
    }
    return inserted;
  }
}

enum _UpsertResult { inserted, merged, failed }
