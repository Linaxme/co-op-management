import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_db.g.dart';

class Members extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get memberIdNumber => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get phoneNormalized => text().nullable().unique()();
  TextColumn get pinHash => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get nidNumber => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get monthlyAmount => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get canCollectDeposits =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Deposits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get memberUuid => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get monthKey => text()(); // yyyy-MM
  IntColumn get amount => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get method => text()(); // cash, bkash, nagad, bank
  TextColumn get receivedBy => text()();
  IntColumn get receiptSerial => integer()();
  TextColumn get receiptPdfPath => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Organization extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get shortName => text().nullable()();
  TextColumn get address => text()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get signaturePath => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('SettingsData')
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get defaultReceivedBy => text()();
  TextColumn get receiptPrefix => text().withDefault(const Constant('RCPT'))();
  IntColumn get nextReceiptSerial => integer().withDefault(const Constant(1))();
  TextColumn get language =>
      text().withDefault(const Constant('en'))(); // 'en' or 'bn'
  TextColumn get themeMode => text()
      .withDefault(const Constant('system'))(); // 'light', 'dark', or 'system'
  TextColumn get defaultMemberPassword =>
      text().withDefault(const Constant('123456'))();
  BoolColumn get memberShowCoopTotalCollection =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get memberShowCoopTotalDue =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get memberShowDueMembersList =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get memberShowCoopCurrentMonth =>
      boolean().withDefault(const Constant(true))();
  TextColumn get tenantCoopId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Members, Deposits, Organization, Settings])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add language column to Settings table
          await migrator.addColumn(settings, settings.language);
        }
        if (from < 3) {
          // Add indexes for performance optimization
          await migrator.createIndex(Index('idx_members_deleted_at',
              'CREATE INDEX idx_members_deleted_at ON members(deleted_at)'));
          await migrator.createIndex(Index('idx_members_is_active',
              'CREATE INDEX idx_members_is_active ON members(is_active)'));
          await migrator.createIndex(Index('idx_deposits_member_uuid',
              'CREATE INDEX idx_deposits_member_uuid ON deposits(member_uuid)'));
          await migrator.createIndex(Index('idx_deposits_deleted_at',
              'CREATE INDEX idx_deposits_deleted_at ON deposits(deleted_at)'));
          await migrator.createIndex(Index('idx_deposits_month_key',
              'CREATE INDEX idx_deposits_month_key ON deposits(month_key)'));
          await migrator.createIndex(Index('idx_deposits_date',
              'CREATE INDEX idx_deposits_date ON deposits(date)'));
        }
        if (from < 4) {
          // Add themeMode column to Settings table
          await migrator.addColumn(settings, settings.themeMode);
        }
        if (from < 5) {
          await migrator.addColumn(members, members.phoneNormalized);
          await migrator.addColumn(members, members.pinHash);
          await migrator.createIndex(Index(
            'idx_members_phone_normalized',
            'CREATE UNIQUE INDEX idx_members_phone_normalized ON members(phone_normalized) WHERE phone_normalized IS NOT NULL',
          ));
          final rows = await customSelect(
            'SELECT id, phone FROM members WHERE phone IS NOT NULL AND phone != ""',
          ).get();
          for (final row in rows) {
            final id = row.read<int>('id');
            final phone = row.read<String>('phone');
            final normalized = _normalizePhoneForMigration(phone);
            if (normalized != null) {
              await customStatement(
                'UPDATE members SET phone_normalized = ? WHERE id = ?',
                [Variable<String>(normalized), Variable<int>(id)],
              );
            }
          }
        }
        if (from < 6) {
          await migrator.addColumn(settings, settings.defaultMemberPassword);
        }
        if (from < 7) {
          await migrator.addColumn(
              settings, settings.memberShowCoopTotalCollection);
          await migrator.addColumn(settings, settings.memberShowCoopTotalDue);
          await migrator.addColumn(settings, settings.memberShowDueMembersList);
          await _backfillMemberDashboardSettings();
        }
        if (from < 8) {
          await migrator.addColumn(
              settings, settings.memberShowCoopCurrentMonth);
          await _backfillMemberDashboardSettings();
        }
        if (from < 9) {
          await migrator.addColumn(settings, settings.tenantCoopId);
        }
        if (from < 10) {
          await migrator.addColumn(organization, organization.shortName);
        }
        if (from < 11) {
          await _ensureOrganizationShortNameColumn();
        }
        if (from < 12) {
          await migrator.addColumn(members, members.canCollectDeposits);
        }
      },
      beforeOpen: (details) async {
        await _ensureOrganizationShortNameColumn();
        await _ensureCanCollectDepositsColumn();
        await _backfillMemberDashboardSettings();
        // Create indexes if they don't exist (for fresh installs)
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_members_deleted_at ON members(deleted_at)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_members_is_active ON members(is_active)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_deposits_member_uuid ON deposits(member_uuid)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_deposits_deleted_at ON deposits(deleted_at)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_deposits_month_key ON deposits(month_key)');
        await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_deposits_date ON deposits(date)');
      },
    );
  }

  static String? _normalizePhoneForMigration(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    var d = digits;
    if (d.startsWith('880')) d = d.substring(3);
    if (d.length == 10 && !d.startsWith('0')) d = '0$d';
    if (d.length == 11 && d.startsWith('01')) return d;
    return null;
  }

  Future<void> _backfillMemberDashboardSettings() async {
    await customStatement(
      'UPDATE settings SET member_show_coop_total_collection = 1 '
      'WHERE member_show_coop_total_collection IS NULL',
    );
    await customStatement(
      'UPDATE settings SET member_show_coop_total_due = 1 '
      'WHERE member_show_coop_total_due IS NULL',
    );
    await customStatement(
      'UPDATE settings SET member_show_due_members_list = 1 '
      'WHERE member_show_due_members_list IS NULL',
    );
    await customStatement(
      'UPDATE settings SET member_show_coop_current_month = 1 '
      'WHERE member_show_coop_current_month IS NULL',
    );
    await customStatement(
      "UPDATE settings SET default_member_password = '123456' "
      "WHERE default_member_password IS NULL OR default_member_password = ''",
    );
  }

  /// Web/IndexedDB can skip migrations — repair columns here.
  Future<void> ensureSchemaReady() async {
    await _ensureOrganizationShortNameColumn();
    await _ensureCanCollectDepositsColumn();
  }

  Future<void> _ensureOrganizationShortNameColumn() async {
    try {
      await customStatement(
        'ALTER TABLE organization ADD COLUMN short_name TEXT',
      );
    } catch (_) {
      // Column already exists.
    }
  }

  Future<void> _ensureCanCollectDepositsColumn() async {
    try {
      await customStatement(
        'ALTER TABLE members ADD COLUMN can_collect_deposits INTEGER NOT NULL DEFAULT 0',
      );
    } catch (_) {
      // Column already exists.
    }
    await customStatement(
      'UPDATE members SET can_collect_deposits = 0 '
      'WHERE can_collect_deposits IS NULL',
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'coop_app',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  Future<String?> getStoredTenantCoopId() async {
    final row = await (select(settings)..limit(1)).getSingleOrNull();
    return row?.tenantCoopId;
  }

  Future<void> setStoredTenantCoopId(String coopId) async {
    final row = await (select(settings)..limit(1)).getSingleOrNull();
    if (row == null) {
      await into(settings).insert(SettingsCompanion.insert(
        defaultReceivedBy: 'Admin',
        tenantCoopId: Value(coopId),
        updatedAt: DateTime.now(),
      ));
    } else {
      await (update(settings)..where((t) => t.id.equals(row.id))).write(
        SettingsCompanion(
          tenantCoopId: Value(coopId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> clearTenantData() async {
    await delete(members).go();
    await delete(deposits).go();
    await delete(organization).go();
    await (delete(settings)).go();
  }

  Future<void> seedIfNeeded() async {
    await ensureSchemaReady();
    final orgRow = await (select(organization)..limit(1)).get();
    if (orgRow.isEmpty) {
      await into(organization).insert(OrganizationCompanion.insert(
        name: 'My Cooperative Society',
        address: 'Address here',
        updatedAt: DateTime.now(),
      ));
    }
    final sRow = await (select(settings)..limit(1)).get();
    if (sRow.isEmpty) {
      await into(settings).insert(SettingsCompanion.insert(
        defaultReceivedBy: 'Admin',
        themeMode: const Value('system'),
        updatedAt: DateTime.now(),
      ));
    }
  }
}
