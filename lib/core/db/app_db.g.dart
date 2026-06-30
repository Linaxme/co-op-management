// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _memberIdNumberMeta =
      const VerificationMeta('memberIdNumber');
  @override
  late final GeneratedColumn<String> memberIdNumber = GeneratedColumn<String>(
      'member_id_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneNormalizedMeta =
      const VerificationMeta('phoneNormalized');
  @override
  late final GeneratedColumn<String> phoneNormalized = GeneratedColumn<String>(
      'phone_normalized', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _pinHashMeta =
      const VerificationMeta('pinHash');
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
      'pin_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nidNumberMeta =
      const VerificationMeta('nidNumber');
  @override
  late final GeneratedColumn<String> nidNumber = GeneratedColumn<String>(
      'nid_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _monthlyAmountMeta =
      const VerificationMeta('monthlyAmount');
  @override
  late final GeneratedColumn<int> monthlyAmount = GeneratedColumn<int>(
      'monthly_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _canCollectDepositsMeta =
      const VerificationMeta('canCollectDeposits');
  @override
  late final GeneratedColumn<bool> canCollectDeposits = GeneratedColumn<bool>(
      'can_collect_deposits', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("can_collect_deposits" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        memberIdNumber,
        name,
        phone,
        phoneNormalized,
        pinHash,
        address,
        nidNumber,
        photoPath,
        monthlyAmount,
        isActive,
        canCollectDeposits,
        deletedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<Member> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('member_id_number')) {
      context.handle(
          _memberIdNumberMeta,
          memberIdNumber.isAcceptableOrUnknown(
              data['member_id_number']!, _memberIdNumberMeta));
    } else if (isInserting) {
      context.missing(_memberIdNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('phone_normalized')) {
      context.handle(
          _phoneNormalizedMeta,
          phoneNormalized.isAcceptableOrUnknown(
              data['phone_normalized']!, _phoneNormalizedMeta));
    }
    if (data.containsKey('pin_hash')) {
      context.handle(_pinHashMeta,
          pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('nid_number')) {
      context.handle(_nidNumberMeta,
          nidNumber.isAcceptableOrUnknown(data['nid_number']!, _nidNumberMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('monthly_amount')) {
      context.handle(
          _monthlyAmountMeta,
          monthlyAmount.isAcceptableOrUnknown(
              data['monthly_amount']!, _monthlyAmountMeta));
    } else if (isInserting) {
      context.missing(_monthlyAmountMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('can_collect_deposits')) {
      context.handle(
          _canCollectDepositsMeta,
          canCollectDeposits.isAcceptableOrUnknown(
              data['can_collect_deposits']!, _canCollectDepositsMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      memberIdNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}member_id_number'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      phoneNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}phone_normalized']),
      pinHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin_hash']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      nidNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nid_number']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      monthlyAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}monthly_amount'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      canCollectDeposits: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}can_collect_deposits'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final int id;
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
  const Member(
      {required this.id,
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
      required this.canCollectDeposits,
      this.deletedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['member_id_number'] = Variable<String>(memberIdNumber);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || phoneNormalized != null) {
      map['phone_normalized'] = Variable<String>(phoneNormalized);
    }
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || nidNumber != null) {
      map['nid_number'] = Variable<String>(nidNumber);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['monthly_amount'] = Variable<int>(monthlyAmount);
    map['is_active'] = Variable<bool>(isActive);
    map['can_collect_deposits'] = Variable<bool>(canCollectDeposits);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      uuid: Value(uuid),
      memberIdNumber: Value(memberIdNumber),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      phoneNormalized: phoneNormalized == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNormalized),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      nidNumber: nidNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(nidNumber),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      monthlyAmount: Value(monthlyAmount),
      isActive: Value(isActive),
      canCollectDeposits: Value(canCollectDeposits),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Member.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      memberIdNumber: serializer.fromJson<String>(json['memberIdNumber']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      phoneNormalized: serializer.fromJson<String?>(json['phoneNormalized']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      address: serializer.fromJson<String?>(json['address']),
      nidNumber: serializer.fromJson<String?>(json['nidNumber']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      monthlyAmount: serializer.fromJson<int>(json['monthlyAmount']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      canCollectDeposits: serializer.fromJson<bool>(json['canCollectDeposits']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'memberIdNumber': serializer.toJson<String>(memberIdNumber),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'phoneNormalized': serializer.toJson<String?>(phoneNormalized),
      'pinHash': serializer.toJson<String?>(pinHash),
      'address': serializer.toJson<String?>(address),
      'nidNumber': serializer.toJson<String?>(nidNumber),
      'photoPath': serializer.toJson<String?>(photoPath),
      'monthlyAmount': serializer.toJson<int>(monthlyAmount),
      'isActive': serializer.toJson<bool>(isActive),
      'canCollectDeposits': serializer.toJson<bool>(canCollectDeposits),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Member copyWith(
          {int? id,
          String? uuid,
          String? memberIdNumber,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> phoneNormalized = const Value.absent(),
          Value<String?> pinHash = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> nidNumber = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          int? monthlyAmount,
          bool? isActive,
          bool? canCollectDeposits,
          Value<DateTime?> deletedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Member(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        memberIdNumber: memberIdNumber ?? this.memberIdNumber,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        phoneNormalized: phoneNormalized.present
            ? phoneNormalized.value
            : this.phoneNormalized,
        pinHash: pinHash.present ? pinHash.value : this.pinHash,
        address: address.present ? address.value : this.address,
        nidNumber: nidNumber.present ? nidNumber.value : this.nidNumber,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        monthlyAmount: monthlyAmount ?? this.monthlyAmount,
        isActive: isActive ?? this.isActive,
        canCollectDeposits: canCollectDeposits ?? this.canCollectDeposits,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      memberIdNumber: data.memberIdNumber.present
          ? data.memberIdNumber.value
          : this.memberIdNumber,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      phoneNormalized: data.phoneNormalized.present
          ? data.phoneNormalized.value
          : this.phoneNormalized,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      address: data.address.present ? data.address.value : this.address,
      nidNumber: data.nidNumber.present ? data.nidNumber.value : this.nidNumber,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      monthlyAmount: data.monthlyAmount.present
          ? data.monthlyAmount.value
          : this.monthlyAmount,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      canCollectDeposits: data.canCollectDeposits.present
          ? data.canCollectDeposits.value
          : this.canCollectDeposits,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('memberIdNumber: $memberIdNumber, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('phoneNormalized: $phoneNormalized, ')
          ..write('pinHash: $pinHash, ')
          ..write('address: $address, ')
          ..write('nidNumber: $nidNumber, ')
          ..write('photoPath: $photoPath, ')
          ..write('monthlyAmount: $monthlyAmount, ')
          ..write('isActive: $isActive, ')
          ..write('canCollectDeposits: $canCollectDeposits, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      memberIdNumber,
      name,
      phone,
      phoneNormalized,
      pinHash,
      address,
      nidNumber,
      photoPath,
      monthlyAmount,
      isActive,
      canCollectDeposits,
      deletedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.memberIdNumber == this.memberIdNumber &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.phoneNormalized == this.phoneNormalized &&
          other.pinHash == this.pinHash &&
          other.address == this.address &&
          other.nidNumber == this.nidNumber &&
          other.photoPath == this.photoPath &&
          other.monthlyAmount == this.monthlyAmount &&
          other.isActive == this.isActive &&
          other.canCollectDeposits == this.canCollectDeposits &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> memberIdNumber;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> phoneNormalized;
  final Value<String?> pinHash;
  final Value<String?> address;
  final Value<String?> nidNumber;
  final Value<String?> photoPath;
  final Value<int> monthlyAmount;
  final Value<bool> isActive;
  final Value<bool> canCollectDeposits;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.memberIdNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.phoneNormalized = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.address = const Value.absent(),
    this.nidNumber = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.monthlyAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.canCollectDeposits = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MembersCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String memberIdNumber,
    required String name,
    this.phone = const Value.absent(),
    this.phoneNormalized = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.address = const Value.absent(),
    this.nidNumber = const Value.absent(),
    this.photoPath = const Value.absent(),
    required int monthlyAmount,
    this.isActive = const Value.absent(),
    this.canCollectDeposits = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : uuid = Value(uuid),
        memberIdNumber = Value(memberIdNumber),
        name = Value(name),
        monthlyAmount = Value(monthlyAmount),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Member> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? memberIdNumber,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? phoneNormalized,
    Expression<String>? pinHash,
    Expression<String>? address,
    Expression<String>? nidNumber,
    Expression<String>? photoPath,
    Expression<int>? monthlyAmount,
    Expression<bool>? isActive,
    Expression<bool>? canCollectDeposits,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (memberIdNumber != null) 'member_id_number': memberIdNumber,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (phoneNormalized != null) 'phone_normalized': phoneNormalized,
      if (pinHash != null) 'pin_hash': pinHash,
      if (address != null) 'address': address,
      if (nidNumber != null) 'nid_number': nidNumber,
      if (photoPath != null) 'photo_path': photoPath,
      if (monthlyAmount != null) 'monthly_amount': monthlyAmount,
      if (isActive != null) 'is_active': isActive,
      if (canCollectDeposits != null)
        'can_collect_deposits': canCollectDeposits,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MembersCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? memberIdNumber,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? phoneNormalized,
      Value<String?>? pinHash,
      Value<String?>? address,
      Value<String?>? nidNumber,
      Value<String?>? photoPath,
      Value<int>? monthlyAmount,
      Value<bool>? isActive,
      Value<bool>? canCollectDeposits,
      Value<DateTime?>? deletedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return MembersCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      memberIdNumber: memberIdNumber ?? this.memberIdNumber,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      phoneNormalized: phoneNormalized ?? this.phoneNormalized,
      pinHash: pinHash ?? this.pinHash,
      address: address ?? this.address,
      nidNumber: nidNumber ?? this.nidNumber,
      photoPath: photoPath ?? this.photoPath,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      isActive: isActive ?? this.isActive,
      canCollectDeposits: canCollectDeposits ?? this.canCollectDeposits,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (memberIdNumber.present) {
      map['member_id_number'] = Variable<String>(memberIdNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (phoneNormalized.present) {
      map['phone_normalized'] = Variable<String>(phoneNormalized.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (nidNumber.present) {
      map['nid_number'] = Variable<String>(nidNumber.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (monthlyAmount.present) {
      map['monthly_amount'] = Variable<int>(monthlyAmount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (canCollectDeposits.present) {
      map['can_collect_deposits'] = Variable<bool>(canCollectDeposits.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('memberIdNumber: $memberIdNumber, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('phoneNormalized: $phoneNormalized, ')
          ..write('pinHash: $pinHash, ')
          ..write('address: $address, ')
          ..write('nidNumber: $nidNumber, ')
          ..write('photoPath: $photoPath, ')
          ..write('monthlyAmount: $monthlyAmount, ')
          ..write('isActive: $isActive, ')
          ..write('canCollectDeposits: $canCollectDeposits, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DepositsTable extends Deposits with TableInfo<$DepositsTable, Deposit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepositsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _memberUuidMeta =
      const VerificationMeta('memberUuid');
  @override
  late final GeneratedColumn<String> memberUuid = GeneratedColumn<String>(
      'member_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _monthKeyMeta =
      const VerificationMeta('monthKey');
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
      'month_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receivedByMeta =
      const VerificationMeta('receivedBy');
  @override
  late final GeneratedColumn<String> receivedBy = GeneratedColumn<String>(
      'received_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiptSerialMeta =
      const VerificationMeta('receiptSerial');
  @override
  late final GeneratedColumn<int> receiptSerial = GeneratedColumn<int>(
      'receipt_serial', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _receiptPdfPathMeta =
      const VerificationMeta('receiptPdfPath');
  @override
  late final GeneratedColumn<String> receiptPdfPath = GeneratedColumn<String>(
      'receipt_pdf_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uuid,
        memberUuid,
        date,
        monthKey,
        amount,
        reason,
        method,
        receivedBy,
        receiptSerial,
        receiptPdfPath,
        deletedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deposits';
  @override
  VerificationContext validateIntegrity(Insertable<Deposit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('member_uuid')) {
      context.handle(
          _memberUuidMeta,
          memberUuid.isAcceptableOrUnknown(
              data['member_uuid']!, _memberUuidMeta));
    } else if (isInserting) {
      context.missing(_memberUuidMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('month_key')) {
      context.handle(_monthKeyMeta,
          monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta));
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('received_by')) {
      context.handle(
          _receivedByMeta,
          receivedBy.isAcceptableOrUnknown(
              data['received_by']!, _receivedByMeta));
    } else if (isInserting) {
      context.missing(_receivedByMeta);
    }
    if (data.containsKey('receipt_serial')) {
      context.handle(
          _receiptSerialMeta,
          receiptSerial.isAcceptableOrUnknown(
              data['receipt_serial']!, _receiptSerialMeta));
    } else if (isInserting) {
      context.missing(_receiptSerialMeta);
    }
    if (data.containsKey('receipt_pdf_path')) {
      context.handle(
          _receiptPdfPathMeta,
          receiptPdfPath.isAcceptableOrUnknown(
              data['receipt_pdf_path']!, _receiptPdfPathMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deposit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deposit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      memberUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_uuid'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      monthKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month_key'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      receivedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}received_by'])!,
      receiptSerial: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}receipt_serial'])!,
      receiptPdfPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receipt_pdf_path']),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DepositsTable createAlias(String alias) {
    return $DepositsTable(attachedDatabase, alias);
  }
}

class Deposit extends DataClass implements Insertable<Deposit> {
  final int id;
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
  const Deposit(
      {required this.id,
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
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['member_uuid'] = Variable<String>(memberUuid);
    map['date'] = Variable<DateTime>(date);
    map['month_key'] = Variable<String>(monthKey);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['method'] = Variable<String>(method);
    map['received_by'] = Variable<String>(receivedBy);
    map['receipt_serial'] = Variable<int>(receiptSerial);
    if (!nullToAbsent || receiptPdfPath != null) {
      map['receipt_pdf_path'] = Variable<String>(receiptPdfPath);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DepositsCompanion toCompanion(bool nullToAbsent) {
    return DepositsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      memberUuid: Value(memberUuid),
      date: Value(date),
      monthKey: Value(monthKey),
      amount: Value(amount),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      method: Value(method),
      receivedBy: Value(receivedBy),
      receiptSerial: Value(receiptSerial),
      receiptPdfPath: receiptPdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPdfPath),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Deposit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deposit(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      memberUuid: serializer.fromJson<String>(json['memberUuid']),
      date: serializer.fromJson<DateTime>(json['date']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String?>(json['reason']),
      method: serializer.fromJson<String>(json['method']),
      receivedBy: serializer.fromJson<String>(json['receivedBy']),
      receiptSerial: serializer.fromJson<int>(json['receiptSerial']),
      receiptPdfPath: serializer.fromJson<String?>(json['receiptPdfPath']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'memberUuid': serializer.toJson<String>(memberUuid),
      'date': serializer.toJson<DateTime>(date),
      'monthKey': serializer.toJson<String>(monthKey),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String?>(reason),
      'method': serializer.toJson<String>(method),
      'receivedBy': serializer.toJson<String>(receivedBy),
      'receiptSerial': serializer.toJson<int>(receiptSerial),
      'receiptPdfPath': serializer.toJson<String?>(receiptPdfPath),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Deposit copyWith(
          {int? id,
          String? uuid,
          String? memberUuid,
          DateTime? date,
          String? monthKey,
          int? amount,
          Value<String?> reason = const Value.absent(),
          String? method,
          String? receivedBy,
          int? receiptSerial,
          Value<String?> receiptPdfPath = const Value.absent(),
          Value<DateTime?> deletedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Deposit(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        memberUuid: memberUuid ?? this.memberUuid,
        date: date ?? this.date,
        monthKey: monthKey ?? this.monthKey,
        amount: amount ?? this.amount,
        reason: reason.present ? reason.value : this.reason,
        method: method ?? this.method,
        receivedBy: receivedBy ?? this.receivedBy,
        receiptSerial: receiptSerial ?? this.receiptSerial,
        receiptPdfPath:
            receiptPdfPath.present ? receiptPdfPath.value : this.receiptPdfPath,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Deposit copyWithCompanion(DepositsCompanion data) {
    return Deposit(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      memberUuid:
          data.memberUuid.present ? data.memberUuid.value : this.memberUuid,
      date: data.date.present ? data.date.value : this.date,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      method: data.method.present ? data.method.value : this.method,
      receivedBy:
          data.receivedBy.present ? data.receivedBy.value : this.receivedBy,
      receiptSerial: data.receiptSerial.present
          ? data.receiptSerial.value
          : this.receiptSerial,
      receiptPdfPath: data.receiptPdfPath.present
          ? data.receiptPdfPath.value
          : this.receiptPdfPath,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deposit(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('memberUuid: $memberUuid, ')
          ..write('date: $date, ')
          ..write('monthKey: $monthKey, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('method: $method, ')
          ..write('receivedBy: $receivedBy, ')
          ..write('receiptSerial: $receiptSerial, ')
          ..write('receiptPdfPath: $receiptPdfPath, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uuid,
      memberUuid,
      date,
      monthKey,
      amount,
      reason,
      method,
      receivedBy,
      receiptSerial,
      receiptPdfPath,
      deletedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deposit &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.memberUuid == this.memberUuid &&
          other.date == this.date &&
          other.monthKey == this.monthKey &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.method == this.method &&
          other.receivedBy == this.receivedBy &&
          other.receiptSerial == this.receiptSerial &&
          other.receiptPdfPath == this.receiptPdfPath &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DepositsCompanion extends UpdateCompanion<Deposit> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> memberUuid;
  final Value<DateTime> date;
  final Value<String> monthKey;
  final Value<int> amount;
  final Value<String?> reason;
  final Value<String> method;
  final Value<String> receivedBy;
  final Value<int> receiptSerial;
  final Value<String?> receiptPdfPath;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DepositsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.memberUuid = const Value.absent(),
    this.date = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.method = const Value.absent(),
    this.receivedBy = const Value.absent(),
    this.receiptSerial = const Value.absent(),
    this.receiptPdfPath = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DepositsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String memberUuid,
    required DateTime date,
    required String monthKey,
    required int amount,
    this.reason = const Value.absent(),
    required String method,
    required String receivedBy,
    required int receiptSerial,
    this.receiptPdfPath = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : uuid = Value(uuid),
        memberUuid = Value(memberUuid),
        date = Value(date),
        monthKey = Value(monthKey),
        amount = Value(amount),
        method = Value(method),
        receivedBy = Value(receivedBy),
        receiptSerial = Value(receiptSerial),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Deposit> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? memberUuid,
    Expression<DateTime>? date,
    Expression<String>? monthKey,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<String>? method,
    Expression<String>? receivedBy,
    Expression<int>? receiptSerial,
    Expression<String>? receiptPdfPath,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (memberUuid != null) 'member_uuid': memberUuid,
      if (date != null) 'date': date,
      if (monthKey != null) 'month_key': monthKey,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (method != null) 'method': method,
      if (receivedBy != null) 'received_by': receivedBy,
      if (receiptSerial != null) 'receipt_serial': receiptSerial,
      if (receiptPdfPath != null) 'receipt_pdf_path': receiptPdfPath,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DepositsCompanion copyWith(
      {Value<int>? id,
      Value<String>? uuid,
      Value<String>? memberUuid,
      Value<DateTime>? date,
      Value<String>? monthKey,
      Value<int>? amount,
      Value<String?>? reason,
      Value<String>? method,
      Value<String>? receivedBy,
      Value<int>? receiptSerial,
      Value<String?>? receiptPdfPath,
      Value<DateTime?>? deletedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DepositsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      memberUuid: memberUuid ?? this.memberUuid,
      date: date ?? this.date,
      monthKey: monthKey ?? this.monthKey,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      method: method ?? this.method,
      receivedBy: receivedBy ?? this.receivedBy,
      receiptSerial: receiptSerial ?? this.receiptSerial,
      receiptPdfPath: receiptPdfPath ?? this.receiptPdfPath,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (memberUuid.present) {
      map['member_uuid'] = Variable<String>(memberUuid.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (receivedBy.present) {
      map['received_by'] = Variable<String>(receivedBy.value);
    }
    if (receiptSerial.present) {
      map['receipt_serial'] = Variable<int>(receiptSerial.value);
    }
    if (receiptPdfPath.present) {
      map['receipt_pdf_path'] = Variable<String>(receiptPdfPath.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepositsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('memberUuid: $memberUuid, ')
          ..write('date: $date, ')
          ..write('monthKey: $monthKey, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('method: $method, ')
          ..write('receivedBy: $receivedBy, ')
          ..write('receiptSerial: $receiptSerial, ')
          ..write('receiptPdfPath: $receiptPdfPath, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OrganizationTable extends Organization
    with TableInfo<$OrganizationTable, OrganizationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logoPathMeta =
      const VerificationMeta('logoPath');
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
      'logo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _signaturePathMeta =
      const VerificationMeta('signaturePath');
  @override
  late final GeneratedColumn<String> signaturePath = GeneratedColumn<String>(
      'signature_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, shortName, address, logoPath, signaturePath, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'organization';
  @override
  VerificationContext validateIntegrity(Insertable<OrganizationData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(_logoPathMeta,
          logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta));
    }
    if (data.containsKey('signature_path')) {
      context.handle(
          _signaturePathMeta,
          signaturePath.isAcceptableOrUnknown(
              data['signature_path']!, _signaturePathMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrganizationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrganizationData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      logoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_path']),
      signaturePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signature_path']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $OrganizationTable createAlias(String alias) {
    return $OrganizationTable(attachedDatabase, alias);
  }
}

class OrganizationData extends DataClass
    implements Insertable<OrganizationData> {
  final int id;
  final String name;
  final String? shortName;
  final String address;
  final String? logoPath;
  final String? signaturePath;
  final DateTime updatedAt;
  const OrganizationData(
      {required this.id,
      required this.name,
      this.shortName,
      required this.address,
      this.logoPath,
      this.signaturePath,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || shortName != null) {
      map['short_name'] = Variable<String>(shortName);
    }
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    if (!nullToAbsent || signaturePath != null) {
      map['signature_path'] = Variable<String>(signaturePath);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrganizationCompanion toCompanion(bool nullToAbsent) {
    return OrganizationCompanion(
      id: Value(id),
      name: Value(name),
      shortName: shortName == null && nullToAbsent
          ? const Value.absent()
          : Value(shortName),
      address: Value(address),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      signaturePath: signaturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(signaturePath),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrganizationData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrganizationData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String?>(json['shortName']),
      address: serializer.fromJson<String>(json['address']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      signaturePath: serializer.fromJson<String?>(json['signaturePath']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String?>(shortName),
      'address': serializer.toJson<String>(address),
      'logoPath': serializer.toJson<String?>(logoPath),
      'signaturePath': serializer.toJson<String?>(signaturePath),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OrganizationData copyWith(
          {int? id,
          String? name,
          Value<String?> shortName = const Value.absent(),
          String? address,
          Value<String?> logoPath = const Value.absent(),
          Value<String?> signaturePath = const Value.absent(),
          DateTime? updatedAt}) =>
      OrganizationData(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName.present ? shortName.value : this.shortName,
        address: address ?? this.address,
        logoPath: logoPath.present ? logoPath.value : this.logoPath,
        signaturePath:
            signaturePath.present ? signaturePath.value : this.signaturePath,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  OrganizationData copyWithCompanion(OrganizationCompanion data) {
    return OrganizationData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      address: data.address.present ? data.address.value : this.address,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      signaturePath: data.signaturePath.present
          ? data.signaturePath.value
          : this.signaturePath,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('address: $address, ')
          ..write('logoPath: $logoPath, ')
          ..write('signaturePath: $signaturePath, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, shortName, address, logoPath, signaturePath, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrganizationData &&
          other.id == this.id &&
          other.name == this.name &&
          other.shortName == this.shortName &&
          other.address == this.address &&
          other.logoPath == this.logoPath &&
          other.signaturePath == this.signaturePath &&
          other.updatedAt == this.updatedAt);
}

class OrganizationCompanion extends UpdateCompanion<OrganizationData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> shortName;
  final Value<String> address;
  final Value<String?> logoPath;
  final Value<String?> signaturePath;
  final Value<DateTime> updatedAt;
  const OrganizationCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.address = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.signaturePath = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OrganizationCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.shortName = const Value.absent(),
    required String address,
    this.logoPath = const Value.absent(),
    this.signaturePath = const Value.absent(),
    required DateTime updatedAt,
  })  : name = Value(name),
        address = Value(address),
        updatedAt = Value(updatedAt);
  static Insertable<OrganizationData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<String>? address,
    Expression<String>? logoPath,
    Expression<String>? signaturePath,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (address != null) 'address': address,
      if (logoPath != null) 'logo_path': logoPath,
      if (signaturePath != null) 'signature_path': signaturePath,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OrganizationCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? shortName,
      Value<String>? address,
      Value<String?>? logoPath,
      Value<String?>? signaturePath,
      Value<DateTime>? updatedAt}) {
    return OrganizationCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      address: address ?? this.address,
      logoPath: logoPath ?? this.logoPath,
      signaturePath: signaturePath ?? this.signaturePath,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (signaturePath.present) {
      map['signature_path'] = Variable<String>(signaturePath.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('address: $address, ')
          ..write('logoPath: $logoPath, ')
          ..write('signaturePath: $signaturePath, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _defaultReceivedByMeta =
      const VerificationMeta('defaultReceivedBy');
  @override
  late final GeneratedColumn<String> defaultReceivedBy =
      GeneratedColumn<String>('default_received_by', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _receiptPrefixMeta =
      const VerificationMeta('receiptPrefix');
  @override
  late final GeneratedColumn<String> receiptPrefix = GeneratedColumn<String>(
      'receipt_prefix', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('RCPT'));
  static const VerificationMeta _nextReceiptSerialMeta =
      const VerificationMeta('nextReceiptSerial');
  @override
  late final GeneratedColumn<int> nextReceiptSerial = GeneratedColumn<int>(
      'next_receipt_serial', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('system'));
  static const VerificationMeta _defaultMemberPasswordMeta =
      const VerificationMeta('defaultMemberPassword');
  @override
  late final GeneratedColumn<String> defaultMemberPassword =
      GeneratedColumn<String>('default_member_password', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('123456'));
  static const VerificationMeta _memberShowCoopTotalCollectionMeta =
      const VerificationMeta('memberShowCoopTotalCollection');
  @override
  late final GeneratedColumn<bool> memberShowCoopTotalCollection =
      GeneratedColumn<bool>(
          'member_show_coop_total_collection', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("member_show_coop_total_collection" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _memberShowCoopTotalDueMeta =
      const VerificationMeta('memberShowCoopTotalDue');
  @override
  late final GeneratedColumn<bool> memberShowCoopTotalDue =
      GeneratedColumn<bool>('member_show_coop_total_due', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("member_show_coop_total_due" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _memberShowDueMembersListMeta =
      const VerificationMeta('memberShowDueMembersList');
  @override
  late final GeneratedColumn<bool> memberShowDueMembersList =
      GeneratedColumn<bool>(
          'member_show_due_members_list', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("member_show_due_members_list" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _memberShowCoopCurrentMonthMeta =
      const VerificationMeta('memberShowCoopCurrentMonth');
  @override
  late final GeneratedColumn<bool> memberShowCoopCurrentMonth =
      GeneratedColumn<bool>(
          'member_show_coop_current_month', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("member_show_coop_current_month" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _tenantCoopIdMeta =
      const VerificationMeta('tenantCoopId');
  @override
  late final GeneratedColumn<String> tenantCoopId = GeneratedColumn<String>(
      'tenant_coop_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        defaultReceivedBy,
        receiptPrefix,
        nextReceiptSerial,
        language,
        themeMode,
        defaultMemberPassword,
        memberShowCoopTotalCollection,
        memberShowCoopTotalDue,
        memberShowDueMembersList,
        memberShowCoopCurrentMonth,
        tenantCoopId,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('default_received_by')) {
      context.handle(
          _defaultReceivedByMeta,
          defaultReceivedBy.isAcceptableOrUnknown(
              data['default_received_by']!, _defaultReceivedByMeta));
    } else if (isInserting) {
      context.missing(_defaultReceivedByMeta);
    }
    if (data.containsKey('receipt_prefix')) {
      context.handle(
          _receiptPrefixMeta,
          receiptPrefix.isAcceptableOrUnknown(
              data['receipt_prefix']!, _receiptPrefixMeta));
    }
    if (data.containsKey('next_receipt_serial')) {
      context.handle(
          _nextReceiptSerialMeta,
          nextReceiptSerial.isAcceptableOrUnknown(
              data['next_receipt_serial']!, _nextReceiptSerialMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('default_member_password')) {
      context.handle(
          _defaultMemberPasswordMeta,
          defaultMemberPassword.isAcceptableOrUnknown(
              data['default_member_password']!, _defaultMemberPasswordMeta));
    }
    if (data.containsKey('member_show_coop_total_collection')) {
      context.handle(
          _memberShowCoopTotalCollectionMeta,
          memberShowCoopTotalCollection.isAcceptableOrUnknown(
              data['member_show_coop_total_collection']!,
              _memberShowCoopTotalCollectionMeta));
    }
    if (data.containsKey('member_show_coop_total_due')) {
      context.handle(
          _memberShowCoopTotalDueMeta,
          memberShowCoopTotalDue.isAcceptableOrUnknown(
              data['member_show_coop_total_due']!,
              _memberShowCoopTotalDueMeta));
    }
    if (data.containsKey('member_show_due_members_list')) {
      context.handle(
          _memberShowDueMembersListMeta,
          memberShowDueMembersList.isAcceptableOrUnknown(
              data['member_show_due_members_list']!,
              _memberShowDueMembersListMeta));
    }
    if (data.containsKey('member_show_coop_current_month')) {
      context.handle(
          _memberShowCoopCurrentMonthMeta,
          memberShowCoopCurrentMonth.isAcceptableOrUnknown(
              data['member_show_coop_current_month']!,
              _memberShowCoopCurrentMonthMeta));
    }
    if (data.containsKey('tenant_coop_id')) {
      context.handle(
          _tenantCoopIdMeta,
          tenantCoopId.isAcceptableOrUnknown(
              data['tenant_coop_id']!, _tenantCoopIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      defaultReceivedBy: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_received_by'])!,
      receiptPrefix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receipt_prefix'])!,
      nextReceiptSerial: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}next_receipt_serial'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      defaultMemberPassword: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}default_member_password'])!,
      memberShowCoopTotalCollection: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}member_show_coop_total_collection'])!,
      memberShowCoopTotalDue: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}member_show_coop_total_due'])!,
      memberShowDueMembersList: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}member_show_due_members_list'])!,
      memberShowCoopCurrentMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}member_show_coop_current_month'])!,
      tenantCoopId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_coop_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingsData extends DataClass implements Insertable<SettingsData> {
  final int id;
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
  final String? tenantCoopId;
  final DateTime updatedAt;
  const SettingsData(
      {required this.id,
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
      this.tenantCoopId,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['default_received_by'] = Variable<String>(defaultReceivedBy);
    map['receipt_prefix'] = Variable<String>(receiptPrefix);
    map['next_receipt_serial'] = Variable<int>(nextReceiptSerial);
    map['language'] = Variable<String>(language);
    map['theme_mode'] = Variable<String>(themeMode);
    map['default_member_password'] = Variable<String>(defaultMemberPassword);
    map['member_show_coop_total_collection'] =
        Variable<bool>(memberShowCoopTotalCollection);
    map['member_show_coop_total_due'] = Variable<bool>(memberShowCoopTotalDue);
    map['member_show_due_members_list'] =
        Variable<bool>(memberShowDueMembersList);
    map['member_show_coop_current_month'] =
        Variable<bool>(memberShowCoopCurrentMonth);
    if (!nullToAbsent || tenantCoopId != null) {
      map['tenant_coop_id'] = Variable<String>(tenantCoopId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      defaultReceivedBy: Value(defaultReceivedBy),
      receiptPrefix: Value(receiptPrefix),
      nextReceiptSerial: Value(nextReceiptSerial),
      language: Value(language),
      themeMode: Value(themeMode),
      defaultMemberPassword: Value(defaultMemberPassword),
      memberShowCoopTotalCollection: Value(memberShowCoopTotalCollection),
      memberShowCoopTotalDue: Value(memberShowCoopTotalDue),
      memberShowDueMembersList: Value(memberShowDueMembersList),
      memberShowCoopCurrentMonth: Value(memberShowCoopCurrentMonth),
      tenantCoopId: tenantCoopId == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantCoopId),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsData(
      id: serializer.fromJson<int>(json['id']),
      defaultReceivedBy: serializer.fromJson<String>(json['defaultReceivedBy']),
      receiptPrefix: serializer.fromJson<String>(json['receiptPrefix']),
      nextReceiptSerial: serializer.fromJson<int>(json['nextReceiptSerial']),
      language: serializer.fromJson<String>(json['language']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      defaultMemberPassword:
          serializer.fromJson<String>(json['defaultMemberPassword']),
      memberShowCoopTotalCollection:
          serializer.fromJson<bool>(json['memberShowCoopTotalCollection']),
      memberShowCoopTotalDue:
          serializer.fromJson<bool>(json['memberShowCoopTotalDue']),
      memberShowDueMembersList:
          serializer.fromJson<bool>(json['memberShowDueMembersList']),
      memberShowCoopCurrentMonth:
          serializer.fromJson<bool>(json['memberShowCoopCurrentMonth']),
      tenantCoopId: serializer.fromJson<String?>(json['tenantCoopId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defaultReceivedBy': serializer.toJson<String>(defaultReceivedBy),
      'receiptPrefix': serializer.toJson<String>(receiptPrefix),
      'nextReceiptSerial': serializer.toJson<int>(nextReceiptSerial),
      'language': serializer.toJson<String>(language),
      'themeMode': serializer.toJson<String>(themeMode),
      'defaultMemberPassword': serializer.toJson<String>(defaultMemberPassword),
      'memberShowCoopTotalCollection':
          serializer.toJson<bool>(memberShowCoopTotalCollection),
      'memberShowCoopTotalDue': serializer.toJson<bool>(memberShowCoopTotalDue),
      'memberShowDueMembersList':
          serializer.toJson<bool>(memberShowDueMembersList),
      'memberShowCoopCurrentMonth':
          serializer.toJson<bool>(memberShowCoopCurrentMonth),
      'tenantCoopId': serializer.toJson<String?>(tenantCoopId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SettingsData copyWith(
          {int? id,
          String? defaultReceivedBy,
          String? receiptPrefix,
          int? nextReceiptSerial,
          String? language,
          String? themeMode,
          String? defaultMemberPassword,
          bool? memberShowCoopTotalCollection,
          bool? memberShowCoopTotalDue,
          bool? memberShowDueMembersList,
          bool? memberShowCoopCurrentMonth,
          Value<String?> tenantCoopId = const Value.absent(),
          DateTime? updatedAt}) =>
      SettingsData(
        id: id ?? this.id,
        defaultReceivedBy: defaultReceivedBy ?? this.defaultReceivedBy,
        receiptPrefix: receiptPrefix ?? this.receiptPrefix,
        nextReceiptSerial: nextReceiptSerial ?? this.nextReceiptSerial,
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
        defaultMemberPassword:
            defaultMemberPassword ?? this.defaultMemberPassword,
        memberShowCoopTotalCollection:
            memberShowCoopTotalCollection ?? this.memberShowCoopTotalCollection,
        memberShowCoopTotalDue:
            memberShowCoopTotalDue ?? this.memberShowCoopTotalDue,
        memberShowDueMembersList:
            memberShowDueMembersList ?? this.memberShowDueMembersList,
        memberShowCoopCurrentMonth:
            memberShowCoopCurrentMonth ?? this.memberShowCoopCurrentMonth,
        tenantCoopId:
            tenantCoopId.present ? tenantCoopId.value : this.tenantCoopId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingsData copyWithCompanion(SettingsCompanion data) {
    return SettingsData(
      id: data.id.present ? data.id.value : this.id,
      defaultReceivedBy: data.defaultReceivedBy.present
          ? data.defaultReceivedBy.value
          : this.defaultReceivedBy,
      receiptPrefix: data.receiptPrefix.present
          ? data.receiptPrefix.value
          : this.receiptPrefix,
      nextReceiptSerial: data.nextReceiptSerial.present
          ? data.nextReceiptSerial.value
          : this.nextReceiptSerial,
      language: data.language.present ? data.language.value : this.language,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      defaultMemberPassword: data.defaultMemberPassword.present
          ? data.defaultMemberPassword.value
          : this.defaultMemberPassword,
      memberShowCoopTotalCollection: data.memberShowCoopTotalCollection.present
          ? data.memberShowCoopTotalCollection.value
          : this.memberShowCoopTotalCollection,
      memberShowCoopTotalDue: data.memberShowCoopTotalDue.present
          ? data.memberShowCoopTotalDue.value
          : this.memberShowCoopTotalDue,
      memberShowDueMembersList: data.memberShowDueMembersList.present
          ? data.memberShowDueMembersList.value
          : this.memberShowDueMembersList,
      memberShowCoopCurrentMonth: data.memberShowCoopCurrentMonth.present
          ? data.memberShowCoopCurrentMonth.value
          : this.memberShowCoopCurrentMonth,
      tenantCoopId: data.tenantCoopId.present
          ? data.tenantCoopId.value
          : this.tenantCoopId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsData(')
          ..write('id: $id, ')
          ..write('defaultReceivedBy: $defaultReceivedBy, ')
          ..write('receiptPrefix: $receiptPrefix, ')
          ..write('nextReceiptSerial: $nextReceiptSerial, ')
          ..write('language: $language, ')
          ..write('themeMode: $themeMode, ')
          ..write('defaultMemberPassword: $defaultMemberPassword, ')
          ..write(
              'memberShowCoopTotalCollection: $memberShowCoopTotalCollection, ')
          ..write('memberShowCoopTotalDue: $memberShowCoopTotalDue, ')
          ..write('memberShowDueMembersList: $memberShowDueMembersList, ')
          ..write('memberShowCoopCurrentMonth: $memberShowCoopCurrentMonth, ')
          ..write('tenantCoopId: $tenantCoopId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      defaultReceivedBy,
      receiptPrefix,
      nextReceiptSerial,
      language,
      themeMode,
      defaultMemberPassword,
      memberShowCoopTotalCollection,
      memberShowCoopTotalDue,
      memberShowDueMembersList,
      memberShowCoopCurrentMonth,
      tenantCoopId,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsData &&
          other.id == this.id &&
          other.defaultReceivedBy == this.defaultReceivedBy &&
          other.receiptPrefix == this.receiptPrefix &&
          other.nextReceiptSerial == this.nextReceiptSerial &&
          other.language == this.language &&
          other.themeMode == this.themeMode &&
          other.defaultMemberPassword == this.defaultMemberPassword &&
          other.memberShowCoopTotalCollection ==
              this.memberShowCoopTotalCollection &&
          other.memberShowCoopTotalDue == this.memberShowCoopTotalDue &&
          other.memberShowDueMembersList == this.memberShowDueMembersList &&
          other.memberShowCoopCurrentMonth == this.memberShowCoopCurrentMonth &&
          other.tenantCoopId == this.tenantCoopId &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<SettingsData> {
  final Value<int> id;
  final Value<String> defaultReceivedBy;
  final Value<String> receiptPrefix;
  final Value<int> nextReceiptSerial;
  final Value<String> language;
  final Value<String> themeMode;
  final Value<String> defaultMemberPassword;
  final Value<bool> memberShowCoopTotalCollection;
  final Value<bool> memberShowCoopTotalDue;
  final Value<bool> memberShowDueMembersList;
  final Value<bool> memberShowCoopCurrentMonth;
  final Value<String?> tenantCoopId;
  final Value<DateTime> updatedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.defaultReceivedBy = const Value.absent(),
    this.receiptPrefix = const Value.absent(),
    this.nextReceiptSerial = const Value.absent(),
    this.language = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.defaultMemberPassword = const Value.absent(),
    this.memberShowCoopTotalCollection = const Value.absent(),
    this.memberShowCoopTotalDue = const Value.absent(),
    this.memberShowDueMembersList = const Value.absent(),
    this.memberShowCoopCurrentMonth = const Value.absent(),
    this.tenantCoopId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required String defaultReceivedBy,
    this.receiptPrefix = const Value.absent(),
    this.nextReceiptSerial = const Value.absent(),
    this.language = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.defaultMemberPassword = const Value.absent(),
    this.memberShowCoopTotalCollection = const Value.absent(),
    this.memberShowCoopTotalDue = const Value.absent(),
    this.memberShowDueMembersList = const Value.absent(),
    this.memberShowCoopCurrentMonth = const Value.absent(),
    this.tenantCoopId = const Value.absent(),
    required DateTime updatedAt,
  })  : defaultReceivedBy = Value(defaultReceivedBy),
        updatedAt = Value(updatedAt);
  static Insertable<SettingsData> custom({
    Expression<int>? id,
    Expression<String>? defaultReceivedBy,
    Expression<String>? receiptPrefix,
    Expression<int>? nextReceiptSerial,
    Expression<String>? language,
    Expression<String>? themeMode,
    Expression<String>? defaultMemberPassword,
    Expression<bool>? memberShowCoopTotalCollection,
    Expression<bool>? memberShowCoopTotalDue,
    Expression<bool>? memberShowDueMembersList,
    Expression<bool>? memberShowCoopCurrentMonth,
    Expression<String>? tenantCoopId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defaultReceivedBy != null) 'default_received_by': defaultReceivedBy,
      if (receiptPrefix != null) 'receipt_prefix': receiptPrefix,
      if (nextReceiptSerial != null) 'next_receipt_serial': nextReceiptSerial,
      if (language != null) 'language': language,
      if (themeMode != null) 'theme_mode': themeMode,
      if (defaultMemberPassword != null)
        'default_member_password': defaultMemberPassword,
      if (memberShowCoopTotalCollection != null)
        'member_show_coop_total_collection': memberShowCoopTotalCollection,
      if (memberShowCoopTotalDue != null)
        'member_show_coop_total_due': memberShowCoopTotalDue,
      if (memberShowDueMembersList != null)
        'member_show_due_members_list': memberShowDueMembersList,
      if (memberShowCoopCurrentMonth != null)
        'member_show_coop_current_month': memberShowCoopCurrentMonth,
      if (tenantCoopId != null) 'tenant_coop_id': tenantCoopId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? defaultReceivedBy,
      Value<String>? receiptPrefix,
      Value<int>? nextReceiptSerial,
      Value<String>? language,
      Value<String>? themeMode,
      Value<String>? defaultMemberPassword,
      Value<bool>? memberShowCoopTotalCollection,
      Value<bool>? memberShowCoopTotalDue,
      Value<bool>? memberShowDueMembersList,
      Value<bool>? memberShowCoopCurrentMonth,
      Value<String?>? tenantCoopId,
      Value<DateTime>? updatedAt}) {
    return SettingsCompanion(
      id: id ?? this.id,
      defaultReceivedBy: defaultReceivedBy ?? this.defaultReceivedBy,
      receiptPrefix: receiptPrefix ?? this.receiptPrefix,
      nextReceiptSerial: nextReceiptSerial ?? this.nextReceiptSerial,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      defaultMemberPassword:
          defaultMemberPassword ?? this.defaultMemberPassword,
      memberShowCoopTotalCollection:
          memberShowCoopTotalCollection ?? this.memberShowCoopTotalCollection,
      memberShowCoopTotalDue:
          memberShowCoopTotalDue ?? this.memberShowCoopTotalDue,
      memberShowDueMembersList:
          memberShowDueMembersList ?? this.memberShowDueMembersList,
      memberShowCoopCurrentMonth:
          memberShowCoopCurrentMonth ?? this.memberShowCoopCurrentMonth,
      tenantCoopId: tenantCoopId ?? this.tenantCoopId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defaultReceivedBy.present) {
      map['default_received_by'] = Variable<String>(defaultReceivedBy.value);
    }
    if (receiptPrefix.present) {
      map['receipt_prefix'] = Variable<String>(receiptPrefix.value);
    }
    if (nextReceiptSerial.present) {
      map['next_receipt_serial'] = Variable<int>(nextReceiptSerial.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (defaultMemberPassword.present) {
      map['default_member_password'] =
          Variable<String>(defaultMemberPassword.value);
    }
    if (memberShowCoopTotalCollection.present) {
      map['member_show_coop_total_collection'] =
          Variable<bool>(memberShowCoopTotalCollection.value);
    }
    if (memberShowCoopTotalDue.present) {
      map['member_show_coop_total_due'] =
          Variable<bool>(memberShowCoopTotalDue.value);
    }
    if (memberShowDueMembersList.present) {
      map['member_show_due_members_list'] =
          Variable<bool>(memberShowDueMembersList.value);
    }
    if (memberShowCoopCurrentMonth.present) {
      map['member_show_coop_current_month'] =
          Variable<bool>(memberShowCoopCurrentMonth.value);
    }
    if (tenantCoopId.present) {
      map['tenant_coop_id'] = Variable<String>(tenantCoopId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('defaultReceivedBy: $defaultReceivedBy, ')
          ..write('receiptPrefix: $receiptPrefix, ')
          ..write('nextReceiptSerial: $nextReceiptSerial, ')
          ..write('language: $language, ')
          ..write('themeMode: $themeMode, ')
          ..write('defaultMemberPassword: $defaultMemberPassword, ')
          ..write(
              'memberShowCoopTotalCollection: $memberShowCoopTotalCollection, ')
          ..write('memberShowCoopTotalDue: $memberShowCoopTotalDue, ')
          ..write('memberShowDueMembersList: $memberShowDueMembersList, ')
          ..write('memberShowCoopCurrentMonth: $memberShowCoopCurrentMonth, ')
          ..write('tenantCoopId: $tenantCoopId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $MembersTable members = $MembersTable(this);
  late final $DepositsTable deposits = $DepositsTable(this);
  late final $OrganizationTable organization = $OrganizationTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [members, deposits, organization, settings];
}

typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  Value<int> id,
  required String uuid,
  required String memberIdNumber,
  required String name,
  Value<String?> phone,
  Value<String?> phoneNormalized,
  Value<String?> pinHash,
  Value<String?> address,
  Value<String?> nidNumber,
  Value<String?> photoPath,
  required int monthlyAmount,
  Value<bool> isActive,
  Value<bool> canCollectDeposits,
  Value<DateTime?> deletedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> memberIdNumber,
  Value<String> name,
  Value<String?> phone,
  Value<String?> phoneNormalized,
  Value<String?> pinHash,
  Value<String?> address,
  Value<String?> nidNumber,
  Value<String?> photoPath,
  Value<int> monthlyAmount,
  Value<bool> isActive,
  Value<bool> canCollectDeposits,
  Value<DateTime?> deletedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$MembersTableFilterComposer extends Composer<_$AppDb, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberIdNumber => $composableBuilder(
      column: $table.memberIdNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNormalized => $composableBuilder(
      column: $table.phoneNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nidNumber => $composableBuilder(
      column: $table.nidNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlyAmount => $composableBuilder(
      column: $table.monthlyAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canCollectDeposits => $composableBuilder(
      column: $table.canCollectDeposits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MembersTableOrderingComposer extends Composer<_$AppDb, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberIdNumber => $composableBuilder(
      column: $table.memberIdNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNormalized => $composableBuilder(
      column: $table.phoneNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nidNumber => $composableBuilder(
      column: $table.nidNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlyAmount => $composableBuilder(
      column: $table.monthlyAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canCollectDeposits => $composableBuilder(
      column: $table.canCollectDeposits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDb, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get memberIdNumber => $composableBuilder(
      column: $table.memberIdNumber, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get phoneNormalized => $composableBuilder(
      column: $table.phoneNormalized, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get nidNumber =>
      $composableBuilder(column: $table.nidNumber, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get monthlyAmount => $composableBuilder(
      column: $table.monthlyAmount, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get canCollectDeposits => $composableBuilder(
      column: $table.canCollectDeposits, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MembersTableTableManager extends RootTableManager<
    _$AppDb,
    $MembersTable,
    Member,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (Member, BaseReferences<_$AppDb, $MembersTable, Member>),
    Member,
    PrefetchHooks Function()> {
  $$MembersTableTableManager(_$AppDb db, $MembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> memberIdNumber = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> phoneNormalized = const Value.absent(),
            Value<String?> pinHash = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> nidNumber = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<int> monthlyAmount = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> canCollectDeposits = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MembersCompanion(
            id: id,
            uuid: uuid,
            memberIdNumber: memberIdNumber,
            name: name,
            phone: phone,
            phoneNormalized: phoneNormalized,
            pinHash: pinHash,
            address: address,
            nidNumber: nidNumber,
            photoPath: photoPath,
            monthlyAmount: monthlyAmount,
            isActive: isActive,
            canCollectDeposits: canCollectDeposits,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String memberIdNumber,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> phoneNormalized = const Value.absent(),
            Value<String?> pinHash = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> nidNumber = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            required int monthlyAmount,
            Value<bool> isActive = const Value.absent(),
            Value<bool> canCollectDeposits = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              MembersCompanion.insert(
            id: id,
            uuid: uuid,
            memberIdNumber: memberIdNumber,
            name: name,
            phone: phone,
            phoneNormalized: phoneNormalized,
            pinHash: pinHash,
            address: address,
            nidNumber: nidNumber,
            photoPath: photoPath,
            monthlyAmount: monthlyAmount,
            isActive: isActive,
            canCollectDeposits: canCollectDeposits,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $MembersTable,
    Member,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (Member, BaseReferences<_$AppDb, $MembersTable, Member>),
    Member,
    PrefetchHooks Function()>;
typedef $$DepositsTableCreateCompanionBuilder = DepositsCompanion Function({
  Value<int> id,
  required String uuid,
  required String memberUuid,
  required DateTime date,
  required String monthKey,
  required int amount,
  Value<String?> reason,
  required String method,
  required String receivedBy,
  required int receiptSerial,
  Value<String?> receiptPdfPath,
  Value<DateTime?> deletedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$DepositsTableUpdateCompanionBuilder = DepositsCompanion Function({
  Value<int> id,
  Value<String> uuid,
  Value<String> memberUuid,
  Value<DateTime> date,
  Value<String> monthKey,
  Value<int> amount,
  Value<String?> reason,
  Value<String> method,
  Value<String> receivedBy,
  Value<int> receiptSerial,
  Value<String?> receiptPdfPath,
  Value<DateTime?> deletedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$DepositsTableFilterComposer extends Composer<_$AppDb, $DepositsTable> {
  $$DepositsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberUuid => $composableBuilder(
      column: $table.memberUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get monthKey => $composableBuilder(
      column: $table.monthKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receivedBy => $composableBuilder(
      column: $table.receivedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get receiptSerial => $composableBuilder(
      column: $table.receiptSerial, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptPdfPath => $composableBuilder(
      column: $table.receiptPdfPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DepositsTableOrderingComposer
    extends Composer<_$AppDb, $DepositsTable> {
  $$DepositsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberUuid => $composableBuilder(
      column: $table.memberUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get monthKey => $composableBuilder(
      column: $table.monthKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receivedBy => $composableBuilder(
      column: $table.receivedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get receiptSerial => $composableBuilder(
      column: $table.receiptSerial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptPdfPath => $composableBuilder(
      column: $table.receiptPdfPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DepositsTableAnnotationComposer
    extends Composer<_$AppDb, $DepositsTable> {
  $$DepositsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get memberUuid => $composableBuilder(
      column: $table.memberUuid, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get receivedBy => $composableBuilder(
      column: $table.receivedBy, builder: (column) => column);

  GeneratedColumn<int> get receiptSerial => $composableBuilder(
      column: $table.receiptSerial, builder: (column) => column);

  GeneratedColumn<String> get receiptPdfPath => $composableBuilder(
      column: $table.receiptPdfPath, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DepositsTableTableManager extends RootTableManager<
    _$AppDb,
    $DepositsTable,
    Deposit,
    $$DepositsTableFilterComposer,
    $$DepositsTableOrderingComposer,
    $$DepositsTableAnnotationComposer,
    $$DepositsTableCreateCompanionBuilder,
    $$DepositsTableUpdateCompanionBuilder,
    (Deposit, BaseReferences<_$AppDb, $DepositsTable, Deposit>),
    Deposit,
    PrefetchHooks Function()> {
  $$DepositsTableTableManager(_$AppDb db, $DepositsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepositsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepositsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepositsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> uuid = const Value.absent(),
            Value<String> memberUuid = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> monthKey = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> receivedBy = const Value.absent(),
            Value<int> receiptSerial = const Value.absent(),
            Value<String?> receiptPdfPath = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DepositsCompanion(
            id: id,
            uuid: uuid,
            memberUuid: memberUuid,
            date: date,
            monthKey: monthKey,
            amount: amount,
            reason: reason,
            method: method,
            receivedBy: receivedBy,
            receiptSerial: receiptSerial,
            receiptPdfPath: receiptPdfPath,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String uuid,
            required String memberUuid,
            required DateTime date,
            required String monthKey,
            required int amount,
            Value<String?> reason = const Value.absent(),
            required String method,
            required String receivedBy,
            required int receiptSerial,
            Value<String?> receiptPdfPath = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              DepositsCompanion.insert(
            id: id,
            uuid: uuid,
            memberUuid: memberUuid,
            date: date,
            monthKey: monthKey,
            amount: amount,
            reason: reason,
            method: method,
            receivedBy: receivedBy,
            receiptSerial: receiptSerial,
            receiptPdfPath: receiptPdfPath,
            deletedAt: deletedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DepositsTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $DepositsTable,
    Deposit,
    $$DepositsTableFilterComposer,
    $$DepositsTableOrderingComposer,
    $$DepositsTableAnnotationComposer,
    $$DepositsTableCreateCompanionBuilder,
    $$DepositsTableUpdateCompanionBuilder,
    (Deposit, BaseReferences<_$AppDb, $DepositsTable, Deposit>),
    Deposit,
    PrefetchHooks Function()>;
typedef $$OrganizationTableCreateCompanionBuilder = OrganizationCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> shortName,
  required String address,
  Value<String?> logoPath,
  Value<String?> signaturePath,
  required DateTime updatedAt,
});
typedef $$OrganizationTableUpdateCompanionBuilder = OrganizationCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> shortName,
  Value<String> address,
  Value<String?> logoPath,
  Value<String?> signaturePath,
  Value<DateTime> updatedAt,
});

class $$OrganizationTableFilterComposer
    extends Composer<_$AppDb, $OrganizationTable> {
  $$OrganizationTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$OrganizationTableOrderingComposer
    extends Composer<_$AppDb, $OrganizationTable> {
  $$OrganizationTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$OrganizationTableAnnotationComposer
    extends Composer<_$AppDb, $OrganizationTable> {
  $$OrganizationTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OrganizationTableTableManager extends RootTableManager<
    _$AppDb,
    $OrganizationTable,
    OrganizationData,
    $$OrganizationTableFilterComposer,
    $$OrganizationTableOrderingComposer,
    $$OrganizationTableAnnotationComposer,
    $$OrganizationTableCreateCompanionBuilder,
    $$OrganizationTableUpdateCompanionBuilder,
    (
      OrganizationData,
      BaseReferences<_$AppDb, $OrganizationTable, OrganizationData>
    ),
    OrganizationData,
    PrefetchHooks Function()> {
  $$OrganizationTableTableManager(_$AppDb db, $OrganizationTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrganizationTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrganizationTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> shortName = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<String?> signaturePath = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              OrganizationCompanion(
            id: id,
            name: name,
            shortName: shortName,
            address: address,
            logoPath: logoPath,
            signaturePath: signaturePath,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> shortName = const Value.absent(),
            required String address,
            Value<String?> logoPath = const Value.absent(),
            Value<String?> signaturePath = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              OrganizationCompanion.insert(
            id: id,
            name: name,
            shortName: shortName,
            address: address,
            logoPath: logoPath,
            signaturePath: signaturePath,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrganizationTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $OrganizationTable,
    OrganizationData,
    $$OrganizationTableFilterComposer,
    $$OrganizationTableOrderingComposer,
    $$OrganizationTableAnnotationComposer,
    $$OrganizationTableCreateCompanionBuilder,
    $$OrganizationTableUpdateCompanionBuilder,
    (
      OrganizationData,
      BaseReferences<_$AppDb, $OrganizationTable, OrganizationData>
    ),
    OrganizationData,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  required String defaultReceivedBy,
  Value<String> receiptPrefix,
  Value<int> nextReceiptSerial,
  Value<String> language,
  Value<String> themeMode,
  Value<String> defaultMemberPassword,
  Value<bool> memberShowCoopTotalCollection,
  Value<bool> memberShowCoopTotalDue,
  Value<bool> memberShowDueMembersList,
  Value<bool> memberShowCoopCurrentMonth,
  Value<String?> tenantCoopId,
  required DateTime updatedAt,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> defaultReceivedBy,
  Value<String> receiptPrefix,
  Value<int> nextReceiptSerial,
  Value<String> language,
  Value<String> themeMode,
  Value<String> defaultMemberPassword,
  Value<bool> memberShowCoopTotalCollection,
  Value<bool> memberShowCoopTotalDue,
  Value<bool> memberShowDueMembersList,
  Value<bool> memberShowCoopCurrentMonth,
  Value<String?> tenantCoopId,
  Value<DateTime> updatedAt,
});

class $$SettingsTableFilterComposer extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultReceivedBy => $composableBuilder(
      column: $table.defaultReceivedBy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptPrefix => $composableBuilder(
      column: $table.receiptPrefix, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nextReceiptSerial => $composableBuilder(
      column: $table.nextReceiptSerial,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultMemberPassword => $composableBuilder(
      column: $table.defaultMemberPassword,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get memberShowCoopTotalCollection => $composableBuilder(
      column: $table.memberShowCoopTotalCollection,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get memberShowCoopTotalDue => $composableBuilder(
      column: $table.memberShowCoopTotalDue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get memberShowDueMembersList => $composableBuilder(
      column: $table.memberShowDueMembersList,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get memberShowCoopCurrentMonth => $composableBuilder(
      column: $table.memberShowCoopCurrentMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantCoopId => $composableBuilder(
      column: $table.tenantCoopId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultReceivedBy => $composableBuilder(
      column: $table.defaultReceivedBy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptPrefix => $composableBuilder(
      column: $table.receiptPrefix,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nextReceiptSerial => $composableBuilder(
      column: $table.nextReceiptSerial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultMemberPassword => $composableBuilder(
      column: $table.defaultMemberPassword,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get memberShowCoopTotalCollection => $composableBuilder(
      column: $table.memberShowCoopTotalCollection,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get memberShowCoopTotalDue => $composableBuilder(
      column: $table.memberShowCoopTotalDue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get memberShowDueMembersList => $composableBuilder(
      column: $table.memberShowDueMembersList,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get memberShowCoopCurrentMonth => $composableBuilder(
      column: $table.memberShowCoopCurrentMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantCoopId => $composableBuilder(
      column: $table.tenantCoopId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDb, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get defaultReceivedBy => $composableBuilder(
      column: $table.defaultReceivedBy, builder: (column) => column);

  GeneratedColumn<String> get receiptPrefix => $composableBuilder(
      column: $table.receiptPrefix, builder: (column) => column);

  GeneratedColumn<int> get nextReceiptSerial => $composableBuilder(
      column: $table.nextReceiptSerial, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get defaultMemberPassword => $composableBuilder(
      column: $table.defaultMemberPassword, builder: (column) => column);

  GeneratedColumn<bool> get memberShowCoopTotalCollection => $composableBuilder(
      column: $table.memberShowCoopTotalCollection,
      builder: (column) => column);

  GeneratedColumn<bool> get memberShowCoopTotalDue => $composableBuilder(
      column: $table.memberShowCoopTotalDue, builder: (column) => column);

  GeneratedColumn<bool> get memberShowDueMembersList => $composableBuilder(
      column: $table.memberShowDueMembersList, builder: (column) => column);

  GeneratedColumn<bool> get memberShowCoopCurrentMonth => $composableBuilder(
      column: $table.memberShowCoopCurrentMonth, builder: (column) => column);

  GeneratedColumn<String> get tenantCoopId => $composableBuilder(
      column: $table.tenantCoopId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDb,
    $SettingsTable,
    SettingsData,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingsData, BaseReferences<_$AppDb, $SettingsTable, SettingsData>),
    SettingsData,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDb db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> defaultReceivedBy = const Value.absent(),
            Value<String> receiptPrefix = const Value.absent(),
            Value<int> nextReceiptSerial = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<String> defaultMemberPassword = const Value.absent(),
            Value<bool> memberShowCoopTotalCollection = const Value.absent(),
            Value<bool> memberShowCoopTotalDue = const Value.absent(),
            Value<bool> memberShowDueMembersList = const Value.absent(),
            Value<bool> memberShowCoopCurrentMonth = const Value.absent(),
            Value<String?> tenantCoopId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            defaultReceivedBy: defaultReceivedBy,
            receiptPrefix: receiptPrefix,
            nextReceiptSerial: nextReceiptSerial,
            language: language,
            themeMode: themeMode,
            defaultMemberPassword: defaultMemberPassword,
            memberShowCoopTotalCollection: memberShowCoopTotalCollection,
            memberShowCoopTotalDue: memberShowCoopTotalDue,
            memberShowDueMembersList: memberShowDueMembersList,
            memberShowCoopCurrentMonth: memberShowCoopCurrentMonth,
            tenantCoopId: tenantCoopId,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String defaultReceivedBy,
            Value<String> receiptPrefix = const Value.absent(),
            Value<int> nextReceiptSerial = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<String> defaultMemberPassword = const Value.absent(),
            Value<bool> memberShowCoopTotalCollection = const Value.absent(),
            Value<bool> memberShowCoopTotalDue = const Value.absent(),
            Value<bool> memberShowDueMembersList = const Value.absent(),
            Value<bool> memberShowCoopCurrentMonth = const Value.absent(),
            Value<String?> tenantCoopId = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              SettingsCompanion.insert(
            id: id,
            defaultReceivedBy: defaultReceivedBy,
            receiptPrefix: receiptPrefix,
            nextReceiptSerial: nextReceiptSerial,
            language: language,
            themeMode: themeMode,
            defaultMemberPassword: defaultMemberPassword,
            memberShowCoopTotalCollection: memberShowCoopTotalCollection,
            memberShowCoopTotalDue: memberShowCoopTotalDue,
            memberShowDueMembersList: memberShowDueMembersList,
            memberShowCoopCurrentMonth: memberShowCoopCurrentMonth,
            tenantCoopId: tenantCoopId,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $SettingsTable,
    SettingsData,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingsData, BaseReferences<_$AppDb, $SettingsTable, SettingsData>),
    SettingsData,
    PrefetchHooks Function()>;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$DepositsTableTableManager get deposits =>
      $$DepositsTableTableManager(_db, _db.deposits);
  $$OrganizationTableTableManager get organization =>
      $$OrganizationTableTableManager(_db, _db.organization);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
