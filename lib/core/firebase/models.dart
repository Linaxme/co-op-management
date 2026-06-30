import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_parsers.dart';

// Firestore-compatible models that match Drift schema

class FirestoreMember {
  final String id; // Firestore document ID
  final String uuid;
  final String memberIdNumber;
  final String name;
  final String? phone;
  final String? phoneNormalized;
  final String? pinHash;
  final String? address;
  final String? nidNumber;
  final String? photoPath;
  final int monthlyAmount;
  final bool isActive;
  final bool canCollectDeposits;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirestoreMember({
    required this.id,
    required this.uuid,
    required this.memberIdNumber,
    required this.name,
    this.phone,
    this.phoneNormalized,
    this.pinHash,
    this.address,
    this.nidNumber,
    this.photoPath,
    required this.monthlyAmount,
    required this.isActive,
    this.canCollectDeposits = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FirestoreMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreMember(
      id: doc.id,
      uuid: parseFirestoreString(data['uuid']),
      memberIdNumber: parseFirestoreString(data['memberIdNumber']),
      name: parseFirestoreString(data['name']),
      phone: parseFirestoreStringOrNull(data['phone']),
      phoneNormalized: parseFirestoreStringOrNull(data['phoneNormalized']),
      pinHash: parseFirestoreStringOrNull(data['pinHash']),
      address: parseFirestoreStringOrNull(data['address']),
      nidNumber: parseFirestoreStringOrNull(data['nidNumber']),
      photoPath: parseFirestoreStringOrNull(data['photoPath']),
      monthlyAmount: parseFirestoreInt(data['monthlyAmount']),
      isActive: parseFirestoreBool(data['isActive']),
      canCollectDeposits: parseFirestoreBool(data['canCollectDeposits']),
      deletedAt: parseFirestoreDateTimeOrNull(data['deletedAt']),
      createdAt: parseFirestoreDateTime(data['createdAt'],
          fallback: DateTime.fromMillisecondsSinceEpoch(0)),
      updatedAt: parseFirestoreDateTime(data['updatedAt'],
          fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
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

class FirestoreDeposit {
  final String id; // Firestore document ID
  final String uuid;
  final String memberUuid;
  final DateTime date;
  final String monthKey;
  final int amount;
  final String? reason;
  final String method;
  final String receivedBy;
  final int receiptSerial;
  final String? receiptPdfPath;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirestoreDeposit({
    required this.id,
    required this.uuid,
    required this.memberUuid,
    required this.date,
    required this.monthKey,
    required this.amount,
    this.reason,
    required this.method,
    required this.receivedBy,
    required this.receiptSerial,
    this.receiptPdfPath,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FirestoreDeposit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreDeposit(
      id: doc.id,
      uuid: parseFirestoreString(data['uuid']),
      memberUuid: parseFirestoreString(data['memberUuid']),
      date: parseFirestoreDateTime(data['date'], fallback: DateTime.now()),
      monthKey: parseFirestoreString(data['monthKey']),
      amount: parseFirestoreInt(data['amount']),
      reason: parseFirestoreStringOrNull(data['reason']),
      method: parseFirestoreString(data['method'], defaultValue: 'cash'),
      receivedBy: parseFirestoreString(data['receivedBy']),
      receiptSerial: parseFirestoreInt(data['receiptSerial']),
      receiptPdfPath: parseFirestoreStringOrNull(data['receiptPdfPath']),
      deletedAt: parseFirestoreDateTimeOrNull(data['deletedAt']),
      createdAt: parseFirestoreDateTime(data['createdAt'],
          fallback: DateTime.fromMillisecondsSinceEpoch(0)),
      updatedAt: parseFirestoreDateTime(data['updatedAt'],
          fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
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

class CooperativeLookup {
  final String coopId;
  final String name;
  final String shortName;
  final String? logoPath;

  const CooperativeLookup({
    required this.coopId,
    required this.name,
    required this.shortName,
    this.logoPath,
  });
}

class FirestoreOrganization {
  final String id; // Firestore document ID
  final String name;
  final String? shortName;
  final String address;
  final String? logoPath;
  final String? signaturePath;
  final DateTime updatedAt;

  FirestoreOrganization({
    required this.id,
    required this.name,
    this.shortName,
    required this.address,
    this.logoPath,
    this.signaturePath,
    required this.updatedAt,
  });

  factory FirestoreOrganization.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreOrganization(
      id: doc.id,
      name: parseFirestoreString(data['name']),
      shortName: parseFirestoreStringOrNull(data['shortName']),
      address: parseFirestoreString(data['address']),
      logoPath: parseFirestoreStringOrNull(data['logoPath']),
      signaturePath: parseFirestoreStringOrNull(data['signaturePath']),
      updatedAt: parseFirestoreDateTime(data['updatedAt'],
          fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (shortName != null) 'shortName': shortName,
      'address': address,
      'logoPath': logoPath,
      'signaturePath': signaturePath,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FirestoreSettings {
  final String id; // Firestore document ID
  final String defaultReceivedBy;
  final String receiptPrefix;
  final int nextReceiptSerial;
  final String language;
  final String themeMode;
  final String defaultMemberPassword;
  final bool memberShowCoopTotalCollection;
  final bool memberShowCoopTotalDue;
  final bool memberShowDueMembersList;
  final bool memberShowCoopCurrentMonth;
  final DateTime updatedAt;

  FirestoreSettings({
    required this.id,
    required this.defaultReceivedBy,
    required this.receiptPrefix,
    required this.nextReceiptSerial,
    required this.language,
    required this.themeMode,
    required this.defaultMemberPassword,
    required this.memberShowCoopTotalCollection,
    required this.memberShowCoopTotalDue,
    required this.memberShowDueMembersList,
    required this.memberShowCoopCurrentMonth,
    required this.updatedAt,
  });

  factory FirestoreSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreSettings(
      id: doc.id,
      defaultReceivedBy:
          parseFirestoreString(data['defaultReceivedBy'], defaultValue: 'Admin'),
      receiptPrefix:
          parseFirestoreString(data['receiptPrefix'], defaultValue: 'RCPT'),
      nextReceiptSerial: parseFirestoreInt(data['nextReceiptSerial'], defaultValue: 1),
      language: parseFirestoreString(data['language'], defaultValue: 'en'),
      themeMode: parseFirestoreString(data['themeMode'], defaultValue: 'system'),
      defaultMemberPassword:
          parseFirestoreString(data['defaultMemberPassword'], defaultValue: '123456'),
      memberShowCoopTotalCollection: parseFirestoreBool(
        data['memberShowCoopTotalCollection'],
      ),
      memberShowCoopTotalDue: parseFirestoreBool(data['memberShowCoopTotalDue']),
      memberShowDueMembersList:
          parseFirestoreBool(data['memberShowDueMembersList']),
      memberShowCoopCurrentMonth:
          parseFirestoreBool(data['memberShowCoopCurrentMonth']),
      updatedAt: parseFirestoreDateTime(data['updatedAt'],
          fallback: DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
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
