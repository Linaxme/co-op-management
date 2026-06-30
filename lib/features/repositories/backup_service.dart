import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/auth/auth_service.dart';
import '../../core/db/app_db.dart';
import '../../core/utils/phone_utils.dart';
import 'coop_repository.dart';

import 'backup_service_io.dart'
    if (dart.library.html) 'backup_service_web.dart' as platform;

class BackupService {
  static const String appName = 'SSF Cooperative';
  static const String backupVersion = '1.0';

  final CoopRepository repo;
  final AuthService auth;

  BackupService({required this.repo, required this.auth});

  Future<String> exportBackup() async {
    final members = await repo.db.select(repo.db.members).get();
    final deposits = await repo.db.select(repo.db.deposits).get();
    final org = await repo.watchOrganization().first;
    final settings = await repo.watchSettings().first;

    final backupData = {
      'version': backupVersion,
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
        'memberShowCoopTotalCollection': settings.memberShowCoopTotalCollection,
        'memberShowCoopTotalDue': settings.memberShowCoopTotalDue,
        'memberShowDueMembersList': settings.memberShowDueMembersList,
        'memberShowCoopCurrentMonth': settings.memberShowCoopCurrentMonth,
        'updatedAt': settings.updatedAt.toIso8601String(),
      },
      'members': members
          .map((m) => {
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
              })
          .toList(),
      'deposits': deposits
          .map((d) => {
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
              })
          .toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
    return platform.writeJsonBackup(jsonString);
  }

