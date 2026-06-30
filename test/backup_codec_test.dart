import 'package:flutter_test/flutter_test.dart';

import 'package:ssf_cooperative/core/db/app_db.dart';
import 'package:ssf_cooperative/features/repositories/backup_codec.dart';

void main() {
  test('BackupCodec round-trip preserves members and deposits', () {
    final now = DateTime(2025, 6, 1);
    final org = OrganizationData(
      id: 1,
      name: 'Test Coop',
      shortName: 'TC',
      address: 'Dhaka',
      updatedAt: now,
    );
    final settings = SettingsData(
      id: 1,
      defaultReceivedBy: 'Admin',
      receiptPrefix: 'RCPT',
      nextReceiptSerial: 42,
      language: 'bn',
      themeMode: 'dark',
      defaultMemberPassword: '123456',
      memberShowCoopTotalCollection: true,
      memberShowCoopTotalDue: true,
      memberShowDueMembersList: false,
      memberShowCoopCurrentMonth: true,
      updatedAt: now,
    );
    final members = <Member>[
      Member(
        id: 1,
        uuid: 'm-1',
        memberIdNumber: '001',
        name: 'Member One',
        phone: '01700000000',
        phoneNormalized: '+8801700000000',
        monthlyAmount: 500,
        isActive: true,
        canCollectDeposits: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final deposits = <Deposit>[
      Deposit(
        id: 1,
        uuid: 'd-1',
        memberUuid: 'm-1',
        date: now,
        monthKey: '2025-06',
        amount: 500,
        method: 'cash',
        receivedBy: 'Admin',
        receiptSerial: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final json = BackupCodec.encode(
      org: org,
      settings: settings,
      members: members,
      deposits: deposits,
    );
    final decoded = BackupCodec.decode(json);

    expect(decoded['version'], BackupCodec.version);
    expect((decoded['members'] as List).length, 1);
    expect((decoded['deposits'] as List).length, 1);
    expect(decoded['organization']['name'], 'Test Coop');
    expect(decoded['settings']['nextReceiptSerial'], 42);
  });
}
