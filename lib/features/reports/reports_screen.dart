import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/db/app_db.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/success_toast.dart' show showSuccessToast;
import '../../l10n/app_localizations.dart';

final _orgProvider =
    StreamProvider((ref) => ref.watch(repoProvider).watchOrganization());

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int year = DateTime.now().year;
  String? selectedMemberUuid;
  DateTime selectedMonth = DateTime.now();
  bool loadingAnnual = false;
  bool loadingMember = false;
  bool loadingMonthly = false;

  @override
  Widget build(BuildContext context) {
    final orgAsync = ref.watch(_orgProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reports),
        actions: [
          IconButton(
            onPressed: () => context.push('/trash'),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: AppLocalizations.of(context)!.trash,
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
      body: orgAsync.when(
        data: (org) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Annual Report
            Card(
              child: ExpansionTile(
                leading: Icon(Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(AppLocalizations.of(context)!.annualReport),
                subtitle: Text(AppLocalizations.of(context)!.yearWiseSummary),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: year,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.selectYear,
                            prefixIcon: const Icon(Icons.calendar_month),
                          ),
                          items: () {
                            final currentYear = DateTime.now().year;
                            const firstYear = 2025;
                            final years = <int>[];
                            for (var y = currentYear; y >= firstYear; y--) {
                              years.add(y);
                            }
                            return years
                                .map(
                                  (y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(
                                      y.toString(),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                )
                                .toList();
                          }(),
                          onChanged: (v) => setState(() => year = v ?? year),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: AppLocalizations.of(context)!.generatePdf,
                          loading: loadingAnnual,
                          onPressed: () async {
                            setState(() => loadingAnnual = true);
                            try {
                              final file = await ref
                                  .read(reportServiceProvider)
                                  .generateAnnualReportPdf(
                                    year: year,
                                    org: org,
                                  );
                              if (mounted) {
                                showSuccessToast(
                                    context,
                                    AppLocalizations.of(context)!
                                        .reportGenerated);
                                await ref
                                    .read(receiptServiceProvider)
                                    .sharePdf(file, text: 'Annual Report ');
                              }
                            } finally {
                              if (mounted) {
                                setState(() => loadingAnnual = false);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: loadingAnnual
                                    ? null
                                    : () async {
                                        setState(() => loadingAnnual = true);
                                        try {
                                          final file = await ref
                                              .read(reportServiceProvider)
                                              .exportAnnualReportCsv(
                                                  year: year);
                                          if (mounted) {
                                            showSuccessToast(context,
                                                'CSV exported successfully');
                                            await ref
                                                .read(reportServiceProvider)
                                                .shareFile(file,
                                                    text: 'Annual Report CSV');
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(
                                                () => loadingAnnual = false);
                                          }
                                        }
                                      },
                                icon: const Icon(Icons.file_download, size: 18),
                                label: const Text('Export CSV'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: loadingAnnual
                                    ? null
                                    : () async {
                                        setState(() => loadingAnnual = true);
                                        try {
                                          final file = await ref
                                              .read(reportServiceProvider)
                                              .exportAnnualReportExcel(
                                                  year: year);
                                          if (mounted) {
                                            showSuccessToast(context,
                                                'Excel exported successfully');
                                            await ref
                                                .read(reportServiceProvider)
                                                .shareFile(file,
                                                    text:
                                                        'Annual Report Excel');
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(
                                                () => loadingAnnual = false);
                                          }
                                        }
                                      },
                                icon: const Icon(Icons.table_chart, size: 18),
                                label: const Text('Export Excel'),
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
            const SizedBox(height: 12),

            // 2. Member Report
            Card(
              child: ExpansionTile(
                leading: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(AppLocalizations.of(context)!.memberReport),
                subtitle:
                    Text(AppLocalizations.of(context)!.individualMemberDetails),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        FutureBuilder<List<Member>>(
                          future:
                              ref.read(repoProvider).watchActiveMembers().first,
                          builder: (context, snap) {
                            final members = snap.data ?? const <Member>[];
                            if (members.isNotEmpty &&
                                selectedMemberUuid == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() =>
                                      selectedMemberUuid = members.first.uuid);
                                }
                              });
                            }
                            return DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedMemberUuid,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.selectMember,
                                prefixIcon: const Icon(Icons.person_outline),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                              items: members
                                  .map((m) => DropdownMenuItem(
                                        value: m.uuid,
                                        child: Text(
                                          '${m.name} (${m.memberIdNumber})',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ))
                                  .toList(),
                              selectedItemBuilder: (context) => members
                                  .map((m) => Text(
                                        '${m.name} (${m.memberIdNumber})',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedMemberUuid = v),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: AppLocalizations.of(context)!.generatePdf,
                          loading: loadingMember,
                          onPressed: () async {
                            final uuid = selectedMemberUuid;
                            if (uuid == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .required)),
                              );
                              return;
                            }

                            setState(() => loadingMember = true);
                            try {
                              final file = await ref
                                  .read(reportServiceProvider)
                                  .generateMemberReportPdf(
                                    memberUuid: uuid,
                                    start: DateTime(2025, 1, 1),
                                    endInclusive: DateTime.now(),
                                    org: org,
                                  );
                              if (mounted) {
                                showSuccessToast(
                                    context,
                                    AppLocalizations.of(context)!
                                        .reportGenerated);
                                await ref
                                    .read(receiptServiceProvider)
                                    .sharePdf(file, text: 'Member Report');
                              }
                            } finally {
                              if (mounted) {
                                setState(() => loadingMember = false);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Monthly Report
            Card(
              child: ExpansionTile(
                leading: Icon(Icons.calendar_month,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(AppLocalizations.of(context)!.monthlyReport),
                subtitle:
                    Text(AppLocalizations.of(context)!.monthWiseCollection),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Shows who paid and who did not pay for a specific month',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedMonth,
                              firstDate: DateTime(2025, 1, 1),
                              lastDate: DateTime(2100, 12, 31),
                            );
                            if (picked != null) {
                              setState(() => selectedMonth = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.selectMonth,
                              prefixIcon: const Icon(Icons.calendar_month),
                            ),
                            child:
                                Text(monthKeyToName(monthKey(selectedMonth))),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: AppLocalizations.of(context)!.generatePdf,
                          loading: loadingMonthly,
                          onPressed: () async {
                            setState(() => loadingMonthly = true);
                            try {
                              final monthKeyValue = monthKey(selectedMonth);
                              final file = await ref
                                  .read(reportServiceProvider)
                                  .generateMonthlyReportPdf(
                                    monthKey: monthKeyValue,
                                    org: org,
                                  );
                              if (mounted) {
                                showSuccessToast(
                                    context,
                                    AppLocalizations.of(context)!
                                        .reportGenerated);
                                await ref
                                    .read(receiptServiceProvider)
                                    .sharePdf(file, text: 'Monthly Report');
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${AppLocalizations.of(context)!.error}: $e')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => loadingMonthly = false);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: loadingMonthly
                                    ? null
                                    : () async {
                                        setState(() => loadingMonthly = true);
                                        try {
                                          final monthKeyValue =
                                              monthKey(selectedMonth);
                                          final file = await ref
                                              .read(reportServiceProvider)
                                              .exportMonthlyReportCsv(
                                                  monthKey: monthKeyValue);
                                          if (mounted) {
                                            showSuccessToast(context,
                                                'CSV exported successfully');
                                            await ref
                                                .read(reportServiceProvider)
                                                .shareFile(file,
                                                    text: 'Monthly Report CSV');
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(
                                                () => loadingMonthly = false);
                                          }
                                        }
                                      },
                                icon: const Icon(Icons.file_download, size: 18),
                                label: const Text('Export CSV'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: loadingMonthly
                                    ? null
                                    : () async {
                                        setState(() => loadingMonthly = true);
                                        try {
                                          final monthKeyValue =
                                              monthKey(selectedMonth);
                                          final file = await ref
                                              .read(reportServiceProvider)
                                              .exportMonthlyReportExcel(
                                                  monthKey: monthKeyValue);
                                          if (mounted) {
                                            showSuccessToast(context,
                                                'Excel exported successfully');
                                            await ref
                                                .read(reportServiceProvider)
                                                .shareFile(file,
                                                    text:
                                                        'Monthly Report Excel');
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(
                                                () => loadingMonthly = false);
                                          }
                                        }
                                      },
                                icon: const Icon(Icons.table_chart, size: 18),
                                label: const Text('Export Excel'),
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
            const SizedBox(height: 16),
          ],
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading organization: $e'),
          ),
        ),
      ),
    );
  }
}
