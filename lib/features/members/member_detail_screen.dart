import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/picked_image_storage.dart';
import '../../core/providers.dart';
import '../../widgets/success_toast.dart' show showSuccessToast;
import '../../core/utils/format_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/cached_image_file.dart';
import '../../l10n/app_localizations.dart';

final memberProvider = FutureProvider.family(
    (ref, String uuid) => ref.watch(repoProvider).getMemberByUuid(uuid));
final memberDepositsProvider = StreamProvider.family((ref, String uuid) {
  return coopScopedStream(
    ref,
    () => ref.watch(repoProvider).watchMemberDeposits(uuid),
  );
});

class MemberDetailScreen extends ConsumerStatefulWidget {
  final String memberUuid;
  final bool readOnly;
  const MemberDetailScreen({
    super.key,
    required this.memberUuid,
    this.readOnly = false,
  });

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  final _imagePicker = ImagePicker();
  bool _updatingPhoto = false;
  String _dateFilter = 'all'; // 'all', 'thisMonth', 'lastMonth', 'custom'
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  String _formatReceiptNumber(int receiptSerial, [String prefix = 'RCPT']) {
    final serialStr = receiptSerial.toString();
    if (serialStr.length >= 14) {
      // Date/time based serial: Format as YYYY-MM-DD-HHMMSS
      final year = serialStr.substring(0, 4);
      final month = serialStr.substring(4, 6);
      final day = serialStr.substring(6, 8);
      final time = serialStr.substring(8, 14);
      return '$prefix-$year$month$day-$time';
    } else {
      // Fallback for old format (backward compatibility)
      return '$prefix-${receiptSerial.toString().padLeft(4, '0')}';
    }
  }

  List _filterDeposits(List deposits) {
    if (_dateFilter == 'all') return deposits;

    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (_dateFilter) {
      case 'thisMonth':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'lastMonth':
        final lastMonth = DateTime(now.year, now.month - 1);
        startDate = DateTime(lastMonth.year, lastMonth.month, 1);
        endDate = DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);
        break;
      case 'custom':
        if (_customStartDate == null || _customEndDate == null) return deposits;
        startDate = _customStartDate!;
        endDate = DateTime(_customEndDate!.year, _customEndDate!.month,
            _customEndDate!.day, 23, 59, 59);
        break;
      default:
        return deposits;
    }

