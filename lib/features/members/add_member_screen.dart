import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/picked_image_storage.dart';
import '../../core/auth/admin_route_guard.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/auth/auth_service.dart';
import '../../core/providers.dart';
import '../../core/utils/phone_utils.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/success_toast.dart';
import '../../widgets/cached_image_file.dart';
import '../../l10n/app_localizations.dart';
import 'member_detail_screen.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  final String? memberUuid; // If provided, this is edit mode
  const AddMemberScreen({super.key, this.memberUuid});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen>
    with AdminRouteGuard {
  final _formKey = GlobalKey<FormState>();
  final memberIdCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final nidCtrl = TextEditingController();
  final monthlyCtrl = TextEditingController(text: '1000');
  final _imagePicker = ImagePicker();
  String? _photoPath;

  // Focus nodes for auto-focus on validation errors
  final _memberIdFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _monthlyFocus = FocusNode();

  bool saving = false;
  bool _initialized = false;
  bool _canCollectDeposits = false;

  Future<void> _loadMemberData(WidgetRef ref) async {
    if (widget.memberUuid == null || _initialized) return;
    try {
      final member =
          await ref.read(repoProvider).getMemberByUuid(widget.memberUuid!);
      if (member != null && mounted) {
        setState(() {
          memberIdCtrl.text = member.memberIdNumber;
          nameCtrl.text = member.name;
          phoneCtrl.text = member.phone ?? '';
          addressCtrl.text = member.address ?? '';
          nidCtrl.text = member.nidNumber ?? '';
          monthlyCtrl.text = member.monthlyAmount.toString();
          _photoPath = member.photoPath;
          _canCollectDeposits = member.canCollectDeposits;
          _initialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading member: $e');
      }
    }
  }

  @override
  void dispose() {
    memberIdCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    nidCtrl.dispose();
    monthlyCtrl.dispose();
    _memberIdFocus.dispose();
    _nameFocus.dispose();
    _monthlyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load member data if editing
    if (widget.memberUuid != null && !_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMemberData(ref);
      });
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.memberUuid == null
              ? AppLocalizations.of(context)!.addMember
              : AppLocalizations.of(context)!.editMember)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Photo Upload
                    GestureDetector(
                      onTap: () async {
                        if (!mounted) return;

                        try {
                          // Pick image from gallery
                          XFile? image;
                          try {
                            image = await _imagePicker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                              requestFullMetadata: false,
                            );
                          } catch (pickError) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to pick image: ${pickError.toString()}'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                            return;
                          }

                          if (image == null || !mounted) return;

                          try {
                            final savedPath = await savePickedImage(
                              image,
                              folderName: 'member_photos',
                              filePrefix: 'member',
                            );
                            if (mounted) {
                              setState(() => _photoPath = savedPath);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .errorSavingImage(e.toString())),
                                ),
                              );
                            }
                          }
                        } catch (e, stackTrace) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .unexpectedError(e.toString())),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                          // Log the error for debugging
                          if (kDebugMode) {
                            debugPrint('Image pick error: $e');
                            debugPrint('Stack trace: $stackTrace');
                          }
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        child: _photoPath != null
                            ? CachedImageFile(
                                filePath: _photoPath!,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(8),
                                errorWidget: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                placeholder: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!.addPhoto,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.addPhoto,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (_photoPath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          onPressed: () => setState(() => _photoPath = null),
                          icon: const Icon(Icons.delete, size: 16),
                          label: Text(AppLocalizations.of(context)!.removePhoto,
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: memberIdCtrl,
                      focusNode: _memberIdFocus,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.memberIdNumber,
                        helperText: 'Unique identifier for this member',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _memberIdFocus.requestFocus();
                          });
                          return AppLocalizations.of(context)!.required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nameCtrl,
                      focusNode: _nameFocus,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name,
                        helperText: 'Full name of the member',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _nameFocus.requestFocus();
                          });
                          return AppLocalizations.of(context)!.required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.phone,
                        hintText: '01XXXXXXXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppLocalizations.of(context)!.required;
                        }
                        if (!PhoneUtils.isValidForLogin(v)) {
                          return PhoneUtils.validationMessage(
                              Localizations.localeOf(context).languageCode);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.addressOptional),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nidCtrl,
                      decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.nidNumberOptional),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: monthlyCtrl,
                      focusNode: _monthlyFocus,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.monthlyAmount,
                        helperText: 'Monthly contribution amount',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _monthlyFocus.requestFocus();
                          });
                          return 'Enter a valid amount greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.canCollectDeposits),
                      subtitle: Text(
                        AppLocalizations.of(context)!.canCollectDepositsHint,
                      ),
                      value: _canCollectDeposits,
                      onChanged: (v) => setState(() => _canCollectDeposits = v),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: widget.memberUuid == null
                          ? AppLocalizations.of(context)!.saveMember
                          : AppLocalizations.of(context)!.updateMember,
                      loading: saving,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => saving = true);
                        try {
                          final phoneRaw = phoneCtrl.text.trim();
                          final normalized = PhoneUtils.normalizeForLogin(phoneRaw);
                          if (normalized == null) {
                            throw AuthException(
                                PhoneUtils.validationMessage(
                                    Localizations.localeOf(context)
                                        .languageCode));
                          }
                          final repo = ref.read(repoProvider);
                          var phoneTaken = false;
                          if (widget.memberUuid != null) {
                            final current =
                                await repo.getMemberByUuid(widget.memberUuid!);
                            if (current?.phoneNormalized != normalized) {
                              phoneTaken = await repo.isPhoneTaken(
                                normalized,
                                excludeUuid: widget.memberUuid,
                              );
                            }
                          } else {
                            phoneTaken = await repo.isPhoneTaken(normalized);
                          }
                          if (phoneTaken) {
                            throw AuthException(
                                AppLocalizations.of(context)!.phoneAlreadyUsed);
                          }

                          if (widget.memberUuid == null) {
                            final uuid = const Uuid().v4();
                            final settings = await repo.getSettings();
                            final defaultPassword =
                                settings.defaultMemberPassword;
                            if (defaultPassword.length < 6) {
                              throw AuthException(AppLocalizations.of(context)!
                                  .passwordLengthHint);
                            }
                            await repo.addMember(
                              photoPath: _photoPath,
                              uuid: uuid,
                              memberIdNumber: memberIdCtrl.text.trim(),
                              name: nameCtrl.text.trim(),
                              phone: phoneRaw,
                              phoneNormalized: normalized,
                              address: addressCtrl.text.trim().isEmpty
                                  ? null
                                  : addressCtrl.text.trim(),
                              nidNumber: nidCtrl.text.trim().isEmpty
                                  ? null
                                  : nidCtrl.text.trim(),
                              monthlyAmount:
                                  int.parse(monthlyCtrl.text.trim()),
                              canCollectDeposits: _canCollectDeposits,
                            );
                            await ref.read(authServiceProvider).provisionMemberLogin(
                                  memberUuid: uuid,
                                  phoneNormalized: normalized,
                                  password: defaultPassword,
                                  coopId: ref.read(authSessionProvider).coopId,
                                );
                          } else {
                            await repo.updateMember(
                              uuid: widget.memberUuid!,
                              memberIdNumber: memberIdCtrl.text.trim(),
                              name: nameCtrl.text.trim(),
                              phone: phoneRaw,
                              phoneNormalized: normalized,
                              address: addressCtrl.text.trim().isEmpty
                                  ? null
                                  : addressCtrl.text.trim(),
                              nidNumber: nidCtrl.text.trim().isEmpty
                                  ? null
                                  : nidCtrl.text.trim(),
                              photoPath: _photoPath,
                              monthlyAmount:
                                  int.parse(monthlyCtrl.text.trim()),
                              canCollectDeposits: _canCollectDeposits,
                            );
                          }
                          if (widget.memberUuid != null) {
                            ref.invalidate(memberProvider(widget.memberUuid!));
                          }
                          if (mounted) {
                            showSuccessToast(
                              context,
                              widget.memberUuid == null
                                  ? AppLocalizations.of(context)!.memberSaved
                                  : AppLocalizations.of(context)!.memberUpdated,
                            );
                            Navigator.pop(context);
                          }
                        } on AuthException catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message)),
                            );
                            setState(() => saving = false);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${AppLocalizations.of(context)!.error}: ${e.toString()}')),
                            );
                            setState(() => saving = false);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
