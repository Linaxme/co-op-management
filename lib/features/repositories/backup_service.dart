import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/auth/auth_service.dart';
import 'backup_codec.dart';
import 'coop_data_repository.dart';

import 'backup_service_io.dart'
    if (dart.library.html) 'backup_service_web.dart' as platform;

class BackupService {
  static const String appName = 'SSF Cooperative';
  static const String backupVersion = BackupCodec.version;

  final CoopDataRepository repo;
  final AuthService auth;

  BackupService({required this.repo, required this.auth});

  Future<String> exportBackup() async {
    final jsonString = await repo.exportToJson();
    return platform.writeJsonBackup(jsonString);
  }

  Future<Map<String, int>> importBackupFromJson(String jsonString) async {
    BackupCodec.decode(jsonString);

    final result = await repo.importFromJson(jsonString);
    final stats = Map<String, int>.from(result.stats);

    await _provisionMemberLoginsAfterImport(result.membersToProvision, stats);

    return stats;
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
}
