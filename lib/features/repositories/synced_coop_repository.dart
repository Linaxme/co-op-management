import '../../core/db/app_db.dart';
import '../../core/firebase/member_photo_storage.dart';
import '../../core/firebase/organization_image_storage.dart';
import '../../core/firebase/sync_service.dart';
import 'coop_data_repository.dart';
import 'coop_repository.dart';
import 'backup_import_result.dart';

class SyncedCoopRepository implements CoopDataRepository {
  final CoopRepository _repository;
  final SyncService _syncService;
  final MemberPhotoStorage _photoStorage;
  final OrganizationImageStorage _orgImageStorage;

  SyncedCoopRepository(
    AppDb db,
    this._syncService, [
    MemberPhotoStorage? photoStorage,
    OrganizationImageStorage? orgImageStorage,
  ])  : _repository = CoopRepository(db),
        _photoStorage = photoStorage ?? MemberPhotoStorage(),
        _orgImageStorage = orgImageStorage ?? OrganizationImageStorage();

  // Delegate all methods to the original repository
  // but trigger sync for important operations

  // ---------- Organization / Settings ----------
  Stream<OrganizationData> watchOrganization() =>
      _repository.watchOrganization();

  Stream<SettingsData> watchSettings() => _repository.watchSettings();

  Future<SettingsData> getSettings() => _repository.getSettings();

  Future<int> generateReceiptSerialFromDateTime(DateTime dateTime) =>
      _repository.generateReceiptSerialFromDateTime(dateTime);

  Future<int> nextReceiptSerialAndIncrement() =>
      _repository.nextReceiptSerialAndIncrement();

  Future<void> updateOrganization({
    required String name,
    required String address,
    String? shortName,
    String? logoPath,
    String? signaturePath,
  }) async {
    final coopId = await _repository.db.getStoredTenantCoopId();
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
    await _repository.updateOrganization(
      name: name,
      address: address,
      shortName: shortName,
      logoPath: resolvedLogo,
      signaturePath: resolvedSignature,
    );
    _triggerSync();
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
    await _repository.updateSettings(
      defaultReceivedBy: defaultReceivedBy,
      receiptPrefix: receiptPrefix,
      language: language,
      defaultMemberPassword: defaultMemberPassword,
      memberShowCoopTotalCollection: memberShowCoopTotalCollection,
      memberShowCoopTotalDue: memberShowCoopTotalDue,
      memberShowDueMembersList: memberShowDueMembersList,
      memberShowCoopCurrentMonth: memberShowCoopCurrentMonth,
    );
    _triggerSync();
  }

  Future<void> updateLanguage(String language) async {
    await _repository.updateLanguage(language);
  }

  Future<void> updateThemeMode(String themeMode) async {
    await _repository.updateThemeMode(themeMode);
  }

  // ---------- Members ----------
  Stream<List<Member>> watchActiveMembers({String? query}) =>
      _repository.watchActiveMembers(query: query);

  Stream<List<Member>> watchTrashedMembers() =>
      _repository.watchTrashedMembers();

  Future<Member?> getMemberByUuid(String uuid) =>
      _repository.getMemberByUuid(uuid);

  Future<Member?> getMemberByPhoneNormalized(String phoneNormalized) =>
      _repository.getMemberByPhoneNormalized(phoneNormalized);

