import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/db/app_db.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/format_utils.dart';
import '../../widgets/org_header_card.dart';
import '../../widgets/sync_status_chip.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/app_localizations.dart';

final _orgProvider =
    StreamProvider((ref) => ref.watch(repoProvider).watchOrganization());
final _lastDepositsProvider = StreamProvider(
    (ref) => ref.watch(repoProvider).watchLastDeposits(limit: 5));
final _membersProvider =
    StreamProvider((ref) => ref.watch(repoProvider).watchActiveMembers());

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _chartYear = DateTime.now().year;
  int _statsYear = DateTime.now().year;
  int _statsMonth = DateTime.now().month;

  String get _statsMonthKey => monthKeyFromYearMonth(_statsYear, _statsMonth);

  Widget _buildMonthYearSelectors(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            key: ValueKey('stats-year-$_statsYear'),
            initialValue: _statsYear,
            decoration: InputDecoration(
              labelText: l10n.selectYear,
              prefixIcon: const Icon(Icons.calendar_today),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: availableYears()
                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _statsYear = v);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<int>(
            key: ValueKey('stats-month-$_statsMonth'),
            initialValue: _statsMonth,
            decoration: InputDecoration(
              labelText: l10n.selectMonth,
              prefixIcon: const Icon(Icons.calendar_month),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: List.generate(
              12,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(calendarMonthName(i + 1)),
              ),
            ),
            onChanged: (v) {
              if (v != null) setState(() => _statsMonth = v);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgAsync = ref.watch(_orgProvider);
    final lastAsync = ref.watch(_lastDepositsProvider);
    final membersAsync = ref.watch(_membersProvider);

    final now = DateTime.now();
    final selectedMonth = _statsMonthKey;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: SyncStatusChip(),
          ),
          IconButton(
            onPressed: () => context.push('/add-member'),
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: AppLocalizations.of(context)!.addMember,
          ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_orgProvider);
          ref.invalidate(_lastDepositsProvider);
          ref.invalidate(_membersProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            orgAsync.when(
              data: (org) => OrgHeaderCard(
                name: org.name,
                address: org.address,
                logoPath: org.logoPath,
                shortName: org.shortName,
              ),
              loading: () => const _Skeleton(height: 92),
              error: (e, _) => _ErrorCard(
                  AppLocalizations.of(context)!.failedToLoadOrganization),
            ),
            const SizedBox(height: 12),
            FutureBuilder<int>(
              future: ref.read(repoProvider).totalCollectionAllTime(),
              builder: (context, snap) {
                final total = snap.data ?? 0;
                return _MetricCard(
                  title: AppLocalizations.of(context)!.totalCollection,
                  value: formatCurrencyCompact(total),
                  icon: Icons.account_balance_wallet,
                  onTap: () async {
                    final byMonth =
                        await ref.read(repoProvider).collectionByMonth();
                    final members =
                        await ref.read(repoProvider).watchActiveMembers().first;
                    if (!context.mounted) return;
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => _MonthMapSheet(
                          title:
                              AppLocalizations.of(context)!.collectionByMonth,
                          data: byMonth,
                          members: members),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<Map<String, dynamic>>(
              future: ref.read(repoProvider).dueSummaryAllMembers(
                    start: DateTime(2025, 1, 1),
                    endInclusive: now,
                  ),
              builder: (context, snap) {
                final totalDue = (snap.data?['totalDue'] as int?) ?? 0;
                return _MetricCard(
                  title: AppLocalizations.of(context)!.totalDue,
                  value: formatCurrencyCompact(totalDue),
                  icon: Icons.warning_amber,
                  onTap: () async {
                    final due =
                        await ref.read(repoProvider).dueSummaryAllMembers(
                              start: DateTime(2025, 1, 1),
                              endInclusive: now,
                            );
                    final members =
                        (due['members'] as List).cast<Map<String, dynamic>>();
                    if (!context.mounted) return;
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => _DueMembersSheet(members: members),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            _buildMonthYearSelectors(context),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .currentMonth(monthKeyToName(selectedMonth)),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<int>(
                            future: ref
                                .read(repoProvider)
                                .collectionForMonth(selectedMonth),
                            builder: (context, snap) {
                              final v = snap.data ?? 0;
                              return _SmallStat(
                                  title:
                                      AppLocalizations.of(context)!.collection,
                                  value:
                                      NumberFormat.decimalPattern().format(v),
                                  onTap: () async {
                                    final paidMembers = await ref
                                        .read(repoProvider)
                                        .getPaidMembersForMonth(selectedMonth);
                                    if (!context.mounted) return;
                                    showModalBottomSheet(
                                      context: context,
                                      showDragHandle: true,
                                      builder: (_) => _PaidMembersSheet(
                                        monthName: monthKeyToName(selectedMonth),
                                        members: paidMembers,
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: ref.read(repoProvider).dueSummaryAllMembers(
                                  start: DateTime(2025, 1, 1),
                                  endInclusive:
                                      DateTime(now.year, now.month, 1),
                                ),
                            builder: (context, snap) {
                              final members = (snap.data?['members'] as List?)
                                      ?.cast<Map<String, dynamic>>() ??
                                  [];
                              int monthDue = 0;
                              for (final m in members) {
                                final dueMonths =
                                    (m['dueMonths'] as Map<String, int>);
                                monthDue += dueMonths[selectedMonth] ?? 0;
                              }
                              return _SmallStat(
                                  title: AppLocalizations.of(context)!.due,
                                  value: NumberFormat.decimalPattern()
                                      .format(monthDue),
                                  onTap: () async {
                                    final unpaidMembers = await ref
                                        .read(repoProvider)
                                        .getUnpaidMembersForMonth(selectedMonth);
                                    if (!context.mounted) return;
                                    showModalBottomSheet(
                                      context: context,
                                      showDragHandle: true,
                                      builder: (_) => _UnpaidMembersSheet(
                                        monthName: monthKeyToName(selectedMonth),
                                        members: unpaidMembers,
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    membersAsync.when(
                      data: (members) =>
                          Text('Active Members: ${members.length}'),
                      loading: () => const Text('Active Members: ...'),
                      error: (e, _) => const Text('Active Members: -'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _CollectionByMonthChart(
              year: _chartYear,
              onYearChanged: (y) => setState(() => _chartYear = y),
            ),
            const SizedBox(height: 12),
            // Paid/Not Paid Pie Chart
            FutureBuilder<Map<String, dynamic>>(
              key: ValueKey(selectedMonth),
              future: Future.wait([
                ref.read(repoProvider).watchActiveMembers().first,
                ref.read(repoProvider).collectionForMonth(selectedMonth),
              ]).then((results) => {
                    'members': results[0] as List,
                    'monthCollection': results[1] as int,
                  }),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                final members = snap.data!['members'] as List;
                final monthCollection = snap.data!['monthCollection'] as int;

                // Calculate expected collection for selected month
                final expectedCollection = members.fold<int>(
                    0, (sum, m) => sum + (m.monthlyAmount as int));
                final paidAmount = monthCollection;
                final notPaidAmount = expectedCollection - paidAmount;

                if (expectedCollection == 0) {
                  return const SizedBox.shrink();
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .monthPaymentStatus(monthKeyToName(selectedMonth)),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    sections: [
                                      PieChartSectionData(
                                        value: paidAmount.toDouble(),
                                        title:
                                            '${((paidAmount / expectedCollection) * 100).toStringAsFixed(1)}%',
                                        color: Colors.green,
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: notPaidAmount > 0
                                            ? notPaidAmount.toDouble()
                                            : 0,
                                        title: notPaidAmount > 0
                                            ? '${((notPaidAmount / expectedCollection) * 100).toStringAsFixed(1)}%'
                                            : '',
                                        color: Colors.red,
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _LegendItem(
                                    color: Colors.green,
                                    label: 'Paid',
                                    value: formatCurrencyCompact(paidAmount),
                                  ),
                                  const SizedBox(height: 12),
                                  _LegendItem(
                                    color: Colors.red,
                                    label: 'Not Paid',
                                    value: formatCurrencyCompact(
                                        notPaidAmount > 0 ? notPaidAmount : 0),
                                  ),
                                  const SizedBox(height: 12),
                                  _LegendItem(
                                    color: Colors.blue,
                                    label: 'Expected',
                                    value: formatCurrencyCompact(
                                        expectedCollection),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.deposits,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            lastAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Card(
                      child: Padding(
                          padding: const EdgeInsets.all(14),
                          child:
                              Text(AppLocalizations.of(context)!.noDeposits)));
                }
                return Card(
                  child: Column(
                    children: [
                      const _TableHeader(),
                      const Divider(height: 1),
                      ...items.map((d) => _DepositRow(deposit: d)),
                    ],
                  ),
                );
              },
              loading: () => const _Skeleton(height: 180),
              error: (e, _) => const _ErrorCard('Failed to load transactions'),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}

class _CollectionByMonthChart extends ConsumerWidget {
  final int year;
  final ValueChanged<int> onYearChanged;

  const _CollectionByMonthChart({
    required this.year,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<Map<String, int>>(
      future: ref.read(repoProvider).collectionByMonthForYear(year),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = monthKeysForYear(year, snap.data!);
        final keys = data.keys.toList()..sort();
        final maxValue = data.values.fold<int>(0, (a, b) => a > b ? a : b);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.collectionByMonth,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<int>(
                        key: ValueKey(year),
                        initialValue: year,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.selectYear,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
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
                          if (v != null) onYearChanged(v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (maxValue == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        l10n.noDeposits,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxValue.toDouble() * 1.2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.blue,
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final mk = keys[group.x.toInt()];
                              return BarTooltipItem(
                                '${monthKeyToName(mk)}\n${formatCurrencyCompact(rod.toY.toInt())}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < keys.length) {
                                  final parts = keys[value.toInt()].split('-');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      DateFormat('MMM').format(DateTime(
                                        int.parse(parts[0]),
                                        int.parse(parts[1]),
                                      )),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  formatCurrencyCompact(value.toInt()),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: keys.asMap().entries.map((entry) {
                          final index = entry.key;
                          final amount = data[entry.value] ?? 0;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: amount.toDouble(),
                                color: Colors.blue,
                                width: 14,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _MetricCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(value,
                          style: Theme.of(context).textTheme.titleMedium),
                    ]),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;
  const _SmallStat({
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black54)),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ]),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: content,
      );
    }

    return content;
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(AppLocalizations.of(context)!.date)),
          Expanded(flex: 5, child: Text(AppLocalizations.of(context)!.members)),
          Expanded(
              flex: 3,
              child: Text(AppLocalizations.of(context)!.amount,
                  textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _DepositRow extends ConsumerWidget {
  final dynamic deposit; // drift type
  const _DepositRow({required this.deposit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final df = DateFormat('yyyy-MM-dd');
    return FutureBuilder(
      future: ref.read(repoProvider).getMemberByUuid(deposit.memberUuid),
      builder: (context, snap) {
        final memberName = snap.data?.name ?? 'Unknown';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(df.format(deposit.date))),
              Expanded(
                  flex: 5,
                  child: Text(memberName, overflow: TextOverflow.ellipsis)),
              Expanded(
                  flex: 3,
                  child: Text(formatCurrencyCompact(deposit.amount),
                      textAlign: TextAlign.end)),
            ],
          ),
        );
      },
    );
  }
}

class _MonthMapSheet extends StatelessWidget {
  final String title;
  final Map<String, int> data;
  final List members; // List of active members
  const _MonthMapSheet({
    required this.title,
    required this.data,
    required this.members,
  });

  // Calculate expected collection for a month (sum of all active members' monthlyAmount)
  int _calculateExpectedCollection() {
    return members.fold<int>(
      0,
      (sum, m) => sum + (m.monthlyAmount as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keys = data.keys.toList()..sort();
    final expectedCollection = _calculateExpectedCollection();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: keys.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final k = keys[i];
                    final actualCollection = data[k] ?? 0;
                    final amountText =
                        NumberFormat.decimalPattern().format(actualCollection);

                    // Show in green if collection >= expected, otherwise default color
                    final isComplete = actualCollection >= expectedCollection;

                    return ListTile(
                      title: Text(
                        monthKeyToName(k),
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        amountText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isComplete ? Colors.green.shade700 : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
      ),
    );
  }
}

class _DueMembersSheet extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  const _DueMembersSheet({required this.members});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Due by Member',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = members[i];
                    final member = m['member'];
                    final totalDue = m['totalDue'] as int;
                    final dueMonths = (m['dueMonths'] as Map<String, int>);
                    final months = dueMonths.keys.toList()..sort();
                    return ListTile(
                      title: Text('${member.name} (${member.memberIdNumber})'),
                      subtitle: months.isEmpty
                          ? Text(AppLocalizations.of(context)!.noDue,
                              style: const TextStyle(color: Colors.green))
                          : Text(
                              'Due months: ${months.length} (${months.take(3).map((k) => monthKeyToName(k)).join(', ')}${months.length > 3 ? '...' : ''})'),
                      trailing: Text(formatCurrencyCompact(totalDue),
                          style: TextStyle(
                            color: totalDue > 0
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          )),
                    );
                  },
                ),
              ),
            ]),
      ),
    );
  }
}

class _PaidMembersSheet extends StatelessWidget {
  final String monthName;
  final List<Map<String, dynamic>> members;
  const _PaidMembersSheet({
    required this.monthName,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.collection} - $monthName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.of(context)!.members}: ${members.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: members.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.noDeposits,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: members.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final m = members[i];
                        final member = m['member'] as Member;
                        final paid = m['paid'] as int;
                        final expected = m['expected'] as int;
                        return ListTile(
                          title:
                              Text('${member.name} (${member.memberIdNumber})'),
                          subtitle: Text(
                            'Expected: ${NumberFormat.decimalPattern().format(expected)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            formatCurrencyCompact(paid),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: paid >= expected
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnpaidMembersSheet extends StatelessWidget {
  final String monthName;
  final List<Map<String, dynamic>> members;
  const _UnpaidMembersSheet({
    required this.monthName,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.due} - $monthName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.of(context)!.members}: ${members.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: members.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.noDueMembers,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: members.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final m = members[i];
                        final member = m['member'] as Member;
                        final paid = m['paid'] as int;
                        final expected = m['expected'] as int;
                        final due = m['due'] as int;
                        return ListTile(
                          title:
                              Text('${member.name} (${member.memberIdNumber})'),
                          subtitle: Text(
                            paid > 0
                                ? 'Paid: ${NumberFormat.decimalPattern().format(paid)} / Expected: ${NumberFormat.decimalPattern().format(expected)}'
                                : 'Expected: ${NumberFormat.decimalPattern().format(expected)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            formatCurrencyCompact(due),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double height;
  const _Skeleton({required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String msg;
  const _ErrorCard(this.msg);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
