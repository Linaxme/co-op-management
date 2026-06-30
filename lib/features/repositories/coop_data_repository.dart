import '../../core/db/app_db.dart';
import 'backup_import_result.dart';

/// Shared data-access API for local+sync (mobile) and Firestore-direct (web).
abstract class CoopDataRepository {
  Stream<OrganizationData> watchOrganization();
  Stream<SettingsData> watchSettings();
  Future<SettingsData> getSettings();
  Future<int> generateReceiptSerialFromDateTime(DateTime dateTime);
  Future<int> nextReceiptSerialAndIncrement();

  Future<void> updateOrganization({
    required String name,
    required String address,
    String? shortName,
    String? logoPath,
    String? signaturePath,
  });

  Future<void> updateSettings({
    required String defaultReceivedBy,
    required String receiptPrefix,
    String? language,
    String? defaultMemberPassword,
    bool? memberShowCoopTotalCollection,
    bool? memberShowCoopTotalDue,
    bool? memberShowDueMembersList,
    bool? memberShowCoopCurrentMonth,
  });

  Future<void> updateLanguage(String language);
  Future<void> updateThemeMode(String themeMode);

  Stream<List<Member>> watchActiveMembers({String? query});
  Stream<List<Member>> watchTrashedMembers();
  Future<Member?> getMemberByUuid(String uuid);
  Future<Member?> getMemberByPhoneNormalized(String phoneNormalized);
  Future<bool> isPhoneTaken(String phoneNormalized, {String? excludeUuid});

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
    bool canCollectDeposits,
  });

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
  });

  Future<void> softDeleteMember(String uuid);
  Future<void> restoreMember(String uuid);
  Future<void> permanentlyDeleteMember(String uuid);

  Stream<List<Deposit>> watchLastDeposits({int limit});
  Stream<List<Deposit>> watchMemberDeposits(String memberUuid);
  Stream<List<Deposit>> watchRecentDepositsForMember(String memberUuid, {int limit});
  Stream<List<Deposit>> watchTrashedDeposits();
  Future<Deposit?> getDepositByUuid(String uuid);
  Future<void> updateDepositReceiptPath(String depositUuid, String path);

  Future<List<String>> checkExistingDepositsForMonths({
    required String memberUuid,
    required List<String> monthKeys,
    String? excludeDepositUuid,
  });

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
  });

  Future<void> updateDeposit({
    required String uuid,
    DateTime? date,
    int? amount,
    String? reason,
    String? method,
    String? receivedBy,
    String? monthKeyOverride,
  });

  Future<void> softDeleteDeposit(String uuid);
  Future<void> restoreDeposit(String uuid);
  Future<void> permanentlyDeleteDeposit(String uuid);

  Future<int> totalCollectionAllTime();
  Future<int> collectionForMonth(String mKey);
  Future<Map<String, int>> collectionByMonth();
  Future<int> collectionForYear(int year);
  Future<Map<String, int>> collectionByMonthForYear(int year);

  Future<Map<String, dynamic>> dueSummaryAllMembers({
    required DateTime start,
    required DateTime endInclusive,
  });

  Future<Map<String, dynamic>> dueForOneMember({
    required String memberUuid,
    required DateTime start,
    required DateTime endInclusive,
  });

  Future<List<Map<String, dynamic>>> getPaidMembersForMonth(String monthKey);
  Future<List<Map<String, dynamic>>> getUnpaidMembersForMonth(String monthKey);

  Future<List<Member>> getAllMembers({bool includeTrashed = false});
  Future<List<Deposit>> getAllDeposits({
    bool includeTrashed = false,
    String? memberUuid,
  });

  Future<String> exportToJson();
  Future<BackupImportResult> importFromJson(String jsonData);
}
