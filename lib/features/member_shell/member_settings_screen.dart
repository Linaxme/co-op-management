import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';
import '../../core/providers.dart';
import '../../widgets/notification_settings_card.dart';
import '../../l10n/app_localizations.dart';

class MemberSettingsScreen extends ConsumerStatefulWidget {
  const MemberSettingsScreen({super.key});

  @override
  ConsumerState<MemberSettingsScreen> createState() =>
      _MemberSettingsScreenState();
}

class _MemberSettingsScreenState extends ConsumerState<MemberSettingsScreen> {
  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context)!;
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.currentPassword),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.newPassword),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.confirmPassword),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    if (newCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordLengthHint)),
      );
      return;
    }
    if (newCtrl.text != confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordMismatch)),
      );
      return;
    }

    try {
      await ref.read(authServiceProvider).changeOwnPassword(
            currentPassword: currentCtrl.text,
            newPassword: newCtrl.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.passwordChanged)),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const NotificationSettingsCard(),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.theme),
                  subtitle: Text(_themeLabel(themeMode, l10n)),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(l10n.themeSystem),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(l10n.themeLight),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(l10n.themeDark),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(v);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(l10n.language),
                  trailing: DropdownButton<String>(
                    value: language,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                      DropdownMenuItem(value: 'bn', child: Text(l10n.bengali)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(languageProvider.notifier).setLanguage(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_reset),
              title: Text(l10n.changePassword),
              onTap: _changePassword,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.error),
            title: Text(
              l10n.logout,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }
}
