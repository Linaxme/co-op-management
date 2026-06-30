import '../../core/db/app_db.dart';
import '../../core/firebase/models.dart';

Member memberFromFirestore(FirestoreMember fm, {int id = 0}) {
  return Member(
    id: id,
    uuid: fm.uuid,
    memberIdNumber: fm.memberIdNumber,
    name: fm.name,
    phone: fm.phone,
    phoneNormalized: fm.phoneNormalized,
    pinHash: fm.pinHash,
    address: fm.address,
    nidNumber: fm.nidNumber,
    photoPath: fm.photoPath,
    monthlyAmount: fm.monthlyAmount,
    isActive: fm.isActive,
    canCollectDeposits: fm.canCollectDeposits,
    deletedAt: fm.deletedAt,
    createdAt: fm.createdAt,
    updatedAt: fm.updatedAt,
  );
}

Deposit depositFromFirestore(FirestoreDeposit fd, {int id = 0}) {
  return Deposit(
    id: id,
    uuid: fd.uuid,
    memberUuid: fd.memberUuid,
    date: fd.date,
    monthKey: fd.monthKey,
    amount: fd.amount,
    reason: fd.reason,
    method: fd.method,
    receivedBy: fd.receivedBy,
    receiptSerial: fd.receiptSerial,
    receiptPdfPath: fd.receiptPdfPath,
    deletedAt: fd.deletedAt,
    createdAt: fd.createdAt,
    updatedAt: fd.updatedAt,
  );
}

OrganizationData organizationFromFirestore(
  FirestoreOrganization fo, {
  int id = 1,
}) {
  return OrganizationData(
    id: id,
    name: fo.name,
    shortName: fo.shortName,
    address: fo.address,
    logoPath: fo.logoPath,
    signaturePath: fo.signaturePath,
    updatedAt: fo.updatedAt,
  );
}

SettingsData settingsFromFirestore(
  FirestoreSettings fs, {
  int id = 1,
  String? tenantCoopId,
  String? languageOverride,
  String? themeModeOverride,
}) {
  return SettingsData(
    id: id,
    defaultReceivedBy: fs.defaultReceivedBy,
    receiptPrefix: fs.receiptPrefix,
    nextReceiptSerial: fs.nextReceiptSerial,
    language: languageOverride ?? fs.language,
    themeMode: themeModeOverride ?? fs.themeMode,
    defaultMemberPassword: fs.defaultMemberPassword,
    memberShowCoopTotalCollection: fs.memberShowCoopTotalCollection,
    memberShowCoopTotalDue: fs.memberShowCoopTotalDue,
    memberShowDueMembersList: fs.memberShowDueMembersList,
    memberShowCoopCurrentMonth: fs.memberShowCoopCurrentMonth,
    tenantCoopId: tenantCoopId,
    updatedAt: fs.updatedAt,
  );
}
