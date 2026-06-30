import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/providers.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/format_utils.dart';
import '../../core/db/app_db.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../l10n/app_localizations.dart';

class AddDepositScreen extends ConsumerStatefulWidget {
  final String? memberUuid;
  final String? depositUuid;
  final bool memberCollectorMode;
  const AddDepositScreen({
    super.key,
    this.memberUuid,
    this.depositUuid,
    this.memberCollectorMode = false,
  });

  @override
  ConsumerState<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends ConsumerState<AddDepositScreen> {
  final _formKey = GlobalKey<FormState>();

  Member? selectedMember;

  final memberQueryCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final amountCtrl = TextEditingController();
  String method = 'cash';
  final receivedByCtrl = TextEditingController();

  // Month range selection for "Month/Reason"
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  String? _fromMonth;
  String? _toMonth;
  int _selectedYear = DateTime.now().year;

  bool saving = false;
  bool _memberLoaded = false;
  bool _depositLoaded = false;

  void _recalculateAmount() {
    // Only auto-calc for new deposits; editing existing should keep stored amount
    if (widget.depositUuid != null) return;
    if (selectedMember == null) return;

    int monthCount = 1;
    if (_fromMonth != null) {
      if (_toMonth != null) {
        // Multi-month: calculate range
        final fromIndex = _months.indexOf(_fromMonth!);
        final toIndex = _months.indexOf(_toMonth!);
        if (fromIndex >= 0 && toIndex >= fromIndex) {
          monthCount = (toIndex - fromIndex) + 1;
        }
      } else {
        // Single month: only From Month selected
        monthCount = 1;
      }
    }

    final base = selectedMember!.monthlyAmount;
    final total = base * monthCount;
    amountCtrl.text = total.toString();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardRoute());
  }

  void _guardRoute() {
    if (!mounted) return;
    if (ref.read(isAdminProvider)) return;

    if (widget.memberCollectorMode) {
      ref.read(canCollectDepositsProvider.future).then((canCollect) {
        if (!mounted) return;
        if (!canCollect) context.go('/my-dashboard');
      });
      return;
    }

    final auth = ref.read(authSessionProvider);
    context.go(auth.isMember ? '/my-dashboard' : '/login');
  }

