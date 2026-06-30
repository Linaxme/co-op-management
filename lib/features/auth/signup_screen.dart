import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';
import '../../core/providers.dart';
import '../../core/utils/coop_short_name.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/auth_page_shell.dart';
import '../../widgets/primary_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameCtrl = TextEditingController();
  final _shortNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _orgNameCtrl.dispose();
    _shortNameCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _error = AppLocalizations.of(context)!.passwordMismatch);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final shortName = CoopShortName.normalize(_shortNameCtrl.text);
      final auth = ref.read(authServiceProvider);
      if (!await auth.isShortNameAvailable(shortName)) {
        throw AuthException(AppLocalizations.of(context)!.shortNameTaken);
      }

      await ref.read(authProvider.notifier).signUpCooperative(
            organizationName: _orgNameCtrl.text.trim(),
            organizationAddress: _addressCtrl.text.trim(),
            organizationShortName: shortName,
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );

      await ref.read(repoProvider).updateOrganization(
            name: _orgNameCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            shortName: shortName,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.signUpSuccess),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = AppLocalizations.of(context)!.signUpFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: AuthPageShell(
        title: l10n.signUpTitle,
        subtitle: l10n.signUpSubtitle,
        footer: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(l10n.alreadyHaveAccount),
          ),
          const SizedBox(height: 8),
        ],
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _orgNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.organizationName,
                  prefixIcon: const Icon(Icons.business_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shortNameCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.organizationShortName,
                  hintText: l10n.organizationShortNameHint,
                  helperText: l10n.organizationShortNameHelper,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.required;
                  if (CoopShortName.validationError(v) != null) {
                    return l10n.shortNameInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.organizationAddress,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
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
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return l10n.passwordLengthHint;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.confirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.required;
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.signUp,
                loading: _loading,
                onPressed: _loading ? null : _signUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