  Future<Map<String, int>> importBackupFromJson(String jsonString) async {
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    if (backupData['version'] != backupVersion) {
      throw Exception('Unsupported backup version: ${backupData['version']}');
    }

    final stats = {
      'members': 0,
      'membersMerged': 0,
      'deposits': 0,
      'depositsMerged': 0,
      'membersFailed': 0,
      'depositsFailed': 0,
      'loginsProvisioned': 0,
      'loginsFailed': 0,
      'loginsSkipped': 0,
    };
    final membersToProvision = <({String uuid, String? phoneNormalized})>[];

    await repo.db.transaction(() async {
      if (backupData.containsKey('organization')) {
        final orgData = backupData['organization'] as Map<String, dynamic>;
        final existingOrg =
            await (repo.db.select(repo.db.organization)..limit(1)).get();
        if (existingOrg.isNotEmpty) {
          await (repo.db.update(repo.db.organization)
                ..where((t) => t.id.equals(existingOrg.first.id)))
              .write(
            OrganizationCompanion(
              name: Value(orgData['name'] as String),
              shortName: orgData['shortName'] != null
                  ? Value(orgData['shortName'] as String)
                  : const Value.absent(),
              address: Value(orgData['address'] as String),
              logoPath: orgData['logoPath'] != null
                  ? Value(orgData['logoPath'] as String)
                  : const Value.absent(),
              signaturePath: orgData['signaturePath'] != null
                  ? Value(orgData['signaturePath'] as String)
                  : const Value.absent(),
              updatedAt: Value(DateTime.parse(orgData['updatedAt'] as String)),
            ),
          );
        } else {
          await repo.db.into(repo.db.organization).insert(
                OrganizationCompanion.insert(
                  name: orgData['name'] as String,
                  shortName: Value(orgData['shortName'] as String?),
                  address: orgData['address'] as String,
                  logoPath: Value(orgData['logoPath'] as String?),
                  signaturePath: Value(orgData['signaturePath'] as String?),
                  updatedAt: DateTime.parse(orgData['updatedAt'] as String),
                ),
              );
        }
      }

      if (backupData.containsKey('settings')) {
        final settingsData = backupData['settings'] as Map<String, dynamic>;
        final existingSettings =
            await (repo.db.select(repo.db.settings)..limit(1)).get();
        final companion = SettingsCompanion(
          defaultReceivedBy: Value(settingsData['defaultReceivedBy'] as String),
          receiptPrefix: Value(settingsData['receiptPrefix'] as String),
          nextReceiptSerial: Value(_asInt(settingsData['nextReceiptSerial'])),
          language: settingsData['language'] != null
              ? Value(settingsData['language'] as String)
              : const Value.absent(),
          themeMode: settingsData['themeMode'] != null
              ? Value(settingsData['themeMode'] as String)
              : const Value.absent(),
          defaultMemberPassword: settingsData['defaultMemberPassword'] != null
              ? Value(settingsData['defaultMemberPassword'] as String)
              : const Value.absent(),
          memberShowCoopTotalCollection:
              settingsData['memberShowCoopTotalCollection'] != null
                  ? Value(settingsData['memberShowCoopTotalCollection'] as bool)
                  : const Value.absent(),
          memberShowCoopTotalDue: settingsData['memberShowCoopTotalDue'] != null
              ? Value(settingsData['memberShowCoopTotalDue'] as bool)
              : const Value.absent(),
          memberShowDueMembersList:
              settingsData['memberShowDueMembersList'] != null
                  ? Value(settingsData['memberShowDueMembersList'] as bool)
                  : const Value.absent(),
          memberShowCoopCurrentMonth:
              settingsData['memberShowCoopCurrentMonth'] != null
                  ? Value(settingsData['memberShowCoopCurrentMonth'] as bool)
                  : const Value.absent(),
          updatedAt:
              Value(DateTime.parse(settingsData['updatedAt'] as String)),
        );
        if (existingSettings.isNotEmpty) {
          await (repo.db.update(repo.db.settings)
                ..where((t) => t.id.equals(existingSettings.first.id)))
              .write(companion);
        } else {
          await repo.db.into(repo.db.settings).insert(
                SettingsCompanion.insert(
                  defaultReceivedBy:
                      settingsData['defaultReceivedBy'] as String,
                  receiptPrefix: Value(settingsData['receiptPrefix'] as String),
                  nextReceiptSerial:
                      Value(_asInt(settingsData['nextReceiptSerial'])),
                  language: Value(settingsData['language'] as String? ?? 'en'),
                  themeMode:
                      Value(settingsData['themeMode'] as String? ?? 'system'),
                  defaultMemberPassword: Value(
                    settingsData['defaultMemberPassword'] as String? ?? '123456',
                  ),
                  memberShowCoopTotalCollection: Value(
                    settingsData['memberShowCoopTotalCollection'] as bool? ??
                        true,
                  ),
                  memberShowCoopTotalDue: Value(
                    settingsData['memberShowCoopTotalDue'] as bool? ?? true,
                  ),
                  memberShowDueMembersList: Value(
                    settingsData['memberShowDueMembersList'] as bool? ?? true,
                  ),
                  memberShowCoopCurrentMonth: Value(
                    settingsData['memberShowCoopCurrentMonth'] as bool? ?? true,
                  ),
                  updatedAt:
                      DateTime.parse(settingsData['updatedAt'] as String),
                ),
              );
        }
      }

      if (backupData.containsKey('members')) {
        final membersList = backupData['members'] as List<dynamic>;
        for (final memberData in membersList) {
          final m = memberData as Map<String, dynamic>;
          final uuid = m['uuid'] as String;
          final existing = await (repo.db.select(repo.db.members)
                ..where((t) => t.uuid.equals(uuid)))
              .get();

          final phone = m['phone'] as String?;
          final loginPhone = PhoneUtils.resolveMemberLoginPhone(
              phone, m['phoneNormalized'] as String?);
          final phoneNormalized =
              await _phoneNormalizedForImport(uuid, loginPhone);

          membersToProvision.add((uuid: uuid, phoneNormalized: loginPhone));

          if (existing.isNotEmpty) {
            final merged = await _mergeMemberFromBackup(
              m: m,
              uuid: uuid,
              phone: phone,
              phoneNormalized: phoneNormalized,
            );
            if (merged) {
              stats['membersMerged'] = (stats['membersMerged'] as int) + 1;
            } else {
              stats['membersFailed'] = (stats['membersFailed'] as int) + 1;
            }
            continue;
          }

          final inserted = await _insertMemberFromBackup(
            m: m,
            uuid: uuid,
            phone: phone,
            phoneNormalized: phoneNormalized,
          );
          if (inserted) {
            stats['members'] = (stats['members'] as int) + 1;
          } else {
            stats['membersFailed'] = (stats['membersFailed'] as int) + 1;
          }
        }
      }

      if (backupData.containsKey('deposits')) {
        final depositsList = backupData['deposits'] as List<dynamic>;
        for (final depositData in depositsList) {
          final d = depositData as Map<String, dynamic>;
          final uuid = d['uuid'] as String;
          final existing = await (repo.db.select(repo.db.deposits)
                ..where((t) => t.uuid.equals(uuid)))
              .get();

          if (existing.isNotEmpty) {
            final merged = await _mergeDepositFromBackup(d, uuid);
            if (merged) {
              stats['depositsMerged'] = (stats['depositsMerged'] as int) + 1;
            } else {
              stats['depositsFailed'] = (stats['depositsFailed'] as int) + 1;
            }
            continue;
          }

          final inserted = await _insertDepositFromBackup(d, uuid);
          if (inserted) {
            stats['deposits'] = (stats['deposits'] as int) + 1;
          } else {
            stats['depositsFailed'] = (stats['depositsFailed'] as int) + 1;
          }
        }
      }
    });

    await _provisionMemberLoginsAfterImport(membersToProvision, stats);

    return stats;
  }

