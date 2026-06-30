import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/auth/admin_route_guard.dart';
import '../../core/providers.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/utils/coop_short_name.dart';
import '../../core/utils/picked_image_storage.dart';
import '../../core/utils/image_sync_codec.dart';
import '../../core/db/app_db.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/success_toast.dart' show showSuccessToast;
import '../../widgets/cached_image_file.dart';
import '../../widgets/admin_announcement_card.dart';
import '../../widgets/notification_settings_card.dart';
import '../../l10n/app_localizations.dart';

final _orgProvider = StreamProvider((ref) {
  return coopScopedStream(
    ref,
    () => ref.watch(repoProvider).watchOrganization(),
  );
});
final _settingsProvider = StreamProvider((ref) {
  return coopScopedStream(
    ref,
    () => ref.watch(repoProvider).watchSettings(),
  );
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AdminRouteGuard, SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _orgNameCtrl = TextEditingController();
  final _orgShortNameCtrl = TextEditingController();
  final _orgAddressCtrl = TextEditingController();
  final _defaultReceivedByCtrl = TextEditingController();
  final _receiptPrefixCtrl = TextEditingController();
  final _defaultMemberPasswordCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _saving = false;
  bool _initialized = false;
  bool _memberShowCoopTotalCollection = true;
  bool _memberShowCoopTotalDue = true;
  bool _memberShowDueMembersList = true;
  bool _memberShowCoopCurrentMonth = true;
  String? _logoPath;
  String? _signaturePath;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orgNameCtrl.dispose();
    _orgShortNameCtrl.dispose();
    _orgAddressCtrl.dispose();
    _defaultReceivedByCtrl.dispose();
    _receiptPrefixCtrl.dispose();
    _defaultMemberPasswordCtrl.dispose();
    super.dispose();
  }

  void _initializeFields(OrganizationData? org, SettingsData? settings) {
    if (!_initialized) {
      if (org != null) {
        _orgNameCtrl.text = org.name;
        _orgShortNameCtrl.text = org.shortName ?? '';
        _orgAddressCtrl.text = org.address;
        _logoPath = org.logoPath;
        _signaturePath = org.signaturePath;
      }
      if (settings != null) {
        _defaultReceivedByCtrl.text = settings.defaultReceivedBy;
        _receiptPrefixCtrl.text = settings.receiptPrefix;
        _defaultMemberPasswordCtrl.text = settings.defaultMemberPassword;
        _memberShowCoopTotalCollection = settings.memberShowCoopTotalCollection;
        _memberShowCoopTotalDue = settings.memberShowCoopTotalDue;
        _memberShowDueMembersList = settings.memberShowDueMembersList;
        _memberShowCoopCurrentMonth = settings.memberShowCoopCurrentMonth;
      }
      _initialized = true;
    }
  }

  Future<void> _deleteLocalFileIfExists(String? path) async {
    if (path == null || kIsWeb || !isLocalFileImagePath(path)) return;
    try {
      final oldFile = File(path);
      if (await oldFile.exists()) await oldFile.delete();
    } catch (_) {}
  }

  Future<void> _pickImage(bool isLogo) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (image == null) return;

      final savedPath = await savePickedImage(
        image,
        folderName: 'images',
        filePrefix: isLogo ? 'logo' : 'signature',
      );

      if (isLogo) {
        await _deleteLocalFileIfExists(_logoPath);
      } else {
        await _deleteLocalFileIfExists(_signaturePath);
      }

      setState(() {
        if (isLogo) {
          _logoPath = savedPath;
        } else {
          _signaturePath = savedPath;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorPickingImage(e.toString()))),
        );
      }
    }
  }

  Future<void> _removeImage(bool isLogo) async {
    if (isLogo && _logoPath != null) {
      await _deleteLocalFileIfExists(_logoPath);
      setState(() => _logoPath = null);
    } else if (!isLogo && _signaturePath != null) {
      await _deleteLocalFileIfExists(_signaturePath);
      setState(() => _signaturePath = null);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final shortName = CoopShortName.normalize(_orgShortNameCtrl.text);
      if (CoopShortName.validationError(_orgShortNameCtrl.text) != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.shortNameInvalid),
            ),
          );
        }
        setState(() => _saving = false);
        return;
      }

      final coopId = ref.read(authSessionProvider).coopId;
      final available = await ref.read(authServiceProvider).isShortNameAvailable(
            shortName,
            excludeCoopId: coopId,
          );
      if (!available) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.shortNameTaken),
            ),
          );
        }
        setState(() => _saving = false);
        return;
      }

      await ref.read(repoProvider).updateOrganization(
            name: _orgNameCtrl.text.trim(),
            address: _orgAddressCtrl.text.trim(),
            shortName: shortName,
            logoPath: _logoPath,
            signaturePath: _signaturePath,
          );

      await ref.read(repoProvider).updateSettings(
            defaultReceivedBy: _defaultReceivedByCtrl.text.trim(),
            receiptPrefix: _receiptPrefixCtrl.text.trim(),
            defaultMemberPassword: _defaultMemberPasswordCtrl.text.trim(),
            memberShowCoopTotalCollection: _memberShowCoopTotalCollection,
            memberShowCoopTotalDue: _memberShowCoopTotalDue,
            memberShowDueMembersList: _memberShowDueMembersList,
            memberShowCoopCurrentMonth: _memberShowCoopCurrentMonth,
          );

      if (mounted) {
        showSuccessToast(context, AppLocalizations.of(context)!.settingsSaved);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _exportBackup() async {
    try {
      setState(() => _saving = true);
      final backupService = ref.read(backupServiceProvider);
      final result = await backupService.exportBackup();

      if (mounted) {
        showSuccessToast(context, AppLocalizations.of(context)!.backupExported);

        // Only share on native platforms
        if (!kIsWeb) {
          await backupService.shareBackup(result);
        }
        // On web, download is already triggered in exportBackup
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;
      if (!kIsWeb && picked.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)!.error}: Could not read backup file',
              ),
            ),
          );
        }
        return;
      }
      if (kIsWeb && picked.bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)!.error}: Could not read backup file',
              ),
            ),
          );
        }
        return;
      }

      final confirmed = await showConfirmationDialog(
        context: context,
        title: 'Import Backup',
        message:
            'This will import data from the backup file. Existing data with the same UUID will be merged. Continue?',
        confirmText: 'Import',
        cancelText: 'Cancel',
        isDestructive: false,
      );

      if (!confirmed) return;

      setState(() => _saving = true);
      final backupService = ref.read(backupServiceProvider);
      final Map<String, int> stats;
      if (kIsWeb) {
        stats = await backupService.importBackupFromJson(
          utf8.decode(picked.bytes!),
        );
      } else {
        stats = await backupService.importBackupFromPath(picked.path!);
      }

      if (mounted) {
        final imported = (stats['members'] as int) + (stats['deposits'] as int);
        final merged =
            (stats['membersMerged'] ?? 0) + (stats['depositsMerged'] ?? 0);
        final membersFailed = stats['membersFailed'] ?? 0;
        final depositsFailed = stats['depositsFailed'] ?? 0;
        final loginsProvisioned = stats['loginsProvisioned'] ?? 0;
        final loginsFailed = stats['loginsFailed'] ?? 0;
        final loginsSkipped = stats['loginsSkipped'] ?? 0;
        final buffer = StringBuffer(
          '${AppLocalizations.of(context)!.backupImported}: $imported items imported',
        );
        if (merged > 0) {
          buffer.write(', $merged merged');
        }
        if (membersFailed > 0 || depositsFailed > 0) {
          buffer.write(
            ', $membersFailed members failed, $depositsFailed deposits failed',
          );
        }
        buffer.write('.');
        if (loginsProvisioned > 0 ||
            loginsFailed > 0 ||
            loginsSkipped > 0) {
          buffer.write(
            ' $loginsProvisioned member logins created',
          );
          if (loginsFailed > 0) {
            buffer.write(', $loginsFailed failed');
          }
          if (loginsSkipped > 0) {
            buffer.write(', $loginsSkipped skipped (invalid phone)');
          }
          buffer.write('.');
        }
        showSuccessToast(context, buffer.toString());
        setState(() => _initialized = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orgAsync = ref.watch(_orgProvider);
    final settingsAsync = ref.watch(_settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.settingsTabOrganization),
            Tab(text: l10n.settingsTabReceipt),
            Tab(text: l10n.settingsTabMemberApp),
            Tab(text: l10n.settingsTabSystem),
          ],
        ),
      ),
      body: orgAsync.when(
        data: (org) => settingsAsync.when(
          data: (settings) {
            _initializeFields(org, settings);
            return Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                  // Member login short name
                  if (_orgShortNameCtrl.text.trim().isNotEmpty)
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.badge_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.organizationShortName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CoopShortName.normalize(_orgShortNameCtrl.text),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!
                                  .memberShareShortName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.warning_amber_outlined,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          Localizations.localeOf(context).languageCode == 'bn'
                              ? 'সদস্য লগইনের জন্য শর্ট নেম সেট করুন'
                              : 'Set a short name for member login',
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // 1. General Settings
                  Card(
                    child: ExpansionTile(
                      leading: Icon(Icons.business,
                          color: Theme.of(context).colorScheme.primary),
                      title:
                          Text(AppLocalizations.of(context)!.generalSettings),
                      subtitle: Text(AppLocalizations.of(context)!
                          .organizationNameAndAddress),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _orgNameCtrl,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .organizationName,
                                  hintText: AppLocalizations.of(context)!
                                      .enterOrganizationName,
                                  prefixIcon: const Icon(Icons.business_center),
                                ),
                                validator: (v) => v?.trim().isEmpty ?? true
                                    ? AppLocalizations.of(context)!.required
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _orgShortNameCtrl,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .organizationShortName,
                                  hintText: AppLocalizations.of(context)!
                                      .organizationShortNameHint,
                                  helperText: AppLocalizations.of(context)!
                                      .organizationShortNameHelper,
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .required;
                                  }
                                  if (CoopShortName.validationError(v) !=
                                      null) {
                                    return AppLocalizations.of(context)!
                                        .shortNameInvalid;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _orgAddressCtrl,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .organizationAddress,
                                  hintText: AppLocalizations.of(context)!
                                      .enterOrganizationAddress,
                                  prefixIcon: const Icon(Icons.location_on),
                                ),
                                maxLines: 3,
                                validator: (v) => v?.trim().isEmpty ?? true
                                    ? AppLocalizations.of(context)!.required
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Branding & Identity
                  Card(
                    child: ExpansionTile(
                      leading: Icon(Icons.palette,
                          color: Theme.of(context).colorScheme.primary),
                      title:
                          Text(AppLocalizations.of(context)!.brandingIdentity),
                      subtitle:
                          Text(AppLocalizations.of(context)!.logoAndSignature),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo
                              Text(
                                AppLocalizations.of(context)!.logo,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!
                                    .usedInReceiptsAndReports,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _pickImage(true),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: _logoPath != null
                                          ? CachedImageFile(
                                              filePath: _logoPath!,
                                              fit: BoxFit.cover,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              errorWidget:
                                                  const Icon(Icons.image),
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_photo_alternate,
                                                  size: 32,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Add Logo',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_logoPath != null)
                                          TextButton.icon(
                                            onPressed: () => _removeImage(true),
                                            icon: const Icon(Icons.delete,
                                                size: 16),
                                            label: const Text('Remove Logo',
                                                style: TextStyle(fontSize: 12)),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Signature
                              Text(
                                AppLocalizations.of(context)!.signature,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Appears at the bottom of receipts',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _pickImage(false),
                                child: Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outlineVariant),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _signaturePath != null
                                      ? CachedImageFile(
                                          filePath: _signaturePath!,
                                          fit: BoxFit.contain,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          errorWidget: const Icon(Icons.image),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.draw,
                                              size: 40,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Tap to add signature image',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              if (_signaturePath != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TextButton.icon(
                                    onPressed: () => _removeImage(false),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Remove Signature'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Receipt Configuration — next tab
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ExpansionTile(
                      leading: Icon(Icons.receipt_long,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(
                          AppLocalizations.of(context)!.receiptConfiguration),
                      subtitle:
                          Text(AppLocalizations.of(context)!.receiptSettings),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _receiptPrefixCtrl,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .receiptPrefix,
                                  hintText: 'e.g., RCPT',
                                  prefixIcon: const Icon(Icons.tag),
                                  helperText:
                                      'Used in receipt numbers (e.g., RCPT-001)',
                                ),
                                validator: (v) => v?.trim().isEmpty ?? true
                                    ? AppLocalizations.of(context)!.required
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _defaultReceivedByCtrl,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .defaultReceivedBy,
                                  hintText: 'Default name for receipt',
                                  prefixIcon: const Icon(Icons.person),
                                  helperText: 'Default name shown on receipts',
                                ),
                                validator: (v) => v?.trim().isEmpty ?? true
                                    ? AppLocalizations.of(context)!.required
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _defaultMemberPasswordCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .defaultMemberPassword,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  helperText: AppLocalizations.of(context)!
                                      .defaultMemberPasswordHint,
                                ),
                                validator: (v) {
                                  if (v == null || v.length < 6) {
                                    return AppLocalizations.of(context)!
                                        .passwordLengthHint;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Member dashboard visibility
                  Card(
                    child: ExpansionTile(
                      leading: Icon(Icons.dashboard_customize_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(l10n.memberDashboardSettings),
                      subtitle: Text(l10n.memberDashboardSettingsSubtitle),
                      children: [
                        SwitchListTile(
                          title: Text(l10n.coopCurrentMonth),
                          value: _memberShowCoopCurrentMonth,
                          onChanged: (v) =>
                              setState(() => _memberShowCoopCurrentMonth = v),
                        ),
                        SwitchListTile(
                          title: Text(l10n.coopTotalCollection),
                          value: _memberShowCoopTotalCollection,
                          onChanged: (v) => setState(
                              () => _memberShowCoopTotalCollection = v),
                        ),
                        SwitchListTile(
                          title: Text(l10n.coopTotalDue),
                          value: _memberShowCoopTotalDue,
                          onChanged: (v) =>
                              setState(() => _memberShowCoopTotalDue = v),
                        ),
                        SwitchListTile(
                          title: Text(l10n.membersWithDueList),
                          value: _memberShowDueMembersList,
                          onChanged: (v) =>
                              setState(() => _memberShowDueMembersList = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const NotificationSettingsCard(),
                  const SizedBox(height: 12),
                  const AdminAnnouncementCard(),
                  const SizedBox(height: 12),
                  // 4. Appearance
                  Card(
                    child: ExpansionTile(
                      leading: Icon(Icons.palette_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(AppLocalizations.of(context)!.appearance),
                      subtitle:
                          Text(AppLocalizations.of(context)!.themeAndLanguage),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Consumer(
                                builder: (context, ref, child) {
                                  final themeMode =
                                      ref.watch(themeModeProvider);
                                  return Row(
                                    children: [
                                      const Icon(Icons.brightness_6, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SegmentedButton<ThemeMode>(
                                          segments: const [
                                            ButtonSegment(
                                              value: ThemeMode.light,
                                              icon: Icon(Icons.light_mode,
                                                  size: 18),
                                              label: Text('Light'),
                                            ),
                                            ButtonSegment(
                                              value: ThemeMode.dark,
                                              icon: Icon(Icons.dark_mode,
                                                  size: 18),
                                              label: Text('Dark'),
                                            ),
                                            ButtonSegment(
                                              value: ThemeMode.system,
                                              icon: Icon(Icons.brightness_auto,
                                                  size: 18),
                                              label: Text('Auto'),
                                            ),
                                          ],
                                          selected: {themeMode},
                                          onSelectionChanged:
                                              (Set<ThemeMode> newSelection) {
                                            ref
                                                .read(
                                                    themeModeProvider.notifier)
                                                .setThemeMode(
                                                    newSelection.first);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Consumer(
                                builder: (context, ref, child) {
                                  final language = ref.watch(languageProvider);
                                  return Row(
                                    children: [
                                      const Icon(Icons.language, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SegmentedButton<String>(
                                          segments: const [
                                            ButtonSegment(
                                              value: 'bn',
                                              label: Text('বাংলা'),
                                            ),
                                            ButtonSegment(
                                              value: 'en',
                                              label: Text('English'),
                                            ),
                                          ],
                                          selected: {language},
                                          onSelectionChanged:
                                              (Set<String> newSelection) {
                                            ref
                                                .read(languageProvider.notifier)
                                                .setLanguage(
                                                    newSelection.first);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Data Management
                  Card(
                    child: ExpansionTile(
                      leading: Icon(Icons.storage,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(AppLocalizations.of(context)!.dataManagement),
                      subtitle:
                          Text(AppLocalizations.of(context)!.backupAndRestore),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export all your data to a JSON file for backup. You can restore it later.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _saving ? null : _exportBackup,
                                      icon: const Icon(Icons.download),
                                      label: Text(AppLocalizations.of(context)!
                                          .exportBackup),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _saving ? null : _importBackup,
                                      icon: const Icon(Icons.upload),
                                      label: Text(AppLocalizations.of(context)!
                                          .importBackup),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  PrimaryButton(
                    label: AppLocalizations.of(context)!.saveAllSettings,
                    onPressed: _saving ? null : _save,
                    loading: _saving,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(AppLocalizations.of(context)!.logout),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