    return deposits.where((d) {
      return d.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          d.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _updateProfilePhoto(String memberUuid) async {
    if (_updatingPhoto) return;
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image == null) return;

      setState(() => _updatingPhoto = true);
      final savedPath = await savePickedImage(
        image,
        folderName: 'images',
        filePrefix: 'member',
      );
      await ref.read(repoProvider).updateMember(
            uuid: memberUuid,
            photoPath: savedPath,
          );
      ref.invalidate(memberProvider(memberUuid));
      if (mounted) {
        showSuccessToast(
          context,
          AppLocalizations.of(context)!.profilePhotoUpdated,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mAsync = ref.watch(memberProvider(widget.memberUuid));
    final dAsync = ref.watch(memberDepositsProvider(widget.memberUuid));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.memberDetails),
        actions: [
          if (!widget.readOnly)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: AppLocalizations.of(context)!.editMember,
              onPressed: () =>
                  context.push('/edit-member/${widget.memberUuid}'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const ClampingScrollPhysics(),
        children: [
          mAsync.when(
            data: (m) {
              if (m == null) {
                return Text(AppLocalizations.of(context)!.errorLoadingMember);
              }
              return Stack(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Member Photo
                          Center(
                            child: GestureDetector(
                              onTap: widget.readOnly && !_updatingPhoto
                                  ? () => _updateProfilePhoto(m.uuid)
                                  : null,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                    child: _updatingPhoto
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : (m.photoPath != null &&
                                                m.photoPath!.trim().isNotEmpty)
                                            ? CachedImageFile(
                                                filePath: m.photoPath!.trim(),
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                placeholder: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2)),
                                                errorWidget: Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant),
                                              )
                                            : Icon(Icons.person,
                                                size: 60,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant),
                                  ),
                                  if (widget.readOnly)
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      child: const Icon(Icons.camera_alt,
                                          size: 16, color: Colors.white),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(m.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                              '${AppLocalizations.of(context)!.memberId}: ${m.memberIdNumber}'),
                          if ((m.phone ?? '').isNotEmpty)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(AppLocalizations.of(context)!
                                      .phoneLabel(m.phone!)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  iconSize: 18,
                                  color: Colors.blue.shade700,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  tooltip: AppLocalizations.of(context)!
                                      .copyPhoneNumber,
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: m.phone!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.check_circle,
                                                color: Colors.white, size: 20),
                                            const SizedBox(width: 8),
                                            Text(AppLocalizations.of(context)!
                                                .phoneCopied),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          if ((m.address ?? '').isNotEmpty)
                            Text(AppLocalizations.of(context)!
                                .addressLabel(m.address!)),
                          if ((m.nidNumber ?? '').isNotEmpty)
                            Text(AppLocalizations.of(context)!
                                .nidLabel(m.nidNumber!)),
                          const SizedBox(height: 8),
                          Text(
                              AppLocalizations.of(context)!.monthlyAmountLabel(
                                  formatCurrencyCompact(m.monthlyAmount)),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          if (!widget.readOnly)
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => context.push(
                                        '/add-deposit?memberUuid=${m.uuid}'),
                                    icon: const Icon(
                                        Icons.account_balance_wallet,
                                        size: 18),
                                    label: Text(AppLocalizations.of(context)!
                                        .addDeposit),
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                  ),
                  if (!widget.readOnly)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      tooltip: AppLocalizations.of(context)!.deleteMember,
                      onPressed: () async {
                        final confirmed = await showConfirmationDialog(
                          context: context,
                          title: AppLocalizations.of(context)!.deleteMember,
                          message: AppLocalizations.of(context)!
                              .deleteMemberConfirm(m.name),
                          confirmText: AppLocalizations.of(context)!.delete,
                        );
                        if (confirmed && context.mounted) {
                          await ref.read(repoProvider).softDeleteMember(m.uuid);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator())),
            error: (e, _) => const Text('Error: '),
          ),
          const SizedBox(height: 12),
          // Balance View Card
          mAsync.when(
            data: (m) {
              if (m == null) return const SizedBox.shrink();
              return FutureBuilder<List>(
                future: ref
                    .read(repoProvider)
                    .watchMemberDeposits(widget.memberUuid)
                    .first,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final deposits = snap.data!;
                  final totalDeposited = deposits.fold<int>(
                      0, (sum, d) => sum + (d.amount as int));

                  // Calculate expected total (from 2025-01-01 to now)
                  final startDate = DateTime(2025, 1, 1);
                  final endDate = DateTime.now();
                  final months = monthKeysBetweenInclusive(startDate, endDate);
                  final expectedTotal = m.monthlyAmount * months.length;

                  // Net Due/Advance
                  final netAmount = expectedTotal - totalDeposited;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.balanceSummary,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _BalanceItem(
                                  label: AppLocalizations.of(context)!
                                      .totalDeposited,
                                  value: formatCurrencyCompact(totalDeposited),
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _BalanceItem(
                                  label: AppLocalizations.of(context)!
                                      .expectedTotal,
                                  value: formatCurrencyCompact(expectedTotal),
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: netAmount >= 0
                                  ? Colors.red.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: netAmount >= 0
                                    ? Colors.red.shade200
                                    : Colors.green.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  netAmount >= 0
                                      ? AppLocalizations.of(context)!
                                          .netDueAdvance
                                      : AppLocalizations.of(context)!
                                          .netDueAdvance,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: netAmount >= 0
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  formatCurrencyCompact(netAmount.abs()),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: netAmount >= 0
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.deposits,
                  style: Theme.of(context).textTheme.titleMedium),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) async {
                  if (value == 'custom') {
                    final start = await showDatePicker(
                      context: context,
                      initialDate: _customStartDate ?? DateTime.now(),
                      firstDate: DateTime(2025, 1, 1),
                      lastDate: DateTime.now(),
                    );
                    if (start == null) return;
                    final end = await showDatePicker(
                      context: context,
                      initialDate: _customEndDate ?? start,
                      firstDate: start,
                      lastDate: DateTime.now(),
                    );
                    if (end == null) return;
                    setState(() {
                      _dateFilter = 'custom';
                      _customStartDate = start;
                      _customEndDate = end;
                    });
                  } else {
                    setState(() => _dateFilter = value);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: 'all',
                      child: Text(AppLocalizations.of(context)!.all)),
                  PopupMenuItem(
                      value: 'thisMonth',
                      child: Text(AppLocalizations.of(context)!.thisMonth)),
                  PopupMenuItem(
                      value: 'lastMonth',
                      child: Text(AppLocalizations.of(context)!.lastMonth)),
                  PopupMenuItem(
                      value: 'custom',
                      child: Text(AppLocalizations.of(context)!.customRange)),
                ],
              ),
            ],
          ),
          if (_dateFilter == 'custom' &&
              _customStartDate != null &&
              _customEndDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Chip(
                label: Text(
                    '${DateFormat('MMM dd').format(_customStartDate!)} - ${DateFormat('MMM dd, yyyy').format(_customEndDate!)}'),
                onDeleted: () => setState(() {
                  _dateFilter = 'all';
                  _customStartDate = null;
                  _customEndDate = null;
                }),
              ),
            ),
          const SizedBox(height: 8),
          dAsync.when(
            data: (items) {
              final filteredItems = _filterDeposits(items);

              if (filteredItems.isEmpty) {
                return EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: items.isEmpty
                      ? AppLocalizations.of(context)!.noDeposits
                      : AppLocalizations.of(context)!.noDeposits,
                  message: items.isEmpty
                      ? 'Add a deposit to get started'
                      : 'Try selecting a different date range',
                  actionLabel: items.isEmpty && !widget.readOnly
                      ? AppLocalizations.of(context)!.addDeposit
                      : null,
                  onAction: items.isEmpty && !widget.readOnly
                      ? () => mAsync.whenData((m) => m != null
                          ? context.push(
                              '/add-deposit?memberUuid=${widget.memberUuid}')
                          : null)
                      : null,
                );
              }
              final df = DateFormat('yyyy-MM-dd');
              final totalDeposited = filteredItems.fold<int>(
                  0, (sum, d) => sum + (d.amount as int));
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.totalDeposited,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatCurrencyCompact(totalDeposited),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Scrollable area for deposits with fixed height
                    SizedBox(
                      height: 450, // Fixed height for scrollable area
                      child: ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final d = filteredItems[i];
                          return ListTile(
                            dense: true, // Make ListTile more compact
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            title: Text(formatCurrencyCompact(d.amount)),
                            subtitle: Text(
                                'Month: ${monthKeyToName(d.monthKey)}  •  ${df.format(d.date)}  •  ${_formatReceiptNumber(d.receiptSerial, 'RCPT')}',
                                style: const TextStyle(fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Share Receipt',
                                  icon: const Icon(Icons.share, size: 18),
                                  iconSize: 18,
                                  color: Colors.blue.shade700,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  onPressed: () async {
                                    final org = await ref
                                        .read(repoProvider)
                                        .watchOrganization()
                                        .first;
                                    final settings = await ref
                                        .read(repoProvider)
                                        .watchSettings()
                                        .first;
                                    final member = await ref
                                        .read(repoProvider)
                                        .getMemberByUuid(widget.memberUuid);
                                    final deposit = await ref
                                        .read(repoProvider)
                                        .getDepositByUuid(d.uuid);
                                    if (member == null || deposit == null)
                                      return;

                                    final file = await ref
                                        .read(receiptServiceProvider)
                                        .generateReceiptPdf(
                                          org: org,
                                          member: member,
                                          deposit: deposit,
                                          settings: settings,
                                        );
                                    await ref
                                        .read(repoProvider)
                                        .updateDepositReceiptPath(
                                            d.uuid, file.path);
                                    await ref
                                        .read(receiptServiceProvider)
                                        .sharePdf(file, text: 'Receipt');
                                  },
                                ),
                                if (!widget.readOnly) ...[
                                  IconButton(
                                    tooltip: 'Edit Deposit',
                                    icon: const Icon(Icons.edit, size: 18),
                                    iconSize: 18,
                                    color: Colors.orange.shade700,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    onPressed: () {
                                      final uuid = d.uuid
                                          .trim()
                                          .replaceAll('\n', '')
                                          .replaceAll('\r', '');
                                      context.push('/edit-deposit/$uuid');
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Delete to Trash',
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18),
                                    iconSize: 18,
                                    color: Colors.red.shade700,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    onPressed: () async {
                                      final confirmed =
                                          await showConfirmationDialog(
                                        context: context,
                                        title: AppLocalizations.of(context)!
                                            .delete,
                                        message: AppLocalizations.of(context)!
                                            .deleteMemberConfirm('deposit'),
                                        confirmText:
                                            AppLocalizations.of(context)!
                                                .delete,
                                      );
                                      if (confirmed) {
                                        await ref
                                            .read(repoProvider)
                                            .softDeleteDeposit(d.uuid);
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator())),
            error: (e, _) => const Text('Error: '),
          ),
          const SizedBox(height: 14),
          FutureBuilder<Map<String, dynamic>>(
            future: ref.read(repoProvider).dueForOneMember(
                  memberUuid: widget.memberUuid,
                  start: DateTime(2025, 1, 1),
                  endInclusive: DateTime.now(),
                ),
            builder: (context, snap) {
              final totalDue = (snap.data?['totalDue'] as int?) ?? 0;
              final dueMonths =
                  (snap.data?['dueMonths'] as Map<String, int>?) ??
                      <String, int>{};
              final keys = dueMonths.keys.toList()..sort();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.totalDue,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                          '${AppLocalizations.of(context)!.totalDue}: ${formatCurrencyCompact(totalDue)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: totalDue > 0
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          )),
                      const SizedBox(height: 8),
                      if (keys.isEmpty)
                        Text(AppLocalizations.of(context)!.noDue,
                            style: const TextStyle(color: Colors.green)),
                      if (keys.isNotEmpty)
                        ...keys.map((k) {
                          final monthName = monthKeyToName(k);
                          return Padding(
                            padding: const EdgeInsets.only(left: 8, top: 4),
                            child: Text(
                              '→ $monthName (${formatCurrencyCompact(dueMonths[k]!)})',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BalanceItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