  Future<bool> isPhoneTaken(String phoneNormalized, {String? excludeUuid}) =>
      _repository.isPhoneTaken(phoneNormalized, excludeUuid: excludeUuid);

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
    await _repository.addMember(
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
    _triggerSync();
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
    await _repository.updateMember(
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
    _triggerSync();
  }

  Future<String?> _resolveMemberPhoto(String memberUuid, String? photoPath) async {
    final coopId = await _repository.db.getStoredTenantCoopId();
    if (coopId == null || coopId.isEmpty) return photoPath;
    return _photoStorage.uploadIfLocal(
      coopId: coopId,
      memberUuid: memberUuid,
      photoPath: photoPath,
    );
  }

  Future<void> softDeleteMember(String uuid) async {
    await _repository.softDeleteMember(uuid);
    _triggerSync();
  }

  Future<void> restoreMember(String uuid) async {
    await _repository.restoreMember(uuid);
    _triggerSync();
  }

  Future<void> permanentlyDeleteMember(String uuid) async {
    await _repository.permanentlyDeleteMember(uuid);
    _triggerSync();
  }

  // ---------- Deposits ----------
  Stream<List<Deposit>> watchLastDeposits({int limit = 5}) =>
      _repository.watchLastDeposits(limit: limit);

  Stream<List<Deposit>> watchMemberDeposits(String memberUuid) =>
      _repository.watchMemberDeposits(memberUuid);

  Stream<List<Deposit>> watchRecentDepositsForMember(
    String memberUuid, {
    int limit = 5,
  }) =>
      _repository.watchRecentDepositsForMember(memberUuid, limit: limit);

  Stream<List<Deposit>> watchTrashedDeposits() =>
      _repository.watchTrashedDeposits();

  Future<Deposit?> getDepositByUuid(String uuid) =>
      _repository.getDepositByUuid(uuid);

  Future<void> updateDepositReceiptPath(String depositUuid, String path) async {
    await _repository.updateDepositReceiptPath(depositUuid, path);
    _triggerSync();
  }

  Future<List<String>> checkExistingDepositsForMonths({
    required String memberUuid,
    required List<String> monthKeys,
    String? excludeDepositUuid,
  }) =>
      _repository.checkExistingDepositsForMonths(
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
  }) async {
    await _repository.addDeposit(
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
    _triggerSync();
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
    await _repository.updateDeposit(
      uuid: uuid,
      date: date,
      amount: amount,
      reason: reason,
      method: method,
      receivedBy: receivedBy,
      monthKeyOverride: monthKeyOverride,
    );
    _triggerSync();
  }

  Future<void> softDeleteDeposit(String uuid) async {
    await _repository.softDeleteDeposit(uuid);
    _triggerSync();
  }

  Future<void> restoreDeposit(String uuid) async {
    await _repository.restoreDeposit(uuid);
    _triggerSync();
  }

  Future<void> permanentlyDeleteDeposit(String uuid) async {
    await _repository.permanentlyDeleteDeposit(uuid);
    _triggerSync();
  }

  // ---------- Reports ----------
  Future<int> totalCollectionAllTime() => _repository.totalCollectionAllTime();

  Future<int> collectionForMonth(String mKey) =>
      _repository.collectionForMonth(mKey);

  Future<Map<String, int>> collectionByMonth() =>
      _repository.collectionByMonth();

  Future<int> collectionForYear(int year) =>
      _repository.collectionForYear(year);

  Future<Map<String, int>> collectionByMonthForYear(int year) =>
      _repository.collectionByMonthForYear(year);

  Future<Map<String, dynamic>> dueSummaryAllMembers({
    required DateTime start,
    required DateTime endInclusive,
  }) =>
      _repository.dueSummaryAllMembers(
        start: start,
        endInclusive: endInclusive,
      );

  Future<Map<String, dynamic>> dueForOneMember({
    required String memberUuid,
    required DateTime start,
    required DateTime endInclusive,
  }) =>
      _repository.dueForOneMember(
        memberUuid: memberUuid,
        start: start,
        endInclusive: endInclusive,
      );

  Future<List<Map<String, dynamic>>> getPaidMembersForMonth(
    String monthKey,
  ) =>
      _repository.getPaidMembersForMonth(monthKey);

  Future<List<Map<String, dynamic>>> getUnpaidMembersForMonth(
    String monthKey,
  ) =>
      _repository.getUnpaidMembersForMonth(monthKey);

  Future<List<Member>> getAllMembers({bool includeTrashed = false}) =>
      _repository.getAllMembers(includeTrashed: includeTrashed);

  Future<List<Deposit>> getAllDeposits({
    bool includeTrashed = false,
    String? memberUuid,
  }) =>
      _repository.getAllDeposits(
        includeTrashed: includeTrashed,
        memberUuid: memberUuid,
      );

  Future<String> exportToJson() async => '{}';

  Future<BackupImportResult> importFromJson(String jsonData) async {
    _triggerSync();
    return const BackupImportResult(stats: {}, membersToProvision: []);
  }

  // Helper method to trigger sync
  void _triggerSync() {
    Future.microtask(() => _syncService.forceSync());
  }
}
