import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_provider.dart';
import '../../core/db/app_db.dart';
import '../../core/firebase/member_photo_storage.dart';
import '../../core/firebase/organization_image_storage.dart';
import '../../core/firebase_providers.dart';
import 'coop_data_repository.dart';
import 'firestore_coop_repository.dart';
import 'backup_import_result.dart';

/// Firestore reads/writes with image encoding (all platforms; no local sync).
class WebCoopRepository implements CoopDataRepository {
  final FirestoreCoopRepository _inner;
  final MemberPhotoStorage _photoStorage;
  final OrganizationImageStorage _orgImageStorage;
  final Ref _ref;

  WebCoopRepository(
    this._ref, [
    MemberPhotoStorage? photoStorage,
    OrganizationImageStorage? orgImageStorage,
  ])  : _inner = FirestoreCoopRepository(
          _ref,
          _ref.read(firebaseServiceProvider),
        ),
        _photoStorage = photoStorage ?? MemberPhotoStorage(),
        _orgImageStorage = orgImageStorage ?? OrganizationImageStorage();

  String? get _coopId => _ref.read(authSessionProvider).coopId;

  Stream<OrganizationData> watchOrganization() => _inner.watchOrganization();
  Stream<SettingsData> watchSettings() => _inner.watchSettings();
  Future<SettingsData> getSettings() => _inner.getSettings();
  Future<int> generateReceiptSerialFromDateTime(DateTime dateTime) =>
      _inner.generateReceiptSerialFromDateTime(dateTime);
  Future<int> nextReceiptSerialAndIncrement() =>
      _inner.nextReceiptSerialAndIncrement();

