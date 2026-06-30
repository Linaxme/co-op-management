import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/app_db.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/image_sync_codec.dart';
import 'coop_data_repository.dart';

class ReportService {
  final CoopDataRepository repo;
  ReportService({required this.repo});

  PdfPageFormat _a4() => PdfPageFormat.a4;

  /// Helper function to parse reason field and get all monthKeys covered by a deposit
  /// Returns list of monthKeys for multi-month deposits (e.g., "January to March" -> ["2025-01", "2025-02", "2025-03"])
  List<String> _parseDepositMonths(String? reason, String monthKey) {
    if (reason == null || reason.trim().isEmpty) {
      return [monthKey]; // Single month deposit
    }

    final monthNames = [
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
      'December'
    ];

    // Check if it's a multi-month deposit (e.g., "January to March")
    if (reason.toLowerCase().contains(' to ')) {
      final parts = reason.split(' to ');
      if (parts.length == 2) {
        final fromMonth = parts[0].trim();
        final toMonth = parts[1].trim();

        final fromIndex = monthNames.indexOf(fromMonth);
        final toIndex = monthNames.indexOf(toMonth);

        if (fromIndex >= 0 && toIndex >= fromIndex) {
          // Extract year from monthKey
          final year = monthKey.split('-')[0];
          final monthKeys = <String>[];

          // Generate all monthKeys in the range
          for (int i = fromIndex; i <= toIndex; i++) {
            final month = (i + 1).toString().padLeft(2, '0');
            monthKeys.add('$year-$month');
          }
          return monthKeys;
        }
      }
    }

    // Single month deposit or couldn't parse
    return [monthKey];
  }

  Future<File> generateAnnualReportPdf({
    required int year,
    required OrganizationData org,
  }) async {
    final doc = pw.Document();
    final money = NumberFormat.decimalPattern();

    // Load logo
    Uint8List? logoBytes;
    if (org.logoPath != null && org.logoPath!.isNotEmpty) {
      try {
        logoBytes = await readImageBytes(org.logoPath);
        if (logoBytes != null && logoBytes.isEmpty) logoBytes = null;
      } catch (e) {
        logoBytes = null;
      }
    }

    final total = await repo.collectionForYear(year);
    final byMonth = await repo.collectionByMonthForYear(year);

    // Get all members and calculate their deposits and dues for the year
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);
    final dueSummary = await repo.dueSummaryAllMembers(
      start: startDate,
      endInclusive: endDate,
    );
    final totalDue = dueSummary['totalDue'] as int;
    final memberDueDetails =
        (dueSummary['members'] as List).cast<Map<String, dynamic>>();

    // Calculate deposits per member for the year
    final deposits = await repo.getAllDeposits();
    final allDeposits = deposits.where((d) => d.deletedAt == null).toList();
    final yearPrefix = '$year-';

    final memberDeposits = <String, int>{};
    for (final deposit in allDeposits) {
      final depositMonths =
          _parseDepositMonths(deposit.reason, deposit.monthKey);
      final yearMonths =
          depositMonths.where((mk) => mk.startsWith(yearPrefix)).toList();

      if (yearMonths.isNotEmpty) {
        final amountPerMonth = deposit.amount ~/ depositMonths.length;
        final yearAmount = amountPerMonth * yearMonths.length;
        memberDeposits[deposit.memberUuid] =
            ((memberDeposits[deposit.memberUuid] ?? 0) + yearAmount).toInt();
      }
    }

    // Create member summary list
    final memberSummaries = <Map<String, dynamic>>[];
    for (final detail in memberDueDetails) {
      final member = detail['member'] as Member;
      final memberDeposit = memberDeposits[member.uuid] ?? 0;
      final memberDue = detail['totalDue'] as int;
      memberSummaries.add({
        'member': member,
        'deposit': memberDeposit,
        'due': memberDue,
      });
    }
    // Sort by name
    memberSummaries.sort((a, b) =>
        (a['member'] as Member).name.compareTo((b['member'] as Member).name));