  Future<bool> _insertMemberFromBackup({
    required Map<String, dynamic> m,
    required String uuid,
    required String? phone,
    required String? phoneNormalized,
  }) async {
    return _saveMemberFromBackup(
      label: 'import',
      uuid: uuid,
      name: m['name'] as String? ?? uuid,
      save: (normalized) => repo.db.into(repo.db.members).insert(
            MembersCompanion.insert(
              uuid: uuid,
              memberIdNumber: m['memberIdNumber'] as String,
              name: m['name'] as String,
              phone: Value(phone),
              phoneNormalized: Value(normalized),
              address: Value(m['address'] as String?),
              nidNumber: Value(m['nidNumber'] as String?),
              photoPath: Value(m['photoPath'] as String?),
              monthlyAmount: _asInt(m['monthlyAmount']),
              isActive: Value(m['isActive'] as bool? ?? true),
              deletedAt: m['deletedAt'] != null
                  ? Value(DateTime.parse(m['deletedAt'] as String))
                  : const Value.absent(),
              createdAt: DateTime.parse(m['createdAt'] as String),
              updatedAt: DateTime.parse(m['updatedAt'] as String),
            ),
          ),
      phoneNormalized: phoneNormalized,
    );
  }

  Future<bool> _mergeMemberFromBackup({
    required Map<String, dynamic> m,
    required String uuid,
    required String? phone,
    required String? phoneNormalized,
  }) async {
    return _saveMemberFromBackup(
      label: 'merge',
      uuid: uuid,
      name: m['name'] as String? ?? uuid,
      save: (normalized) => (repo.db.update(repo.db.members)
            ..where((t) => t.uuid.equals(uuid)))
          .write(
        MembersCompanion(
          memberIdNumber: Value(m['memberIdNumber'] as String),
          name: Value(m['name'] as String),
          phone: Value(phone),
          phoneNormalized: Value(normalized),
          address: Value(m['address'] as String?),
          nidNumber: Value(m['nidNumber'] as String?),
          photoPath: Value(m['photoPath'] as String?),
          monthlyAmount: Value(_asInt(m['monthlyAmount'])),
          isActive: Value(m['isActive'] as bool? ?? true),
          deletedAt: m['deletedAt'] != null
              ? Value(DateTime.parse(m['deletedAt'] as String))
              : const Value(null),
          updatedAt: Value(DateTime.parse(m['updatedAt'] as String)),
        ),
      ),
      phoneNormalized: phoneNormalized,
    );
  }

  Future<bool> _saveMemberFromBackup({
    required String label,
    required String uuid,
    required String name,
    required Future<int> Function(String? normalized) save,
    required String? phoneNormalized,
  }) async {
    try {
      await save(phoneNormalized);
      return true;
    } catch (e) {
      if (phoneNormalized == null) {
        debugPrint('Failed to $label member $uuid ($name): $e');
        return false;
      }
      try {
        await save(null);
        debugPrint(
          'Imported member $uuid ($name) without normalized phone after: $e',
        );
        return true;
      } catch (e2) {
        debugPrint('Failed to $label member $uuid ($name): $e2');
        return false;
      }
    }
  }

