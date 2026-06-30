import 'package:drift/drift.dart';
import '../../core/db/app_db.dart';
import '../../core/utils/date_utils.dart';

class CoopRepository {
  final AppDb db;
  CoopRepository(this.db);

  // ---------- Organization / Settings ----------
  Stream<OrganizationData> watchOrganization() =>
      (db.select(db.organization)..limit(1)).watchSingle();

  Stream<SettingsData> watchSettings() =>
      (db.select(db.settings)..limit(1)).watchSingle();

  Future<SettingsData> getSettings() async =>
      (db.select(db.settings)..limit(1)).getSingle();

  /// Generate receipt serial based on current date and time
  /// Format: YYYYMMDDHHMMSS (e.g., 20251224143025 for 2025-12-24 14:30:25)
  Future<int> generateReceiptSerialFromDateTime(DateTime dateTime) async {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    // Format: YYYYMMDDHHMMSS
    final serialString = '$year$month$day$hour$minute$second';
    return int.parse(serialString);
  }

  // Generate receipt serial based on current date and time
  Future<int> nextReceiptSerialAndIncrement() async {
    // Generate serial based on current date and time
    return await generateReceiptSerialFromDateTime(DateTime.now());
  }

  Future<void> updateOrganization({
    required String name,
    required String address,
    String? shortName,
    String? logoPath,
    String? signaturePath,
  }) async {
    await db.ensureSchemaReady();
    final org = await (db.select(db.organization)..limit(1)).getSingle();
    await (db.update(db.organization)..where((t) => t.id.equals(org.id))).write(
      OrganizationCompanion(
        name: Value(name),
        address: Value(address),
        shortName: Value(shortName),
        logoPath: Value(logoPath),
        signaturePath: Value(signaturePath),
        updatedAt: Value(DateTime.now()),
      ),
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
  }) async {
    final s = await getSettings();
    await (db.update(db.settings)..where((t) => t.id.equals(s.id))).write(
      SettingsCompanion(
        defaultReceivedBy: Value(defaultReceivedBy),
        receiptPrefix: Value(receiptPrefix),
        language: language != null ? Value(language) : const Value.absent(),
        defaultMemberPassword: defaultMemberPassword != null
            ? Value(defaultMemberPassword)
            : const Value.absent(),
        memberShowCoopTotalCollection: memberShowCoopTotalCollection != null
            ? Value(memberShowCoopTotalCollection)
            : const Value.absent(),
        memberShowCoopTotalDue: memberShowCoopTotalDue != null
            ? Value(memberShowCoopTotalDue)
            : const Value.absent(),
        memberShowDueMembersList: memberShowDueMembersList != null
            ? Value(memberShowDueMembersList)
            : const Value.absent(),
        memberShowCoopCurrentMonth: memberShowCoopCurrentMonth != null
            ? Value(memberShowCoopCurrentMonth)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateLanguage(String language) async {
    final s = await getSettings();
    await (db.update(db.settings)..where((t) => t.id.equals(s.id))).write(
      SettingsCompanion(
        language: Value(language),
      ),
    );
  }

  Future<void> updateThemeMode(String themeMode) async {
    final s = await getSettings();
    await (db.update(db.settings)..where((t) => t.id.equals(s.id))).write(
      SettingsCompanion(
        themeMode: Value(themeMode),
      ),
    );
  }

  // ---------- Members ----------
  Stream<List<Member>> watchActiveMembers({String? query}) {
    final trimmed = query?.trim();
    return Stream.fromFuture(db.ensureSchemaReady()).asyncExpand((_) {
      final q = db.select(db.members)
        ..where((m) {
          final active = m.deletedAt.isNull() & m.isActive.equals(true);
          if (trimmed == null || trimmed.isEmpty) return active;
          final pattern = '%$trimmed%';
          return active &
              (m.name.like(pattern) |
                  m.memberIdNumber.like(pattern) |
                  m.phone.like(pattern));
        })
        ..orderBy([(m) => OrderingTerm.asc(m.memberIdNumber)]);
      return q.watch();
    });
  }

  Stream<List<Member>> watchTrashedMembers() {
    return Stream.fromFuture(db.ensureSchemaReady()).asyncExpand((_) {
      final q = db.select(db.members)
        ..where((m) => m.deletedAt.isNotNull())
        ..orderBy([(m) => OrderingTerm.desc(m.deletedAt)]);
      return q.watch();
    });
  }

  Future<Member?> getMemberByUuid(String uuid) async {
    await db.ensureSchemaReady();
    final q = db.select(db.members)..where((m) => m.uuid.equals(uuid));
    final list = await q.get();
    return list.isEmpty ? null : list.first;
  }

  Future<Member?> getMemberByPhoneNormalized(String phoneNormalized) async {
    final q = db.select(db.members)
      ..where((m) =>
          m.phoneNormalized.equals(phoneNormalized) & m.deletedAt.isNull());
    final list = await q.get();
    return list.isEmpty ? null : list.first;
  }

  Future<bool> isPhoneTaken(String phoneNormalized, {String? excludeUuid}) async {
    final q = db.select(db.members)
      ..where((m) =>
          m.phoneNormalized.equals(phoneNormalized) & m.deletedAt.isNull());
    if (excludeUuid != null) {
      q.where((m) => m.uuid.equals(excludeUuid).not());
    }
    final list = await q.get();
    return list.isNotEmpty;
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
    final now = DateTime.now();
    await db.into(db.members).insert(MembersCompanion.insert(
          uuid: uuid,
          memberIdNumber: memberIdNumber,
          name: name,
          phone: Value(phone),
          phoneNormalized: Value(phoneNormalized),
          address: Value(address),
          nidNumber: Value(nidNumber),
          photoPath: Value(photoPath),
          monthlyAmount: monthlyAmount,
          canCollectDeposits: Value(canCollectDeposits),
          createdAt: now,
          updatedAt: now,
        ));
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
    final now = DateTime.now();
    await (db.update(db.members)..where((m) => m.uuid.equals(uuid))).write(
      MembersCompanion(
        memberIdNumber: memberIdNumber != null
            ? Value(memberIdNumber)
            : const Value.absent(),
        name: name != null ? Value(name) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        phoneNormalized: phoneNormalized != null
            ? Value(phoneNormalized)
            : const Value.absent(),
        address: address != null ? Value(address) : const Value.absent(),
        nidNumber: nidNumber != null ? Value(nidNumber) : const Value.absent(),
        photoPath: Value(photoPath),
        monthlyAmount:
            monthlyAmount != null ? Value(monthlyAmount) : const Value.absent(),
        canCollectDeposits: canCollectDeposits != null
            ? Value(canCollectDeposits)
            : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> softDeleteMember(String uuid) async {
    final now = DateTime.now();
    // Soft delete the member
    await (db.update(db.members)..where((m) => m.uuid.equals(uuid))).write(
      MembersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    // Also soft delete all deposits associated with this member
    await (db.update(db.deposits)
          ..where((d) => d.memberUuid.equals(uuid) & d.deletedAt.isNull()))
        .write(
      DepositsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> restoreMember(String uuid) async {
    final now = DateTime.now();
    // Restore the member
    await (db.update(db.members)..where((m) => m.uuid.equals(uuid))).write(
      MembersCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
    // Also restore all deposits associated with this member that were soft deleted
    await (db.update(db.deposits)
          ..where((d) => d.memberUuid.equals(uuid) & d.deletedAt.isNotNull()))
        .write(
      DepositsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> permanentlyDeleteMember(String uuid) async {
    // Also permanently delete deposits of this member (including trashed)
    await (db.delete(db.deposits)..where((d) => d.memberUuid.equals(uuid)))
        .go();
    await (db.delete(db.members)..where((m) => m.uuid.equals(uuid))).go();
  }

  // ---------- Deposits ----------
  Stream<List<Deposit>> watchLastDeposits({int limit = 5}) {
    final q = db.select(db.deposits)
      ..where((d) => d.deletedAt.isNull())
      ..orderBy(
          [(d) => OrderingTerm.desc(d.date), (d) => OrderingTerm.desc(d.id)])
      ..limit(limit);
    return q.watch();
  }

  Stream<List<Deposit>> watchMemberDeposits(String memberUuid) {
    final q = db.select(db.deposits)
      ..where((d) => d.deletedAt.isNull() & d.memberUuid.equals(memberUuid))
      ..orderBy(
          [(d) => OrderingTerm.desc(d.date), (d) => OrderingTerm.desc(d.id)]);
    return q.watch();
  }

  Stream<List<Deposit>> watchRecentDepositsForMember(
    String memberUuid, {
    int limit = 5,
  }) {
    return watchMemberDeposits(memberUuid).map(
      (deposits) => deposits.take(limit).toList(),
    );
  }

  Stream<List<Deposit>> watchTrashedDeposits() {
    final q = db.select(db.deposits)
      ..where((d) => d.deletedAt.isNotNull())
      ..orderBy([(d) => OrderingTerm.desc(d.deletedAt)]);
    return q.watch();
  }

  Future<Deposit?> getDepositByUuid(String uuid) async {
    final q = db.select(db.deposits)..where((d) => d.uuid.equals(uuid));
    final list = await q.get();
    return list.isEmpty ? null : list.first;
  }

  Future<void> updateDepositReceiptPath(String depositUuid, String path) async {
    await (db.update(db.deposits)..where((d) => d.uuid.equals(depositUuid)))
        .write(
      DepositsCompanion(
        receiptPdfPath: Value(path),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Check if deposits already exist for a member for the given monthKeys
  /// Returns a list of monthKeys that already have deposits
  /// excludeDepositUuid: if provided, excludes this deposit from the check (useful when updating)
  ///
  /// Note: Also checks the reason field for multi-month deposits (e.g., "January to March")
  /// to prevent duplicate deposits for any month in the range
  Future<List<String>> checkExistingDepositsForMonths({
    required String memberUuid,
    required List<String> monthKeys,
    String? excludeDepositUuid,
  }) async {
    if (monthKeys.isEmpty) return [];

    final deposits = await (db.select(db.deposits)
          ..where(
              (d) => d.deletedAt.isNull() & d.memberUuid.equals(memberUuid)))
        .get();

    // Filter out excluded deposit if provided
    final filteredDeposits = excludeDepositUuid != null
        ? deposits.where((d) => d.uuid != excludeDepositUuid).toList()
        : deposits;

    // Get all monthKeys that have deposits (either directly or through multi-month deposits)
    final existingMonthKeys = <String>{};
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    for (final deposit in filteredDeposits) {
      // Add the stored monthKey
      existingMonthKeys.add(deposit.monthKey);

      // If reason contains "to", it's a multi-month deposit - parse all months
      if (deposit.reason != null &&
          deposit.reason!.toLowerCase().contains(' to ')) {
        final parts = deposit.reason!.split(' to ');
        if (parts.length == 2) {
          final fromMonth = parts[0].trim();
          final toMonth = parts[1].trim();

          final fromIndex = monthNames.indexOf(fromMonth);
          final toIndex = monthNames.indexOf(toMonth);

          if (fromIndex >= 0 && toIndex >= fromIndex) {
            // Extract year from the stored monthKey
            final year = deposit.monthKey.split('-')[0];

            // Add all months in the range
            for (int i = fromIndex; i <= toIndex; i++) {
              final month = (i + 1).toString().padLeft(2, '0');
              existingMonthKeys.add('$year-$month');
            }
          }
        }
      }
    }

    return monthKeys.where((mk) => existingMonthKeys.contains(mk)).toList();
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
    final now = DateTime.now();
    final mk = monthKeyOverride ?? monthKey(date);

    // Check for duplicate deposits for this month
    final existing = await checkExistingDepositsForMonths(
      memberUuid: memberUuid,
      monthKeys: [mk],
    );

    if (existing.isNotEmpty) {
      throw Exception(
          'এই মাসের জন্য ইতিমধ্যে ডিপোজিট করা হয়েছে (${monthKeyToName(mk)})। একই মাসের জন্য একাধিক ডিপোজিট করা যাবে না।');
    }

    await db.into(db.deposits).insert(DepositsCompanion.insert(
          uuid: uuid,
          memberUuid: memberUuid,
          date: date,
          monthKey: mk,
          amount: amount,
          reason: Value(reason),
          method: method,
          receivedBy: receivedBy,
          receiptSerial: receiptSerial,
          createdAt: now,
          updatedAt: now,
        ));
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
    final now = DateTime.now();

    // Get the current deposit to find memberUuid
    final currentDeposit = await getDepositByUuid(uuid);
    if (currentDeposit == null) {
      throw Exception('Deposit not found');
    }

    // Determine the new monthKey
    final newMonthKey = monthKeyOverride ??
        (date != null ? monthKey(date) : currentDeposit.monthKey);

    // Only check for duplicates if monthKey is changing
    if (newMonthKey != currentDeposit.monthKey) {
      final existing = await checkExistingDepositsForMonths(
        memberUuid: currentDeposit.memberUuid,
        monthKeys: [newMonthKey],
        excludeDepositUuid: uuid, // Exclude current deposit from check
      );

      if (existing.isNotEmpty) {
        throw Exception(
            'এই মাসের জন্য ইতিমধ্যে ডিপোজিট করা হয়েছে (${monthKeyToName(newMonthKey)})। একই মাসের জন্য একাধিক ডিপোজিট করা যাবে না।');
      }
    }

    await (db.update(db.deposits)..where((d) => d.uuid.equals(uuid))).write(
      DepositsCompanion(
        date: date != null ? Value(date) : const Value.absent(),
        monthKey: monthKeyOverride != null
            ? Value(monthKeyOverride)
            : (date != null ? Value(monthKey(date)) : const Value.absent()),
        amount: amount != null ? Value(amount) : const Value.absent(),
        reason: reason != null ? Value(reason) : const Value.absent(),
        method: method != null ? Value(method) : const Value.absent(),
        receivedBy:
            receivedBy != null ? Value(receivedBy) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> softDeleteDeposit(String uuid) async {
    await (db.update(db.deposits)..where((d) => d.uuid.equals(uuid))).write(
      DepositsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreDeposit(String uuid) async {
    await (db.update(db.deposits)..where((d) => d.uuid.equals(uuid))).write(
      DepositsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> permanentlyDeleteDeposit(String uuid) async {
    await (db.delete(db.deposits)..where((d) => d.uuid.equals(uuid))).go();
  }

  // ---------- Aggregations / Reports ----------
  Future<int> totalCollectionAllTime() async {
    final expr = db.deposits.amount.sum();
    final q = db.selectOnly(db.deposits)
      ..addColumns([expr])
      ..where(db.deposits.deletedAt.isNull());
    final row = await q.getSingle();
    return row.read(expr) ?? 0;
  }

  Future<int> collectionForMonth(String mKey) async {
    // Get all deposits and calculate collection for the specific month
    // This handles multi-month deposits correctly by distributing amount across months
    final rows = await (db.select(db.deposits)
          ..where((d) => d.deletedAt.isNull()))
        .get();

    int total = 0;
    for (final d in rows) {
      // Parse deposit months (handles multi-month deposits like "January to March")
      final depositMonths = _parseDepositMonths(d.reason, d.monthKey);

      // Check if this deposit covers the requested month
      if (depositMonths.contains(mKey)) {
        // Distribute deposit amount equally across all months in the range
        final amountPerMonth = d.amount ~/ depositMonths.length;
        total += amountPerMonth;
      }
    }

    return total;
  }

  Future<Map<String, int>> collectionByMonth() async {
    // Get all deposits and calculate collection for each month
    // This handles multi-month deposits correctly by distributing amount across months
    final rows = await (db.select(db.deposits)
          ..where((d) => d.deletedAt.isNull()))
        .get();

    final map = <String, int>{};
    for (final d in rows) {
      // Parse deposit months (handles multi-month deposits like "January to March")
      final depositMonths = _parseDepositMonths(d.reason, d.monthKey);

      // Distribute deposit amount equally across all months in the range
      final amountPerMonth = d.amount ~/ depositMonths.length;

      // Add amount to each month covered by this deposit
      for (final mk in depositMonths) {
        map[mk] = (map[mk] ?? 0) + amountPerMonth;
      }
    }

    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  Future<int> collectionForYear(int year) async {
    // Filter by monthKey starting with the year (e.g., "2025-")
    // This ensures deposits are counted for the month they are FOR, not when they were made
    final yearPrefix = '$year-';
    final rows = await (db.select(db.deposits)
          ..where(
              (d) => d.deletedAt.isNull() & d.monthKey.like('$yearPrefix%')))
        .get();

    int total = 0;
    for (final d in rows) {
      // Parse deposit months (handles multi-month deposits like "January to March")
      final depositMonths = _parseDepositMonths(d.reason, d.monthKey);

      // Only count months that belong to the requested year
      final yearMonths =
          depositMonths.where((mk) => mk.startsWith(yearPrefix)).toList();

      if (yearMonths.isNotEmpty) {
        // Distribute deposit amount equally across all months in the range
        final amountPerMonth = d.amount ~/ depositMonths.length;
        // Add the portion for this year's months
        total += amountPerMonth * yearMonths.length;
      }
    }

    return total;
  }

  Future<Map<String, int>> collectionByMonthForYear(int year) async {
    // Filter by monthKey starting with the year (e.g., "2025-")
    // This ensures deposits are counted for the month they are FOR, not when they were made
    final yearPrefix = '$year-';
    final rows = await (db.select(db.deposits)
          ..where(
              (d) => d.deletedAt.isNull() & d.monthKey.like('$yearPrefix%')))
        .get();

    final map = <String, int>{};
    for (final d in rows) {
      // Parse deposit months (handles multi-month deposits like "January to March")
      final depositMonths = _parseDepositMonths(d.reason, d.monthKey);

      // Only include months that belong to the requested year
      final yearMonths =
          depositMonths.where((mk) => mk.startsWith(yearPrefix)).toList();

      if (yearMonths.isNotEmpty) {
        // Distribute deposit amount equally across all months in the range
        final amountPerMonth = d.amount ~/ depositMonths.length;

        // Add amount to each month in the year
        for (final mk in yearMonths) {
          map[mk] = (map[mk] ?? 0) + amountPerMonth;
        }
      }
    }

    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  /// Helper function to parse reason field and get all monthKeys covered by a deposit
  /// Returns list of monthKeys for multi-month deposits (e.g., "January to March" -> ["2025-01", "2025-02", "2025-03"])
  List<String> _parseDepositMonths(String? reason, String monthKey) {
    if (reason == null || reason.trim().isEmpty) {
      return [monthKey]; // Single month deposit
    }

    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Check if it's a multi-month deposit (e.g., "January to March")
    if (reason.toLowerCase().contains(' to ')) {
      final parts = reason.split(' to ');
      if (parts.length == 2) {
        final fromMonth = parts[0].trim();
        final toMonth = parts[1].trim();

        final fromIndex = monthNames.indexOf(fromMonth);
        final toIndex = monthNames.indexOf(toMonth);

        if (fromIndex >= 0 && toIndex >= fromIndex) {
          // Extract year from monthKey
          final year = monthKey.split('-')[0];
          final monthKeys = <String>[];

          // Generate all monthKeys in the range
          for (int i = fromIndex; i <= toIndex; i++) {
            final month = (i + 1).toString().padLeft(2, '0');
            monthKeys.add('$year-$month');
          }
          return monthKeys;
        }
      }
    }

    // Single month deposit or couldn't parse
    return [monthKey];
  }

  /// Due rule:
  /// expected = member.monthlyAmount per month
  /// paid = sum deposits for that month (considering multi-month deposits)
  /// due = max(expected - paid, 0)
  Future<Map<String, dynamic>> dueSummaryAllMembers({
    required DateTime start,
    required DateTime endInclusive,
  }) async {
    final members = await (db.select(db.members)
          ..where((m) => m.deletedAt.isNull() & m.isActive.equals(true)))
        .get();
    final deposits = await (db.select(db.deposits)
          ..where((d) => d.deletedAt.isNull()))
        .get();

    final paidByMemberMonth = <String, Map<String, int>>{};
    for (final d in deposits) {
      final mm =
          paidByMemberMonth.putIfAbsent(d.memberUuid, () => <String, int>{});

      // Parse deposit months (handles multi-month deposits)
      final depositMonths = _parseDepositMonths(d.reason, d.monthKey);

      // Distribute deposit amount across months
      // For multi-month deposits, divide amount equally among months
      final amountPerMonth = d.amount ~/ depositMonths.length;

      for (final mk in depositMonths) {
        mm[mk] = (mm[mk] ?? 0) + amountPerMonth;
      }
    }

    final months = monthKeysBetweenInclusive(start, endInclusive);

    int totalDue = 0;
    final memberDueDetails = <Map<String, dynamic>>[];
    for (final m in members) {
      final dueMonths = <String, int>{};
      for (final mk in months) {
        final paid = paidByMemberMonth[m.uuid]?[mk] ?? 0;
        final due = m.monthlyAmount - paid;
        if (due > 0) dueMonths[mk] = due;
      }
      final memberDue = dueMonths.values.fold<int>(0, (a, b) => a + b);
      totalDue += memberDue;
      memberDueDetails.add({
        'member': m,
        'totalDue': memberDue,
        'dueMonths': dueMonths,
      });
    }

    memberDueDetails
        .sort((a, b) => (b['totalDue'] as int).compareTo(a['totalDue'] as int));

    return {
      'totalDue': totalDue,
      'members': memberDueDetails,
      'months': months,
    };
  }

  Future<Map<String, dynamic>> dueForOneMember({
    required String memberUuid,
    required DateTime start,
    required DateTime endInclusive,
  }) async {
    final m = await getMemberByUuid(memberUuid);
    if (m == null) {
      return {'totalDue': 0, 'dueMonths': <String, int>{}};
    }

    final deposits = await (db.select(db.deposits)
          ..where(
              (d) => d.deletedAt.isNull() & d.memberUuid.equals(memberUuid)))
        .get();

    final paidByMonth = <String, int>{};
    for (final d in deposits) {
      // Parse deposit months (handles multi-month deposits)
      final depositMonths = _parseDepositMonths(d.reason, d.monthKey);

      // Distribute deposit amount across months
      // For multi-month deposits, divide amount equally among months
      final amountPerMonth = d.amount ~/ depositMonths.length;

      for (final mk in depositMonths) {
        paidByMonth[mk] = (paidByMonth[mk] ?? 0) + amountPerMonth;
      }
    }

    final months = monthKeysBetweenInclusive(start, endInclusive);
    final dueMonths = <String, int>{};
    for (final mk in months) {
      final paid = paidByMonth[mk] ?? 0;
      final due = m.monthlyAmount - paid;
      if (due > 0) dueMonths[mk] = due;
    }
    final totalDue = dueMonths.values.fold<int>(0, (a, b) => a + b);
    return {
      'totalDue': totalDue,
      'dueMonths': dueMonths,
      'months': months,
      'member': m
    };
  }

  /// Get members who paid for a specific month
  Future<List<Map<String, dynamic>>> getPaidMembersForMonth(
      String monthKey) async {
    final members = await (db.select(db.members)
          ..where((m) => m.deletedAt.isNull() & m.isActive.equals(true)))
        .get();
    final deposits = await (db.select(db.deposits)
          ..where((d) => d.deletedAt.isNull()))
        .get();

    final paidByMember = <String, int>{};
    for (final d in deposits) {
      // Parse deposit months (handles multi-month deposits)
      final depositMonths = _parseDepositMonths(d.reason, d.monthKey);

      // Check if this deposit covers the requested month
      if (depositMonths.contains(monthKey)) {
        // Distribute deposit amount equally across all months in the range
        final amountPerMonth = d.amount ~/ depositMonths.length;
        paidByMember[d.memberUuid] =
            (paidByMember[d.memberUuid] ?? 0) + amountPerMonth;
      }
    }

    final paidMembers = <Map<String, dynamic>>[];
    for (final m in members) {
      final paid = paidByMember[m.uuid] ?? 0;
      if (paid > 0) {
        paidMembers.add({
          'member': m,
          'paid': paid,
          'expected': m.monthlyAmount,
        });
      }
    }

    // Sort by name
    paidMembers.sort((a, b) =>
        (a['member'] as Member).name.compareTo((b['member'] as Member).name));

    return paidMembers;
  }

  /// Get members who didn't pay (or paid less) for a specific month
  Future<List<Map<String, dynamic>>> getUnpaidMembersForMonth(
      String monthKey) async {
    final members = await (db.select(db.members)
          ..where((m) => m.deletedAt.isNull() & m.isActive.equals(true)))
        .get();
    final deposits = await (db.select(db.deposits)
          ..where((d) => d.deletedAt.isNull()))
        .get();

    final paidByMember = <String, int>{};
    for (final d in deposits) {
      // Parse deposit months (handles multi-month deposits)
      final depositMonths = _parseDepositMonths(d.reason, d.monthKey);

      // Check if this deposit covers the requested month
      if (depositMonths.contains(monthKey)) {
        // Distribute deposit amount equally across all months in the range
        final amountPerMonth = d.amount ~/ depositMonths.length;
        paidByMember[d.memberUuid] =
            (paidByMember[d.memberUuid] ?? 0) + amountPerMonth;
      }
    }

    final unpaidMembers = <Map<String, dynamic>>[];
    for (final m in members) {
      final paid = paidByMember[m.uuid] ?? 0;
      final due = m.monthlyAmount - paid;
      if (due > 0) {
        unpaidMembers.add({
          'member': m,
          'paid': paid,
          'expected': m.monthlyAmount,
          'due': due,
        });
      }
    }

    // Sort by due amount (highest first)
    unpaidMembers.sort((a, b) => (b['due'] as int).compareTo(a['due'] as int));

    return unpaidMembers;
  }

  Future<List<Member>> getAllMembers({bool includeTrashed = false}) async {
    final members = await db.select(db.members).get();
    if (includeTrashed) return members;
    return members.where((m) => m.deletedAt == null).toList();
  }

  Future<List<Deposit>> getAllDeposits({
    bool includeTrashed = false,
    String? memberUuid,
  }) async {
    var deposits = await db.select(db.deposits).get();
    if (memberUuid != null) {
      deposits = deposits.where((d) => d.memberUuid == memberUuid).toList();
    }
    if (!includeTrashed) {
      deposits = deposits.where((d) => d.deletedAt == null).toList();
    }
    return deposits;
  }
}