    // Calculate month-wise due amounts
    final monthDue = <String, int>{};
    for (final detail in memberDueDetails) {
      final dueMonths = detail['dueMonths'] as Map<String, int>;
      for (final entry in dueMonths.entries) {
        final monthKey = entry.key;
        if (monthKey.startsWith(yearPrefix)) {
          monthDue[monthKey] = (monthDue[monthKey] ?? 0) + entry.value;
        }
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: _a4(),
        build: (_) => [
          // Header with logo and organization info
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              if (logoBytes != null)
                pw.Container(
                  width: 80,
                  height: 80,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                pw.Container(
                  width: 80,
                  height: 80,
                  margin: const pw.EdgeInsets.only(right: 12),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.green,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      org.name.length >= 3
                          ? org.name.substring(0, 3).toUpperCase()
                          : 'SSF',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Organization name and address
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(org.name,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(org.address,
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Annual Collection Report - $year',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey700),
                    color: PdfColors.green50,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text('Total Collection')),
                      pw.Text('${money.format(total)} BDT',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey700),
                    color: PdfColors.red50,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text('Total Due')),
                      pw.Text('${money.format(totalDue)} BDT',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Member-wise Summary',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Member Name',
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Deposits (BDT)',
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Due (BDT)',
                          style: const pw.TextStyle(fontSize: 10))),
                ],
              ),
              ...memberSummaries.map((summary) {
                final member = summary['member'] as Member;
                final deposit = summary['deposit'] as int;
                final due = summary['due'] as int;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: pw.Text(
                            '${member.name} (${member.memberIdNumber})',
                            style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: pw.Text(money.format(deposit),
                            style: pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.green700,
                                fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: pw.Text(money.format(due),
                            style: pw.TextStyle(
                                fontSize: 9,
                                color: due > 0
                                    ? PdfColors.red700
                                    : PdfColors.green700,
                                fontWeight: pw.FontWeight.bold))),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Text('Month-wise Summary',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Month',
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Collection (BDT)',
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Due (BDT)',
                          style: const pw.TextStyle(fontSize: 10))),
                ],
              ),
              ...byMonth.entries.map((e) {
                final monthDueAmount = monthDue[e.key] ?? 0;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text(monthKeyToName(e.key),
                          style: const pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: pw.Text(money.format(e.value),
                            style: pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.green700,
                                fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        child: pw.Text(money.format(monthDueAmount),
                            style: pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.red700,
                                fontWeight: pw.FontWeight.bold))),
                  ],
                );
              }),
            ],
          ),
          if (byMonth.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                'No collection data found for $year',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'reports'));
    if (!await folder.exists()) await folder.create(recursive: true);

    // Generate filename with date and time
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final timeStr = DateFormat('HHmmss').format(now);
    final fileName = 'annual_report_${year}_${dateStr}_$timeStr.pdf';
    final file = File(p.join(folder.path, fileName));
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<File> generateMemberReportPdf({
    required String memberUuid,
    required DateTime start,
    required DateTime endInclusive,
    required OrganizationData org,
  }) async {
    final doc = pw.Document();
    final money = NumberFormat.decimalPattern();

    final member = await repo.getMemberByUuid(memberUuid);
    if (member == null) {
      throw Exception('Member not found');
    }

    // Load logo
    Uint8List? logoBytes;
    if (org.logoPath != null && org.logoPath!.isNotEmpty) {
      try {
        logoBytes = await readImageBytes(org.logoPath);
        if (logoBytes != null && logoBytes.isEmpty) logoBytes = null;
      } catch (e) {
        logoBytes = null;
      }
    }

    final due = await repo.dueForOneMember(
        memberUuid: memberUuid, start: start, endInclusive: endInclusive);
    final totalDue = due['totalDue'] as int;
    final dueMonths = (due['dueMonths'] as Map<String, int>);
    final dueKeys = dueMonths.keys.toList()..sort();

    final deposits = await repo.getAllDeposits();
    final memberDeposits = deposits
        .where((d) => d.deletedAt == null && d.memberUuid == memberUuid)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalPaid = memberDeposits.fold<int>(0, (a, b) => a + b.amount);

    doc.addPage(
      pw.MultiPage(
        pageFormat: _a4(),
        build: (_) => [
          // Header with logo and organization info
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              if (logoBytes != null)
                pw.Container(
                  width: 80,
                  height: 80,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                pw.Container(
                  width: 80,
                  height: 80,
                  margin: const pw.EdgeInsets.only(right: 12),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.green,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      org.name.length >= 3
                          ? org.name.substring(0, 3).toUpperCase()
                          : 'SSF',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Organization name and address
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(org.name,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(org.address,
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
              'Member Report (Up to ${DateFormat('yyyy-MM-dd').format(endInclusive)})',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Name: ${member.name}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Member ID: ${member.memberIdNumber}'),
                pw.Text(
                    'Monthly Amount: ${money.format(member.monthlyAmount)} BDT'),
                if ((member.phone ?? '').isNotEmpty)
                  pw.Text('Phone: ${member.phone}'),
                if ((member.address ?? '').isNotEmpty)
                  pw.Text('Address: ${member.address}'),
                if ((member.nidNumber ?? '').isNotEmpty)
                  pw.Text('NID: ${member.nidNumber}'),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey700),
                      color: PdfColors.green50),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Paid',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('${money.format(totalPaid)} BDT',
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey700),
                      color: PdfColors.red50),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Due',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text('${money.format(totalDue)} BDT',
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 12),
          pw.Text('Due Months',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (dueKeys.isEmpty) pw.Text('No due months'),
          if (dueKeys.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3)
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Month')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Due (BDT)')),
                  ],
                ),
                ...dueKeys.map((k) => pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(monthKeyToName(k))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(money.format(dueMonths[k]))),
                      ],
                    )),
              ],
            ),

          pw.SizedBox(height: 14),
          pw.Text('Deposit History',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Date',
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Month',
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Method',
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: pw.Text('Amount',
                          style: const pw.TextStyle(fontSize: 10))),
                ],
              ),
              ...memberDeposits.map((d) => pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          child: pw.Text(
                              DateFormat('yyyy-MM-dd').format(d.date),
                              style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          child: pw.Text(monthKeyToName(d.monthKey),
                              style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          child: pw.Text(d.method.toUpperCase(),
                              style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          child: pw.Text(money.format(d.amount),
                              style: const pw.TextStyle(fontSize: 9))),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'reports'));
    if (!await folder.exists()) await folder.create(recursive: true);

    // Generate filename with member name, date and time
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final timeStr = DateFormat('HHmmss').format(now);

    // Sanitize member name
    String sanitizedName = member.name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    final fileName = 'member_report_${sanitizedName}_${dateStr}_$timeStr.pdf';
    final file = File(p.join(folder.path, fileName));
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<File> generateMonthlyReportPdf({
    required String monthKey, // yyyy-MM format
    required OrganizationData org,
  }) async {
    final doc = pw.Document();
    final money = NumberFormat.decimalPattern();

    // Load logo
    Uint8List? logoBytes;
    if (org.logoPath != null && org.logoPath!.isNotEmpty) {
      try {
        logoBytes = await readImageBytes(org.logoPath);
        if (logoBytes != null && logoBytes.isEmpty) logoBytes = null;
      } catch (e) {
        logoBytes = null;
      }
    }

    // Get all active members
    final allMembersData = await repo.getAllMembers(includeTrashed: true);
    final membersList = allMembersData
        .where((m) => m.deletedAt == null && m.isActive == true)
        .toList();

    // Get all deposits and filter for this month (handles multi-month deposits)
    final deposits = await repo.getAllDeposits();
    final allDeposits = deposits.where((d) => d.deletedAt == null).toList();

    // Create maps: memberUuid -> total paid amount and deposit info
    // Handle multi-month deposits by distributing amount across months
    final paidByMember = <String, int>{};
    final depositInfoByMember =
        <String, List<Map<String, dynamic>>>{}; // Store deposit date and amount

    for (final deposit in allDeposits) {
      // Parse deposit months (handles multi-month deposits like "January to March")
      final depositMonths =
          _parseDepositMonths(deposit.reason, deposit.monthKey);

      // Check if this deposit covers the requested month
      if (depositMonths.contains(monthKey)) {
        // Distribute deposit amount equally across all months in the range
        final amountPerMonth = deposit.amount ~/ depositMonths.length;
        paidByMember[deposit.memberUuid] =
            ((paidByMember[deposit.memberUuid] ?? 0) + amountPerMonth).toInt();

        // Store deposit info (date and amount for this month)
        depositInfoByMember.putIfAbsent(deposit.memberUuid, () => []).add({
          'date': deposit.date,
          'amount': amountPerMonth,
        });
      }
    }

    // Calculate total due
    int totalDue = 0;
    for (final member in membersList) {
      final paid = paidByMember[member.uuid] ?? 0;
      final due = (member.monthlyAmount - paid) as int;
      if (due > 0) {
        totalDue += due.toInt();
      }
    }

    // Separate members into paid and not paid
    final paidMembers = <Member>[];
    final notPaidMembers = <Member>[];

    for (final member in membersList) {
      if (paidByMember.containsKey(member.uuid) &&
          paidByMember[member.uuid]! > 0) {
        paidMembers.add(member);
      } else {
        notPaidMembers.add(member);
      }
    }

    // Sort by name
    paidMembers.sort((a, b) => a.name.compareTo(b.name));
    notPaidMembers.sort((a, b) => a.name.compareTo(b.name));

    final monthName = monthKeyToName(monthKey);
    // Calculate total collection for this month (from paidByMember map)
    final totalCollection =
        paidByMember.values.fold<int>(0, (sum, amount) => sum + amount);
    final totalMembers = membersList.length;

    doc.addPage(
      pw.MultiPage(
        pageFormat: _a4(),
        build: (_) => [
          // Header with logo and organization info
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              if (logoBytes != null)
                pw.Container(
                  width: 80,
                  height: 80,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                pw.Container(
                  width: 80,
                  height: 80,
                  margin: const pw.EdgeInsets.only(right: 12),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.green,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      org.name.length >= 3
                          ? org.name.substring(0, 3).toUpperCase()
                          : 'SSF',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Organization name and address
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(org.name,
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(org.address,
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Monthly Report - $monthName',
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700),
                color: PdfColors.green50),
            child: pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Total Collection')),
                pw.Text('${money.format(totalCollection)} BDT',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700),
                color: PdfColors.red50),
            child: pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Total Due')),
                pw.Text('${money.format(totalDue)} BDT',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red700)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700)),
            child: pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Total Members')),
                pw.Text('$totalMembers',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700)),
            child: pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Paid Members')),
                pw.Text('${paidMembers.length}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey700)),
            child: pw.Row(
              children: [
                pw.Expanded(child: pw.Text('Not Paid Members')),
                pw.Text('${notPaidMembers.length}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          // Paid Members Section
          pw.Text('Members Who Paid',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (paidMembers.isEmpty)
            pw.Text('No members paid this month',
                style:
                    const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
          if (paidMembers.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Name')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Member ID')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Date')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Paid Amount')),
                  ],
                ),
                ...paidMembers.map((m) {
                  final paidAmount = paidByMember[m.uuid] ?? 0;
                  final depositInfos = depositInfoByMember[m.uuid] ?? [];
                  // Get the earliest deposit date for this month
                  final depositDate = depositInfos.isNotEmpty
                      ? depositInfos
                          .map((d) => d['date'] as DateTime)
                          .reduce((a, b) => a.isBefore(b) ? a : b)
                      : DateTime.now();
                  final dateStr = DateFormat('yyyy-MM-dd').format(depositDate);

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(m.name)),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(m.memberIdNumber)),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(dateStr)),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(money.format(paidAmount),
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green700))),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 20),
          // Not Paid Members Section
          pw.Text('Members Who Did Not Pay',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (notPaidMembers.isEmpty)
            pw.Text('All members paid this month ✅',
                style:
                    const pw.TextStyle(fontSize: 11, color: PdfColors.green)),
          if (notPaidMembers.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Name')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Member ID')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Due Amount')),
                  ],
                ),
                ...notPaidMembers.map((m) {
                  final paid = paidByMember[m.uuid] ?? 0;
                  final due = m.monthlyAmount - paid;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(m.name)),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(m.memberIdNumber)),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(money.format(due),
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red))),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'reports'));
    if (!await folder.exists()) await folder.create(recursive: true);

    // Generate filename with month, date and time
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final timeStr = DateFormat('HHmmss').format(now);
    final monthNameForFile = monthKeyToName(monthKey).replaceAll(' ', '_');
    final fileName =
        'monthly_report_${monthNameForFile}_${dateStr}_$timeStr.pdf';
    final file = File(p.join(folder.path, fileName));
    await file.writeAsBytes(await doc.save());
    return file;
  }

  // CSV Export Methods
  Future<File> exportAnnualReportCsv({required int year}) async {
    final total = await repo.collectionForYear(year);
    final byMonth = await repo.collectionByMonthForYear(year);

    // Get member-wise data
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);
    final dueSummary = await repo.dueSummaryAllMembers(
      start: startDate,
      endInclusive: endDate,
    );
    final totalDue = dueSummary['totalDue'] as int;
    final memberDueDetails =
        (dueSummary['members'] as List).cast<Map<String, dynamic>>();

    // Calculate deposits per member for the year
    final deposits = await repo.getAllDeposits();
    final allDeposits = deposits.where((d) => d.deletedAt == null).toList();
    final yearPrefix = '$year-';

    final memberDeposits = <String, int>{};
    for (final deposit in allDeposits) {
      final depositMonths =
          _parseDepositMonths(deposit.reason, deposit.monthKey);
      final yearMonths =
          depositMonths.where((mk) => mk.startsWith(yearPrefix)).toList();

      if (yearMonths.isNotEmpty) {
        final amountPerMonth = deposit.amount ~/ depositMonths.length;
        final yearAmount = amountPerMonth * yearMonths.length;
        memberDeposits[deposit.memberUuid] =
            ((memberDeposits[deposit.memberUuid] ?? 0) + yearAmount).toInt();
      }
    }

    // Create member summary list
    final memberSummaries = <Map<String, dynamic>>[];
    for (final detail in memberDueDetails) {
      final member = detail['member'] as Member;
      final memberDeposit = memberDeposits[member.uuid] ?? 0;
      final memberDue = detail['totalDue'] as int;
      memberSummaries.add({
        'member': member,
        'deposit': memberDeposit,
        'due': memberDue,
      });
    }
    memberSummaries.sort((a, b) =>
        (a['member'] as Member).name.compareTo((b['member'] as Member).name));

    // Calculate month-wise due amounts
    final monthDue = <String, int>{};
    for (final detail in memberDueDetails) {
      final dueMonths = detail['dueMonths'] as Map<String, int>;
      for (final entry in dueMonths.entries) {
        final monthKey = entry.key;
        if (monthKey.startsWith(yearPrefix)) {
          monthDue[monthKey] = (monthDue[monthKey] ?? 0) + entry.value;
        }
      }
    }

    final csv = StringBuffer();
    csv.writeln('Annual Collection Report - $year');
    csv.writeln(
        'Total Collection,${NumberFormat.decimalPattern().format(total)} BDT');
    csv.writeln(
        'Total Due,${NumberFormat.decimalPattern().format(totalDue)} BDT');
    csv.writeln('');
    csv.writeln('Member-wise Summary');
    csv.writeln('Member Name,Deposits (BDT),Due (BDT)');
    for (final summary in memberSummaries) {
      final member = summary['member'] as Member;
      final deposit = summary['deposit'] as int;
      final due = summary['due'] as int;
      csv.writeln(
          '${member.name} (${member.memberIdNumber}),${NumberFormat.decimalPattern().format(deposit)},${NumberFormat.decimalPattern().format(due)}');
    }
    csv.writeln('');
    csv.writeln('Month-wise Summary');
    csv.writeln('Month,Collection (BDT),Due (BDT)');
    for (final entry in byMonth.entries) {
      final monthDueAmount = monthDue[entry.key] ?? 0;
      csv.writeln(
          '${monthKeyToName(entry.key)},${NumberFormat.decimalPattern().format(entry.value)},${NumberFormat.decimalPattern().format(monthDueAmount)}');
    }

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'reports'));
    if (!await folder.exists()) await folder.create(recursive: true);

    final file = File(p.join(folder.path, 'annual_report_$year.csv'));
    await file.writeAsString(csv.toString());
    return file;
  }

  Future<File> exportMonthlyReportCsv({required String monthKey}) async {
    final allMembers = await repo.getAllMembers(includeTrashed: true);
    final membersList = allMembers
        .where((m) => m.deletedAt == null && m.isActive == true)
        .toList();

    final deposits = await repo.getAllDeposits();
    final allDeposits = deposits.where((d) => d.deletedAt == null).toList();

    // Handle multi-month deposits by distributing amount across months
    final paidByMember = <String, int>{};
    final depositInfoByMember =
        <String, List<Map<String, dynamic>>>{}; // Store deposit date and amount

    for (final deposit in allDeposits) {
      // Parse deposit months (handles multi-month deposits like "January to March")
      final depositMonths =
          _parseDepositMonths(deposit.reason, deposit.monthKey);

      // Check if this deposit covers the requested month
      if (depositMonths.contains(monthKey)) {
        // Distribute deposit amount equally across all months in the range
        final amountPerMonth = deposit.amount ~/ depositMonths.length;
        paidByMember[deposit.memberUuid] =
            ((paidByMember[deposit.memberUuid] ?? 0) + amountPerMonth).toInt();

        // Store deposit info
        depositInfoByMember.putIfAbsent(deposit.memberUuid, () => []).add({
          'date': deposit.date,
          'amount': amountPerMonth,
        });
      }
    }

    // Calculate total collection and total due
    final totalCollection =
        paidByMember.values.fold<int>(0, (sum, amount) => sum + amount);
    int totalDue = 0;
    for (final member in membersList) {
      final paid = paidByMember[member.uuid] ?? 0;
      final due = (member.monthlyAmount - paid) as int;
      if (due > 0) {
        totalDue += due.toInt();
      }
    }

    final csv = StringBuffer();
    csv.writeln('Monthly Report - ${monthKeyToName(monthKey)}');
    csv.writeln(
        'Total Collection,${NumberFormat.decimalPattern().format(totalCollection)} BDT');
    csv.writeln(
        'Total Due,${NumberFormat.decimalPattern().format(totalDue)} BDT');
    csv.writeln('Total Members,${membersList.length}');
    csv.writeln('Paid Members,${paidByMember.length}');
    csv.writeln('Not Paid Members,${membersList.length - paidByMember.length}');
    csv.writeln('');
    csv.writeln('Paid Members');
    csv.writeln('Name,Member ID,Date,Paid Amount');
    for (final member in membersList) {
      if (paidByMember.containsKey(member.uuid) &&
          paidByMember[member.uuid]! > 0) {
        final depositInfos = depositInfoByMember[member.uuid] ?? [];
        final depositDate = depositInfos.isNotEmpty
            ? depositInfos
                .map((d) => d['date'] as DateTime)
                .reduce((a, b) => a.isBefore(b) ? a : b)
            : DateTime.now();
        final dateStr = DateFormat('yyyy-MM-dd').format(depositDate);
        csv.writeln(
            '${member.name},${member.memberIdNumber},$dateStr,${paidByMember[member.uuid]}');
      }
    }
    csv.writeln('');
    csv.writeln('Not Paid Members');
    csv.writeln('Name,Member ID,Due Amount');
    for (final member in membersList) {
      if (!paidByMember.containsKey(member.uuid) ||
          paidByMember[member.uuid] == 0) {
        final paid = paidByMember[member.uuid] ?? 0;
        final due = (member.monthlyAmount - paid) as int;
        csv.writeln('${member.name},${member.memberIdNumber},$due');
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'reports'));
    if (!await folder.exists()) await folder.create(recursive: true);

    final file = File(p.join(
        folder.path, 'monthly_report_${monthKey.replaceAll('-', '_')}.csv'));
    await file.writeAsString(csv.toString());
    return file;
  }

  // Excel Export Methods
  Future<File> exportAnnualReportExcel({required int year}) async {
    final total = await repo.collectionForYear(year);
    final byMonth = await repo.collectionByMonthForYear(year);

    // Get member-wise data
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);
    final dueSummary = await repo.dueSummaryAllMembers(
      start: startDate,
      endInclusive: endDate,
    );
    final totalDue = dueSummary['totalDue'] as int;
    final memberDueDetails =
        (dueSummary['members'] as List).cast<Map<String, dynamic>>();

    // Calculate deposits per member for the year
    final deposits = await repo.getAllDeposits();
    final allDeposits = deposits.where((d) => d.deletedAt == null).toList();
    final yearPrefix = '$year-';

    final memberDeposits = <String, int>{};
    for (final deposit in allDeposits) {
      final depositMonths =
          _parseDepositMonths(deposit.reason, deposit.monthKey);
      final yearMonths =
          depositMonths.where((mk) => mk.startsWith(yearPrefix)).toList();

      if (yearMonths.isNotEmpty) {
        final amountPerMonth = deposit.amount ~/ depositMonths.length;
        final yearAmount = amountPerMonth * yearMonths.length;
        memberDeposits[deposit.memberUuid] =
            ((memberDeposits[deposit.memberUuid] ?? 0) + yearAmount).toInt();
      }
    }

    // Create member summary list
    final memberSummaries = <Map<String, dynamic>>[];
    for (final detail in memberDueDetails) {
      final member = detail['member'] as Member;
      final memberDeposit = memberDeposits[member.uuid] ?? 0;
      final memberDue = detail['totalDue'] as int;
      memberSummaries.add({
        'member': member,
        'deposit': memberDeposit,
        'due': memberDue,
      });
    }
    memberSummaries.sort((a, b) =>
        (a['member'] as Member).name.compareTo((b['member'] as Member).name));

    // Calculate month-wise due amounts
    final monthDue = <String, int>{};
    for (final detail in memberDueDetails) {
      final dueMonths = detail['dueMonths'] as Map<String, int>;
      for (final entry in dueMonths.entries) {
        final monthKey = entry.key;
        if (monthKey.startsWith(yearPrefix)) {
          monthDue[monthKey] = (monthDue[monthKey] ?? 0) + entry.value;
        }
      }
    }

    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Annual Report $year'];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('Annual Collection Report - $year');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value =
        TextCellValue('Total Collection');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value =
        TextCellValue('${NumberFormat.decimalPattern().format(total)} BDT');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value =
        TextCellValue('Total Due');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value =
        TextCellValue('${NumberFormat.decimalPattern().format(totalDue)} BDT');

    int row = 4;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Member-wise Summary');
    row++;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Member Name');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('Deposits (BDT)');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue('Due (BDT)');
    row++;

    for (final summary in memberSummaries) {
      final member = summary['member'] as Member;
      final deposit = summary['deposit'] as int;
      final due = summary['due'] as int;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue('${member.name} (${member.memberIdNumber})');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(NumberFormat.decimalPattern().format(deposit));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue(NumberFormat.decimalPattern().format(due));
      row++;
    }

    row += 2;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Month-wise Summary');
    row++;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Month');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('Collection (BDT)');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue('Due (BDT)');
    row++;

    for (final entry in byMonth.entries) {
      final monthDueAmount = monthDue[entry.key] ?? 0;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(monthKeyToName(entry.key));
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
              .value =
          TextCellValue(NumberFormat.decimalPattern().format(entry.value));
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
              .value =
          TextCellValue(NumberFormat.decimalPattern().format(monthDueAmount));
      row++;
    }

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'reports'));
    if (!await folder.exists()) await folder.create(recursive: true);

    final file = File(p.join(folder.path, 'annual_report_$year.xlsx'));
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  Future<File> exportMonthlyReportExcel({required String monthKey}) async {
    final allMembers = await repo.getAllMembers(includeTrashed: true);
    final membersList = allMembers
        .where((m) => m.deletedAt == null && m.isActive == true)
        .toList();

    final deposits = await repo.getAllDeposits();
    final allDeposits = deposits.where((d) => d.deletedAt == null).toList();

    // Handle multi-month deposits by distributing amount across months
    final paidByMember = <String, int>{};
    final depositInfoByMember =
        <String, List<Map<String, dynamic>>>{}; // Store deposit date and amount

    for (final deposit in allDeposits) {
      // Parse deposit months (handles multi-month deposits like "January to March")
      final depositMonths =
          _parseDepositMonths(deposit.reason, deposit.monthKey);

      // Check if this deposit covers the requested month
      if (depositMonths.contains(monthKey)) {
        // Distribute deposit amount equally across all months in the range
        final amountPerMonth = deposit.amount ~/ depositMonths.length;
        paidByMember[deposit.memberUuid] =
            ((paidByMember[deposit.memberUuid] ?? 0) + amountPerMonth).toInt();

        // Store deposit info
        depositInfoByMember.putIfAbsent(deposit.memberUuid, () => []).add({
          'date': deposit.date,
          'amount': amountPerMonth,
        });
      }
    }

    // Calculate total collection and total due
    final totalCollection =
        paidByMember.values.fold<int>(0, (sum, amount) => sum + amount);
    int totalDue = 0;
    for (final member in membersList) {
      final paid = paidByMember[member.uuid] ?? 0;
      final due = (member.monthlyAmount - paid) as int;
      if (due > 0) {
        totalDue += due.toInt();
      }
    }

    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Monthly Report'];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('Monthly Report - ${monthKeyToName(monthKey)}');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value =
        TextCellValue('Total Collection');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value =
        TextCellValue(NumberFormat.decimalPattern().format(totalCollection));
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value =
        TextCellValue('Total Due');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2)).value =
        TextCellValue(NumberFormat.decimalPattern().format(totalDue));
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value =
        TextCellValue('Total Members');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).value =
        IntCellValue(membersList.length);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4)).value =
        TextCellValue('Paid Members');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4)).value =
        IntCellValue(paidByMember.length);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5)).value =
        TextCellValue('Not Paid Members');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5)).value =
        IntCellValue(membersList.length - paidByMember.length);

    int row = 7;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Paid Members');
    row++;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Name');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('Member ID');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue('Date');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
        .value = TextCellValue('Paid Amount');
    row++;

    for (final member in membersList) {
      if (paidByMember.containsKey(member.uuid) &&
          paidByMember[member.uuid]! > 0) {
        final depositInfos = depositInfoByMember[member.uuid] ?? [];
        final depositDate = depositInfos.isNotEmpty
            ? depositInfos
                .map((d) => d['date'] as DateTime)
                .reduce((a, b) => a.isBefore(b) ? a : b)
            : DateTime.now();
        final dateStr = DateFormat('yyyy-MM-dd').format(depositDate);

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = TextCellValue(member.name);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = TextCellValue(member.memberIdNumber);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = TextCellValue(dateStr);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
            .value = IntCellValue(paidByMember[member.uuid]!);
        row++;
      }
    }

    row += 2;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Not Paid Members');
    row++;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue('Name');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue('Member ID');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = TextCellValue('Due Amount');
    row++;

    for (final member in membersList) {
      if (!paidByMember.containsKey(member.uuid) ||
          paidByMember[member.uuid] == 0) {
        final paid = paidByMember[member.uuid] ?? 0;
        final due = (member.monthlyAmount - paid) as int;
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = TextCellValue(member.name);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = TextCellValue(member.memberIdNumber);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = IntCellValue(due);
        row++;
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'reports'));
    if (!await folder.exists()) await folder.create(recursive: true);

    final file = File(p.join(
        folder.path, 'monthly_report_${monthKey.replaceAll('-', '_')}.xlsx'));
    await file.writeAsBytes(excel.encode()!);
    return file;
  }

  Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text ?? 'Report');
  }
}
