import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/auth_provider.dart';
import 'auth/auth_session.dart';
import 'db/app_db.dart';
import 'firebase/sync_service.dart';
import 'firebase_providers.dart';
import 'notifications/notification_service.dart';
import 'notifications/firestore_notification_listener.dart';
import '../features/repositories/coop_data_repository.dart';
import '../features/repositories/web_coop_repository.dart';
import '../features/repositories/receipt_service.dart';
import '../features/repositories/report_service.dart';
import '../features/repositories/backup_service.dart';

export 'firebase_providers.dart';

final dbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  if (!kIsWeb) {
    db.ensureSchemaReady().catchError((error) {
      debugPrint('Error preparing database: $error');
    });
  }
  ref.onDispose(db.close);
  return db;
});

/// Data access: all platforms read/write Firestore directly (no offline sync).
final repoProvider = Provider<CoopDataRepository>((ref) {
  return WebCoopRepository(ref);
});

/// Subscribes to [streamFactory] only when signed in with a cooperative id.
/// Prevents StreamProvider errors during brief auth loading windows.
Stream<T> coopScopedStream<T>(Ref ref, Stream<T> Function() streamFactory) {
  final session = ref.watch(authSessionProvider);
  if (!session.isAuthenticated || session.coopId == null) {
    final controller = StreamController<T>();
    ref.onDispose(controller.close);
    return controller.stream;
  }
  return streamFactory();
}

final receiptServiceProvider = Provider<ReceiptService>((ref) {
  final repo = ref.watch(repoProvider);
  return ReceiptService(repo: repo);
});

final reportServiceProvider = Provider<ReportService>((ref) {
  final repo = ref.watch(repoProvider);
  return ReportService(repo: repo);
});

final backupServiceProvider = Provider<BackupService>((ref) {
  final repo = ref.watch(repoProvider);
  final auth = ref.watch(authServiceProvider);
  return BackupService(repo: repo, auth: auth);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final firebase = ref.watch(firebaseServiceProvider);
  final connectivity = ref.watch(connectivityProvider);
  final syncService = SyncService(
    ref.watch(dbProvider),
    firebase,
    connectivity,
  );

  ref.listen<AuthSession>(authSessionProvider, (prev, next) async {
    syncService.setSession(next);

    if (!kIsWeb &&
        next.isAuthenticated &&
        next.coopId != null &&
        (prev?.coopId != next.coopId ||
            prev?.user?.uid != next.user?.uid ||
            (next.isMember && prev?.memberUuid != next.memberUuid))) {
      await FirestoreNotificationListener.instance.start(
        coopId: next.coopId!,
        memberUuid: next.memberUuid,
        isMember: next.isMember,
      );

      final uid = next.user?.uid;
      if (uid != null) {
        try {
          final settings = await ref.read(repoProvider).getSettings();
          final isBn = settings.language == 'bn';
          if (next.isMember) {
            await NotificationService.instance.onMemberSessionStarted(
              uid: uid,
              dueReminderTitle:
                  isBn ? 'মাসিক বকেয়া স্মরণ' : 'Monthly due reminder',
              dueReminderBody: isBn
                  ? 'অ্যাপে আপনার বকেয়া দেখুন'
                  : 'Check your due amount in the app',
            );
          } else if (next.isAdmin) {
            await NotificationService.instance.onAdminSessionStarted(uid: uid);
          }
        } catch (e) {
          debugPrint('Notification setup failed: $e');
        }
      }
    } else if (!kIsWeb && !next.isAuthenticated && prev?.isAuthenticated == true) {
      FirestoreNotificationListener.instance.stop();
    }
  });

  ref.onDispose(() {
    syncService.dispose();
    if (!kIsWeb) {
      FirestoreNotificationListener.instance.stop();
    }
  });

  return syncService;
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;
  ThemeModeNotifier(this.ref) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final settings = await ref.read(repoProvider).getSettings();
      final themeModeStr =
          settings.themeMode.isNotEmpty ? settings.themeMode : 'system';
      switch (themeModeStr) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        case 'system':
          state = ThemeMode.system;
          break;
        default:
          state = ThemeMode.system;
          break;
      }
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String themeModeStr;
    switch (mode) {
      case ThemeMode.light:
        themeModeStr = 'light';
        break;
      case ThemeMode.dark:
        themeModeStr = 'dark';
        break;
      case ThemeMode.system:
        themeModeStr = 'system';
        break;
    }
    await ref.read(repoProvider).updateThemeMode(themeModeStr);
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier(ref);
});

class LanguageNotifier extends StateNotifier<String> {
  final Ref ref;
  LanguageNotifier(this.ref) : super('en') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final settings = await ref.read(repoProvider).getSettings();
      state = settings.language.isNotEmpty ? settings.language : 'en';
    } catch (e) {
      state = 'en';
    }
  }

  Future<void> setLanguage(String language) async {
    if (language != 'en' && language != 'bn') {
      return;
    }
    state = language;
    await ref.read(repoProvider).updateLanguage(language);
  }
}

final canCollectDepositsProvider = FutureProvider<bool>((ref) async {
  final uuid = ref.watch(currentMemberUuidProvider);
  if (uuid == null) return false;
  final member = await ref.read(repoProvider).getMemberByUuid(uuid);
  return member?.canCollectDeposits ?? false;
});