  Future<void> updateOrganization({
    required String name,
    required String address,
    String? shortName,
    String? logoPath,
    String? signaturePath,
  }) async {
    final coopId = _coopId;
    var resolvedLogo = logoPath;
    var resolvedSignature = signaturePath;
    if (coopId != null && coopId.isNotEmpty) {
      resolvedLogo = await _orgImageStorage.uploadLogo(
        coopId: coopId,
        path: logoPath,
      );
      resolvedSignature = await _orgImageStorage.uploadSignature(
        coopId: coopId,
        path: signaturePath,
      );
    }
    await _inner.updateOrganization(
      name: name,
      address: address,
      shortName: shortName,
      logoPath: resolvedLogo,
      signaturePath: resolvedSignature,
    );
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
  }) =>
      _inner.updateSettings(
        defaultReceivedBy: defaultReceivedBy,
        receiptPrefix: receiptPrefix,
        language: language,
        defaultMemberPassword: defaultMemberPassword,
        memberShowCoopTotalCollection: memberShowCoopTotalCollection,
        memberShowCoopTotalDue: memberShowCoopTotalDue,
        memberShowDueMembersList: memberShowDueMembersList,
        memberShowCoopCurrentMonth: memberShowCoopCurrentMonth,
      );

  Future<void> updateLanguage(String language) =>
      _inner.updateLanguage(language);
  Future<void> updateThemeMode(String themeMode) =>
      _inner.updateThemeMode(themeMode);

  Stream<List<Member>> watchActiveMembers({String? query}) =>
      _inner.watchActiveMembers(query: query);
  Stream<List<Member>> watchTrashedMembers() => _inner.watchTrashedMembers();
  Future<Member?> getMemberByUuid(String uuid) =>
      _inner.getMemberByUuid(uuid);
  Future<Member?> getMemberByPhoneNormalized(String phoneNormalized) =>
      _inner.getMemberByPhoneNormalized(phoneNormalized);
  Future<bool> isPhoneTaken(String phoneNormalized, {String? excludeUuid}) =>
      _inner.isPhoneTaken(phoneNormalized, excludeUuid: excludeUuid);

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
    final resolvedPhoto = await _resolveMemberPhoto(uuid, photoPath);
    await _inner.addMember(
      uuid: uuid,
      memberIdNumber: memberIdNumber,
      name: name,
      phone: phone,
      phoneNormalized: phoneNormalized,
      address: address,
      nidNumber: nidNumber,
      photoPath: resolvedPhoto,
      monthlyAmount: monthlyAmount,
      canCollectDeposits: canCollectDeposits,
    );
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
    final resolvedPhoto = await _resolveMemberPhoto(uuid, photoPath);
    await _inner.updateMember(
      uuid: uuid,
      memberIdNumber: memberIdNumber,
      name: name,
      phone: phone,
      phoneNormalized: phoneNormalized,
      address: address,
      nidNumber: nidNumber,
      photoPath: resolvedPhoto,
      monthlyAmount: monthlyAmount,
      canCollectDeposits: canCollectDeposits,
    );
  }

  Future<String?> _resolveMemberPhoto(String memberUuid, String? photoPath) async {
    final coopId = _coopId;
    if (coopId == null || coopId.isEmpty) return photoPath;
    return _photoStorage.uploadIfLocal(
      coopId: coopId,
      memberUuid: memberUuid,
      photoPath: photoPath,
    );
  }

  Future<void> softDeleteMember(String uuid) => _inner.softDeleteMember(uuid);
  Future<void> restoreMember(String uuid) => _inner.restoreMember(uuid);
  Future<void> permanentlyDeleteMember(String uuid) =>
      _inner.permanentlyDeleteMember(uuid);

  Stream<List<Deposit>> watchLastDeposits({int limit = 5}) =>
      _inner.watchLastDeposits(limit: limit);
  Stream<List<Deposit>> watchMemberDeposits(String memberUuid) =>
      _inner.watchMemberDeposits(memberUuid);
  Stream<List<Deposit>> watchRecentDepositsForMember(
    String memberUuid, {
    int limit = 5,
  }) =>
      _inner.watchRecentDepositsForMember(memberUuid, limit: limit);
  Stream<List<Deposit>> watchTrashedDeposits() => _inner.watchTrashedDeposits();
  Future<Deposit?> getDepositByUuid(String uuid) =>
      _inner.getDepositByUuid(uuid);
  Future<void> updateDepositReceiptPath(String depositUuid, String path) =>
      _inner.updateDepositReceiptPath(depositUuid, path);
  Future<List<String>> checkExistingDepositsForMonths({
    required String memberUuid,
    required List<String> monthKeys,
    String? excludeDepositUuid,
  }) =>
      _inner.checkExistingDepositsForMonths(
        memberUuid: memberUuid,
        monthKeys: monthKeys,
        excludeDepositUuid: excludeDepositUuid,
      );

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
  }) =>
      _inner.addDeposit(
        uuid: uuid,
        memberUuid: memberUuid,
        date: date,
        amount: amount,
        reason: reason,
        method: method,
        receivedBy: receivedBy,
        receiptSerial: receiptSerial,
        monthKeyOverride: monthKeyOverride,
      );

  Future<void> updateDeposit({
    required String uuid,
    DateTime? date,
    int? amount,
    String? reason,
    String? method,
    String? receivedBy,
    String? monthKeyOverride,
  }) =>
      _inner.updateDeposit(
        uuid: uuid,
        date: date,
        amount: amount,
        reason: reason,
        method: method,
        receivedBy: receivedBy,
        monthKeyOverride: monthKeyOverride,
      );

  Future<void> softDeleteDeposit(String uuid) => _inner.softDeleteDeposit(uuid);
  Future<void> restoreDeposit(String uuid) => _inner.restoreDeposit(uuid);
  Future<void> permanentlyDeleteDeposit(String uuid) =>
      _inner.permanentlyDeleteDeposit(uuid);

  Future<int> totalCollectionAllTime() => _inner.totalCollectionAllTime();
  Future<int> collectionForMonth(String mKey) => _inner.collectionForMonth(mKey);
  Future<Map<String, int>> collectionByMonth() => _inner.collectionByMonth();
  Future<int> collectionForYear(int year) => _inner.collectionForYear(year);
  Future<Map<String, int>> collectionByMonthForYear(int year) =>
      _inner.collectionByMonthForYear(year);
  Future<Map<String, dynamic>> dueSummaryAllMembers({
    required DateTime start,
    required DateTime endInclusive,
  }) =>
      _inner.dueSummaryAllMembers(start: start, endInclusive: endInclusive);
  Future<Map<String, dynamic>> dueForOneMember({
    required String memberUuid,
    required DateTime start,
    required DateTime endInclusive,
  }) =>
      _inner.dueForOneMember(
        memberUuid: memberUuid,
        start: start,
        endInclusive: endInclusive,
      );
  Future<List<Map<String, dynamic>>> getPaidMembersForMonth(String monthKey) =>
      _inner.getPaidMembersForMonth(monthKey);
  Future<List<Map<String, dynamic>>> getUnpaidMembersForMonth(String monthKey) =>
      _inner.getUnpaidMembersForMonth(monthKey);
  Future<List<Member>> getAllMembers({bool includeTrashed = false}) =>
      _inner.getAllMembers(includeTrashed: includeTrashed);
  Future<List<Deposit>> getAllDeposits({
    bool includeTrashed = false,
    String? memberUuid,
  }) =>
      _inner.getAllDeposits(
        includeTrashed: includeTrashed,
        memberUuid: memberUuid,
      );
  Future<String> exportToJson() => _inner.exportToJson();
  Future<BackupImportResult> importFromJson(String jsonData) =>
      _inner.importFromJson(jsonData);
}
