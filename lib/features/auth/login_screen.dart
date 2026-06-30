import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/member_login_storage.dart';
import '../../core/firebase/models.dart';
import '../../core/utils/coop_short_name.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/cached_image_file.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _adminFormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _adminMode = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _switchToAdmin() {
    setState(() {
      _adminMode = true;
      _error = null;
    });
  }

  void _switchToMember() {
    setState(() {
      _adminMode = false;
      _error = null;
    });
  }

  Future<void> _adminLogin() async {
    if (!_adminFormKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).signInAdmin(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = AppLocalizations.of(context)!.loginFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Icon(
                    Icons.account_balance,
                    size: 52,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _adminMode
                        ? l10n.loginSubtitleAdmin
                        : l10n.loginSubtitleMember,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _adminMode
                          ? _AdminLoginForm(
                              key: const ValueKey('admin'),
                              formKey: _adminFormKey,
                              emailCtrl: _emailCtrl,
                              passwordCtrl: _passwordCtrl,
                              loading: _loading,
                              onSubmit: _adminLogin,
                            )
                          : _MemberLoginForm(
                              key: const ValueKey('member'),
                              loading: _loading,
                              onLoadingChanged: (v) =>
                                  setState(() => _loading = v),
                              onError: (msg) => setState(() => _error = msg),
                              onClearError: () => setState(() => _error = null),
                            ),
                    ),
                  ),
                  if (_adminMode) ...[
                    TextButton(
                      onPressed: _loading ? null : () => context.push('/signup'),
                      child: Text(l10n.dontHaveAccount),
                    ),
                    TextButton(
                      onPressed: _loading ? null : _switchToMember,
                      child: Text(l10n.loginSwitchToMember),
                    ),
                  ] else
                    TextButton(
                      onPressed: _loading ? null : _switchToAdmin,
                      child: Text(
                        l10n.loginSwitchToAdmin,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminLoginForm extends StatelessWidget {
  const _AdminLoginForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? l10n.required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.password,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            validator: (v) => v == null || v.isEmpty ? l10n.required : null,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.login,
            loading: loading,
            onPressed: loading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _MemberLoginForm extends ConsumerStatefulWidget {
  const _MemberLoginForm({
    super.key,
    required this.loading,
    required this.onLoadingChanged,
    required this.onError,
    required this.onClearError,
  });

  final bool loading;
  final ValueChanged<bool> onLoadingChanged;
  final ValueChanged<String> onError;
  final VoidCallback onClearError;

  @override
  ConsumerState<_MemberLoginForm> createState() => _MemberLoginFormState();
}

class _MemberLoginFormState extends ConsumerState<_MemberLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _shortNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _step2 = false;
  CooperativeLookup? _lookup;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _shortNameCtrl.addListener(_onShortNameChanged);
  }

  Future<void> _loadSaved() async {
    final saved = await MemberLoginStorage.load();
    if (!mounted || saved == null) return;
    _shortNameCtrl.text = saved.shortName;
    final lookup = await ref
        .read(authServiceProvider)
        .lookupCooperativeByShortName(saved.shortName);
    if (!mounted) return;
    setState(() {
      _lookup = lookup ??
          CooperativeLookup(
            coopId: saved.coopId,
            name: saved.coopName,
            shortName: saved.shortName,
          );
      _step2 = true;
    });
  }

  void _onShortNameChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _lookupShortName);
  }

  Future<void> _lookupShortName() async {
    final raw = _shortNameCtrl.text;
    final normalized = CoopShortName.normalize(raw);
    if (CoopShortName.validationError(raw) != null || normalized.isEmpty) {
      if (mounted) setState(() => _lookup = null);
      return;
    }

    final result = await ref
        .read(authServiceProvider)
        .lookupCooperativeByShortName(normalized);
    if (mounted) setState(() => _lookup = result);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _shortNameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (_lookup == null) return;
    setState(() => _step2 = true);
  }

  void _backToStep1() {
    setState(() => _step2 = false);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _lookup == null) return;
    widget.onClearError();
    widget.onLoadingChanged(true);
    try {
      await ref.read(authProvider.notifier).signInMember(
            _phoneCtrl.text.trim(),
            _passwordCtrl.text,
            shortName: _lookup!.shortName,
          );
      await MemberLoginStorage.save(
        shortName: _lookup!.shortName,
        coopId: _lookup!.coopId,
        coopName: _lookup!.name,
      );
    } on AuthException catch (e) {
      widget.onError(e.message);
    } catch (_) {
      widget.onError(AppLocalizations.of(context)!.loginFailed);
    } finally {
      if (mounted) widget.onLoadingChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          if (!_step2) ...[
            Text(
              l10n.memberLoginShortNameHint,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shortNameCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l10n.memberLoginShortName,
                hintText: l10n.organizationShortNameHint,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.required;
                if (CoopShortName.validationError(v) != null) {
                  return l10n.shortNameInvalid;
                }
                if (_lookup == null) return l10n.shortNameInvalid;
                return null;
              },
            ),
            if (_lookup != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: ListTile(
                  leading: _CoopLookupAvatar(lookup: _lookup!),
                  title: Text(
                    l10n.memberLoginConfirmOrg,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  subtitle: Text(
                    _lookup!.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: l10n.memberLoginContinue,
              loading: false,
              onPressed: _lookup == null ? null : _goToStep2,
            ),
          ] else ...[
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListTile(
                leading: _CoopLookupAvatar(lookup: _lookup!),
                title: Text(_lookup!.name),
                trailing: TextButton(
                  onPressed: widget.loading ? null : _backToStep1,
                  child: Text(l10n.memberLoginChangeOrg),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.phone,
                hintText: '01XXXXXXXXX',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.required;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: (v) {
                if (v == null || v.length < 6) return l10n.passwordLengthHint;
                return null;
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: l10n.login,
              loading: widget.loading,
              onPressed: widget.loading ? null : _login,
            ),
          ],
        ],
      ),
    );
  }
}

class _CoopLookupAvatar extends StatelessWidget {
  final CooperativeLookup lookup;

  const _CoopLookupAvatar({required this.lookup});

  @override
  Widget build(BuildContext context) {
    final logo = lookup.logoPath?.trim();
    if (logo != null && logo.isNotEmpty) {
      return ClipOval(
        child: CachedImageFile(
          filePath: logo,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorWidget: _shortNameFallback(context),
        ),
      );
    }
    return _shortNameFallback(context);
  }

  Widget _shortNameFallback(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initial =
        lookup.name.isNotEmpty ? lookup.name[0].toUpperCase() : '?';
    return CircleAvatar(
      backgroundColor: cs.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(fontSize: 11, color: cs.onPrimaryContainer),
      ),
    );
  }
}
