import 'dart:convert';

import '../../core/db/app_db.dart';

class BackupCodec {
  static const String version = '1.0';

  static String encode({
    required OrganizationData org,
    required SettingsData settings,
    required List<Member> members,
    required List<Deposit> deposits,
  }) {
    final backupData = {
      'version': version,
      'exportDate': DateTime.now().toIso8601String(),
      'organization': {
        'name': org.name,
        'shortName': org.shortName,
        'address': org.address,
        'logoPath': org.logoPath,
        'signaturePath': org.signaturePath,
        'updatedAt': org.updatedAt.toIso8601String(),
      },
      'settings': {
        'defaultReceivedBy': settings.defaultReceivedBy,
        'receiptPrefix': settings.receiptPrefix,
        'nextReceiptSerial': settings.nextReceiptSerial,
        'language': settings.language,
        'themeMode': settings.themeMode,
        'defaultMemberPassword': settings.defaultMemberPassword,
        'memberShowCoopTotalCollection':
            settings.memberShowCoopTotalCollection,
        'memberShowCoopTotalDue': settings.memberShowCoopTotalDue,
        'memberShowDueMembersList': settings.memberShowDueMembersList,
        'memberShowCoopCurrentMonth': settings.memberShowCoopCurrentMonth,
        'updatedAt': settings.updatedAt.toIso8601String(),
      },
      'members': members.map(_memberToJson).toList(),
      'deposits': deposits.map(_depositToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  static Map<String, dynamic> decode(String jsonString) {
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
    if (backupData['version'] != version) {
      throw Exception('Unsupported backup version: ${backupData['version']}');
    }
    return backupData;
  }

  static Map<String, dynamic> memberToJson(Member m) => _memberToJson(m);

  static Map<String, dynamic> depositToJson(Deposit d) => _depositToJson(d);

  static Map<String, dynamic> _memberToJson(Member m) => {
        'uuid': m.uuid,
        'memberIdNumber': m.memberIdNumber,
        'name': m.name,
        'phone': m.phone,
        'phoneNormalized': m.phoneNormalized,
        'address': m.address,
        'nidNumber': m.nidNumber,
        'photoPath': m.photoPath,
        'monthlyAmount': m.monthlyAmount,
        'isActive': m.isActive,
        'deletedAt': m.deletedAt?.toIso8601String(),
        'createdAt': m.createdAt.toIso8601String(),
        'updatedAt': m.updatedAt.toIso8601String(),
      };

  static Map<String, dynamic> _depositToJson(Deposit d) => {
        'uuid': d.uuid,
        'memberUuid': d.memberUuid,
        'date': d.date.toIso8601String(),
        'monthKey': d.monthKey,
        'amount': d.amount,
        'reason': d.reason,
        'method': d.method,
        'receivedBy': d.receivedBy,
        'receiptSerial': d.receiptSerial,
        'receiptPdfPath': d.receiptPdfPath,
        'deletedAt': d.deletedAt?.toIso8601String(),
        'createdAt': d.createdAt.toIso8601String(),
        'updatedAt': d.updatedAt.toIso8601String(),
      };

  static int asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.parse(value.toString());
  }
}