  Future<bool> _insertDepositFromBackup(
    Map<String, dynamic> d,
    String uuid,
  ) async {
    try {
      await repo.db.into(repo.db.deposits).insert(
            DepositsCompanion.insert(
              uuid: uuid,
              memberUuid: d['memberUuid'] as String,
              date: DateTime.parse(d['date'] as String),
              monthKey: d['monthKey'] as String,
              amount: _asInt(d['amount']),
              reason: Value(d['reason'] as String?),
              method: d['method'] as String,
              receivedBy: d['receivedBy'] as String,
              receiptSerial: _asInt(d['receiptSerial']),
              receiptPdfPath: Value(d['receiptPdfPath'] as String?),
              deletedAt: d['deletedAt'] != null
                  ? Value(DateTime.parse(d['deletedAt'] as String))
                  : const Value.absent(),
              createdAt: DateTime.parse(d['createdAt'] as String),
              updatedAt: DateTime.parse(d['updatedAt'] as String),
            ),
          );
      return true;
    } catch (e) {
      debugPrint(
        'Failed to import deposit $uuid (member ${d['memberUuid']}): $e',
      );
      return false;
    }
  }

  Future<bool> _mergeDepositFromBackup(
    Map<String, dynamic> d,
    String uuid,
  ) async {
    try {
      await (repo.db.update(repo.db.deposits)..where((t) => t.uuid.equals(uuid)))
          .write(
        DepositsCompanion(
          memberUuid: Value(d['memberUuid'] as String),
          date: Value(DateTime.parse(d['date'] as String)),
          monthKey: Value(d['monthKey'] as String),
          amount: Value(_asInt(d['amount'])),
          reason: Value(d['reason'] as String?),
          method: Value(d['method'] as String),
          receivedBy: Value(d['receivedBy'] as String),
          receiptSerial: Value(_asInt(d['receiptSerial'])),
          receiptPdfPath: Value(d['receiptPdfPath'] as String?),
          deletedAt: d['deletedAt'] != null
              ? Value(DateTime.parse(d['deletedAt'] as String))
              : const Value(null),
          updatedAt: Value(DateTime.parse(d['updatedAt'] as String)),
        ),
      );
      return true;
    } catch (e) {
      debugPrint(
        'Failed to merge deposit $uuid (member ${d['memberUuid']}): $e',
      );
      return false;
    }
  }

  Future<String?> _phoneNormalizedForImport(
    String uuid,
    String? resolved,
  ) async {
    if (resolved == null) return null;

    final existing = await (repo.db.select(repo.db.members)
          ..where((t) => t.phoneNormalized.equals(resolved)))
        .get();
    if (existing.any((m) => m.uuid != uuid)) {
      debugPrint(
        'Phone $resolved already used; importing member $uuid without normalized phone',
      );
      return null;
    }
    return resolved;
  }

  Future<void> _provisionMemberLoginsAfterImport(
    List<({String uuid, String? phoneNormalized})> members,
    Map<String, int> stats,
  ) async {
    if (members.isEmpty) return;

    final settings = await repo.getSettings();
    final password = settings.defaultMemberPassword;
    if (password.length < 6) {
      debugPrint(
        'Skip member login provisioning: default password must be at least 6 characters',
      );
      stats['loginsSkipped'] = members.length;
      return;
    }

    for (final member in members) {
      final phone = member.phoneNormalized;
      if (phone == null || phone.isEmpty) {
        stats['loginsSkipped'] = (stats['loginsSkipped'] as int) + 1;
        continue;
      }

      try {
        final coopId = await auth.getCurrentUserCoopId();
        await auth.provisionMemberLogin(
          memberUuid: member.uuid,
          phoneNormalized: phone,
          password: password,
          coopId: coopId,
        );
        stats['loginsProvisioned'] = (stats['loginsProvisioned'] as int) + 1;
      } catch (e) {
        debugPrint('Login provision failed for ${member.uuid}: $e');
        stats['loginsFailed'] = (stats['loginsFailed'] as int) + 1;
      }
    }
  }

  Future<Map<String, int>> importBackupFromPath(String path) async {
    final jsonString = await platform.readBackupFile(path);
    return importBackupFromJson(jsonString);
  }

  Future<void> shareBackup(String filePath) async {
    if (!kIsWeb) {
      await Share.shareXFiles([XFile(filePath)], text: 'SSF Cooperative Backup');
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.parse(value.toString());
  }
}