  @override
  void dispose() {
    memberQueryCtrl.dispose();
    amountCtrl.dispose();
    receivedByCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');

    // Load member from memberUuid if provided
    if (widget.memberUuid != null && !_memberLoaded && selectedMember == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final member =
            await ref.read(repoProvider).getMemberByUuid(widget.memberUuid!);
        if (member != null && mounted) {
          setState(() {
            selectedMember = member;
            memberQueryCtrl.text = '${member.name} (${member.memberIdNumber})';
            _memberLoaded = true;
          });
          _recalculateAmount();
        }
      });
    }

    // Load deposit data if editing
    if (widget.depositUuid != null && !_depositLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final deposit =
            await ref.read(repoProvider).getDepositByUuid(widget.depositUuid!);
        if (deposit != null && mounted) {
          final member =
              await ref.read(repoProvider).getMemberByUuid(deposit.memberUuid);
          setState(() {
            selectedMember = member;
            if (member != null) {
              memberQueryCtrl.text =
                  '${member.name} (${member.memberIdNumber})';
            }
            selectedDate = deposit.date;
            amountCtrl.text = deposit.amount.toString();
            try {
              final parts = deposit.monthKey.split('-');
              if (parts.length == 2) {
                _selectedYear = int.parse(parts[0]);
              }
            } catch (_) {}
            // Try to populate month range if reason is in "X to Y" format
            if (deposit.reason != null && deposit.reason!.contains('to')) {
              final parts = deposit.reason!.split('to');
              if (parts.length == 2) {
                final from = parts[0].trim();
                final to = parts[1].trim();
                if (_months.contains(from)) {
                  _fromMonth = from;
                }
                if (_months.contains(to)) {
                  _toMonth = to;
                }
              }
            } else if (deposit.reason != null &&
                _months.contains(deposit.reason!)) {
              _fromMonth = deposit.reason;
            }
            method = deposit.method;
            receivedByCtrl.text = deposit.receivedBy;
            _depositLoaded = true;
            _memberLoaded = true;
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.depositUuid == null
              ? AppLocalizations.of(context)!.addDeposit
              : AppLocalizations.of(context)!.edit)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: FutureBuilder<SettingsData>(
                future: ref.read(repoProvider).getSettings(),
                builder: (context, snap) {
                  if (snap.hasData && receivedByCtrl.text.isEmpty) {
                    receivedByCtrl.text = snap.data!.defaultReceivedBy;
                  }
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        widget.depositUuid == null
                            ? TypeAheadField<Member>(
                                controller: memberQueryCtrl,
                                suggestionsCallback: (pattern) async {
                                  final list = await ref
                                      .read(repoProvider)
                                      .watchActiveMembers(query: pattern)
                                      .first;
                                  return list.take(12).toList();
                                },
                                itemBuilder: (context, m) => ListTile(
                                  title: Text(m.name),
                                  subtitle: Text(
                                      'ID: ${m.memberIdNumber}  •  Monthly: ${formatCurrencyCompact(m.monthlyAmount)}'),
                                ),
                                onSelected: (m) {
                                  setState(() => selectedMember = m);
                                  memberQueryCtrl.text =
                                      '${m.name} (${m.memberIdNumber})';
                                  _recalculateAmount();
                                },
                                builder: (context, controller, focusNode) {
                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .memberTypeNameOrId,
                                      prefixIcon:
                                          const Icon(Icons.person_search),
                                    ),
                                    validator: (_) => selectedMember == null
                                        ? AppLocalizations.of(context)!.required
                                        : null,
                                  );
                                },
                              )
                            : TextFormField(
                                controller: memberQueryCtrl,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .memberCannotBeChanged,
                                  prefixIcon: const Icon(Icons.person_search),
                                ),
                              ),
                        const SizedBox(height: 10),

                        // Member Details Card
                        if (selectedMember != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.pink.shade200),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.person,
                                    color: Colors.pink.shade700, size: 32),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedMember!.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: ${selectedMember!.memberIdNumber}  •  Monthly: ${formatCurrencyCompact(selectedMember!.monthlyAmount)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.pink.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2025, 1, 1),
                              lastDate: DateTime(2100, 12, 31),
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.date,
                              prefixIcon: const Icon(Icons.date_range),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(df.format(selectedDate)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: amountCtrl,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.amount,
                            prefixIcon: const Icon(Icons.payments_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          readOnly: true,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n <= 0) {
                              return AppLocalizations.of(context)!.required;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          key: ValueKey(_selectedYear),
                          initialValue: _selectedYear,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.selectYear,
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          items: availableYears()
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(y.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedYear = v);
                          },
                        ),
                        const SizedBox(height: 10),
                        // Month range selector (e.g. January to March)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: _fromMonth,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.fromMonth,
                                  prefixIcon: const Icon(Icons.calendar_month),
                                  hintText:
                                      AppLocalizations.of(context)!.selectMonth,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                hint: Text(
                                    AppLocalizations.of(context)!.selectMonth,
                                    overflow: TextOverflow.ellipsis),
                                items: _months
                                    .map((m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m,
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                selectedItemBuilder: (context) {
                                  return _months.map((m) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(m,
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList();
                                },
                                validator: (v) =>
                                    v == null ? 'Select a month' : null,
                                onChanged: (v) {
                                  setState(() {
                                    _fromMonth = v;
                                    // Clear validation error when value changes
                                    _formKey.currentState?.validate();
                                    // Ensure "to" is not before "from"
                                    if (_fromMonth != null &&
                                        _toMonth != null &&
                                        _months.indexOf(_toMonth!) <
                                            _months.indexOf(_fromMonth!)) {
                                      _toMonth = _fromMonth;
                                    }
                                  });
                                  _recalculateAmount();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: _toMonth,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .toMonthOptional,
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  hintText: AppLocalizations.of(context)!
                                      .selectMonthOptional,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                hint: Text(
                                    AppLocalizations.of(context)!
                                        .selectMonthOptional,
                                    overflow: TextOverflow.ellipsis),
                                items: [
                                  // Add a "None" option to clear selection
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .noneSingleMonth,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  ..._months.map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(m,
                                            overflow: TextOverflow.ellipsis),
                                      )),
                                ],
                                selectedItemBuilder: (context) {
                                  return [
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('None (Single Month)',
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    ..._months.map((m) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(m,
                                            overflow: TextOverflow.ellipsis),
                                      );
                                    }),
                                  ];
                                },
                                // No validator - make it optional (always valid)
                                validator: (v) => null,
                                onChanged: (v) {
                                  setState(() {
                                    _toMonth = v;
                                    // Clear validation error when value changes
                                    _formKey.currentState?.validate();
                                    // Ensure "to" is not before "from"
                                    if (_fromMonth != null &&
                                        _toMonth != null &&
                                        _months.indexOf(_toMonth!) <
                                            _months.indexOf(_fromMonth!)) {
                                      _fromMonth = _toMonth;
                                    }
                                  });
                                  _recalculateAmount();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          initialValue: method,
                          decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.paymentMethod,
                            prefixIcon:
                                const Icon(Icons.account_balance_outlined),
                          ),
                          items: [
                            DropdownMenuItem(
                                value: 'cash',
                                child:
                                    Text(AppLocalizations.of(context)!.cash)),
                            DropdownMenuItem(
                                value: 'bkash',
                                child:
                                    Text(AppLocalizations.of(context)!.bkash)),
                            DropdownMenuItem(
                                value: 'nagad',
                                child:
                                    Text(AppLocalizations.of(context)!.nagad)),
                            DropdownMenuItem(
                                value: 'bank',
                                child:
                                    Text(AppLocalizations.of(context)!.bank)),
                          ],
                          onChanged: (v) =>
                              setState(() => method = v ?? 'cash'),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: receivedByCtrl,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.receivedBy,
                            prefixIcon:
                                const Icon(Icons.person_pin_circle_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? AppLocalizations.of(context)!.required
                              : null,
                        ),
                        const SizedBox(height: 14),

                        PrimaryButton(
                          label: widget.depositUuid == null
                              ? AppLocalizations.of(context)!
                                  .confirmGenerateReceiptButton
                              : AppLocalizations.of(context)!.save,
                          loading: saving,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            if (selectedMember == null) return;

                            // Show confirmation dialog for new deposits
                            if (widget.depositUuid == null) {
                              final confirmed = await showConfirmationDialog(
                                context: context,
                                title: AppLocalizations.of(context)!
                                    .confirmDeposit,
                                message:
                                    '${AppLocalizations.of(context)!.depositAmount(formatCurrencyCompact(int.parse(amountCtrl.text.trim())))}\n${AppLocalizations.of(context)!.member(selectedMember!.name)}\n\n${AppLocalizations.of(context)!.confirmGenerateReceipt}',
                                confirmText: AppLocalizations.of(context)!
                                    .confirmGenerateReceiptButton,
                                cancelText:
                                    AppLocalizations.of(context)!.cancel,
                                isDestructive: false,
                              );
                              if (!confirmed) return;
                            }

                            setState(() => saving = true);

                            try {
                              final repo = ref.read(repoProvider);
                              String? reason;
                              if (_fromMonth != null && _toMonth != null) {
                                // Multi-month: "January to March"
                                reason = '$_fromMonth to $_toMonth';
                              } else if (_fromMonth != null) {
                                // Single month: just "January"
                                reason = _fromMonth;
                              } else {
                                reason = null;
                              }
                              // Calculate all monthKeys for the selected range
                              List<String> monthKeysToCheck = [];
                              String? monthKeyOverride;

                              if (_fromMonth != null) {
                                final fromIndex = _months.indexOf(_fromMonth!);
                                final toIndex = _toMonth != null
                                    ? _months.indexOf(_toMonth!)
                                    : fromIndex;

                                if (fromIndex >= 0) {
                                  final year = _selectedYear;

                                  // Generate all monthKeys in the range
                                  for (int i = fromIndex; i <= toIndex; i++) {
                                    final month = i + 1;
                                    final mk =
                                        '$year-${month.toString().padLeft(2, '0')}';
                                    monthKeysToCheck.add(mk);
                                  }

                                  // Use the first month as the primary monthKey for storage
                                  monthKeyOverride = monthKeysToCheck.first;
                                }
                              }

                              if (widget.depositUuid == null) {
                                // Check for duplicate deposits for any month in the range
                                if (monthKeysToCheck.isNotEmpty) {
                                  final existing =
                                      await repo.checkExistingDepositsForMonths(
                                    memberUuid: selectedMember!.uuid,
                                    monthKeys: monthKeysToCheck,
                                  );

                                  if (existing.isNotEmpty) {
                                    final monthNames = existing
                                        .map(monthKeyToName)
                                        .join(', ');

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .duplicateDepositsError(
                                                      monthNames)),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                      setState(() => saving = false);
                                    }
                                    return;
                                  }
                                }

                                // Add new deposit - generate serial from current date/time
                                final receiptSerial = await repo
                                    .generateReceiptSerialFromDateTime(
                                        DateTime.now());
                                final depositUuid = const Uuid().v4();

                                await repo.addDeposit(
                                  uuid: depositUuid,
                                  memberUuid: selectedMember!.uuid,
                                  date: selectedDate,
                                  amount: int.parse(amountCtrl.text.trim()),
                                  reason: reason,
                                  method: method,
                                  receivedBy: receivedByCtrl.text.trim(),
                                  receiptSerial: receiptSerial,
                                  monthKeyOverride: monthKeyOverride,
                                );

                                // Show success confirmation and navigate
                                if (mounted) {
                                  // Store member UUID and name before navigation
                                  final memberUuid = selectedMember!.uuid;
                                  final memberName = selectedMember!.name;

                                  setState(() => saving = false);

                                  // Show snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.white),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Deposit added successfully for $memberName',
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );

                                  // Wait for snackbar to be visible, then navigate
                                  await Future.delayed(
                                      const Duration(milliseconds: 2000));

                                  // Navigate to member profile
                                  if (mounted && context.mounted) {
                                    // Pop current screen and navigate in one smooth action
                                    Navigator.of(context).pop();
                                    // Small delay to ensure pop completes
                                    await Future.delayed(
                                        const Duration(milliseconds: 100));
                                    if (context.mounted) {
                                      context.push('/member/$memberUuid');
                                    }
                                  }
                                  // Exit early to prevent duplicate pop
                                  return;
                                }
                              } else {
                                // Check for duplicate deposits when updating (if month range changed)
                                if (monthKeysToCheck.isNotEmpty) {
                                  final existing =
                                      await repo.checkExistingDepositsForMonths(
                                    memberUuid: selectedMember!.uuid,
                                    monthKeys: monthKeysToCheck,
                                    excludeDepositUuid: widget.depositUuid,
                                  );

                                  if (existing.isNotEmpty) {
                                    final monthNames = existing
                                        .map(monthKeyToName)
                                        .join(', ');

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .duplicateDepositsError(
                                                      monthNames)),
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                      setState(() => saving = false);
                                    }
                                    return;
                                  }
                                }

                                // Update existing deposit
                                await repo.updateDeposit(
                                  uuid: widget.depositUuid!,
                                  date: selectedDate,
                                  amount: int.parse(amountCtrl.text.trim()),
                                  reason: reason,
                                  method: method,
                                  receivedBy: receivedByCtrl.text.trim(),
                                  monthKeyOverride: monthKeyOverride,
                                );

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.white),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .depositUpdated)),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );

                                  // For edit mode, just pop back after showing snackbar
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));

                                  if (mounted && context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
