import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

import 'coop_repository.dart';
import 'synced_coop_repository.dart';
import '../../core/db/app_db.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/image_sync_codec.dart';

class ReceiptService {
  final dynamic repo;
  ReceiptService({required this.repo});

  PdfPageFormat _receiptFormat() {
    // Landscape, half of A4: A4 is 210mm x 297mm, so half is 297mm x 105mm (landscape, half height)
    return const PdfPageFormat(297 * PdfPageFormat.mm, 105 * PdfPageFormat.mm,
        marginAll: 0); // Landscape, half A4
  }

  // Helper: Format date as dd/MM/yyyy
  String _formatDate(DateTime date) {
    final df = DateFormat('dd/MM/yyyy');
    return df.format(date);
  }

  // Helper: Format money with comma grouping
  String _formatMoney(int amount) {
    final money = NumberFormat('#,##0.00');
    return money.format(amount);
  }

  // Helper: Build label-value widget with underline (exactly like image)
  pw.Widget _labelValue({
    required String label,
    required String value,
    double labelWidth = 90,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.Container(
            width: labelWidth,
            height: 0.7,
            color: PdfColors.grey700,
            margin: const pw.EdgeInsets.only(bottom: 4, top: 2),
          ),
          pw.Text(
            value.isEmpty ? ' ' : value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.normal,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<File> generateReceiptPdf({
    required OrganizationData org,
    required Member member,
    required Deposit deposit,
    required SettingsData settings,
  }) async {
    final doc = pw.Document();
    final fmt = _receiptFormat();
    // Format receipt number from date/time serial
    // Serial format: YYYYMMDDHHMMSS (e.g., 20251224143025)
    final receiptSerialStr = deposit.receiptSerial.toString();
    String receiptNo;
    if (receiptSerialStr.length >= 14) {
      // Date/time based serial: Format as YYYY-MM-DD-HHMMSS
      final year = receiptSerialStr.substring(0, 4);
      final month = receiptSerialStr.substring(4, 6);
      final day = receiptSerialStr.substring(6, 8);
      final time = receiptSerialStr.substring(8, 14);
      receiptNo = '${settings.receiptPrefix}-$year$month$day-$time';
    } else {
      // Fallback for old format (backward compatibility)
      receiptNo =
          '${settings.receiptPrefix}-${deposit.receiptSerial.toString().padLeft(4, '0')}';
    }
    final blueColor = PdfColor.fromHex('#2563EB');
    const barHeight = 14.0;
    const contentPadding = 28.0;
    const topSpacing = 12.0;

    // Load logo and signature as Uint8List
    Uint8List? logoBytes;
    Uint8List? signatureBytes;

    if (org.logoPath != null) {
      try {
        logoBytes = await readImageBytes(org.logoPath);
      } catch (e) {
        // Logo loading failed, will use fallback
      }
    }

    // Load signature image
    signatureBytes = null;
    if (org.signaturePath != null && org.signaturePath!.trim().isNotEmpty) {
      try {
        signatureBytes = await readImageBytes(org.signaturePath);
        if (signatureBytes != null && signatureBytes.isEmpty) {
          signatureBytes = null;
        }
      } catch (e) {
        signatureBytes = null;
      }
    }

    try {
      doc.addPage(
        pw.Page(
          pageFormat: fmt.copyWith(
            marginLeft: 0,
            marginRight: 0,
            marginTop: 0,
            marginBottom: 0,
          ),
          build: (pw.Context context) {
            return pw.Container(
              color: PdfColors.white,
              child: pw.Stack(
                children: [
                  // Top blue bar - inset from page edges so there is white margin
                  pw.Positioned(
                    left: 8,
                    right: 8,
                    top: 6,
                    child: pw.Container(
                      height: barHeight,
                      color: blueColor,
                    ),
                  ),

                  // Header section below blue bar (logo, title, receipt info)
                  pw.Positioned(
                    left: contentPadding,
                    right: contentPadding,
                    top: barHeight + topSpacing,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Logo
                        pw.Container(
                          width: 60,
                          height: 60,
                          margin: const pw.EdgeInsets.only(right: 12),
                          child: (logoBytes != null)
                              ? pw.Image(
                                  pw.MemoryImage(logoBytes),
                                  fit: pw.BoxFit.contain,
                                )
                              : pw.Container(
                                  decoration: const pw.BoxDecoration(
                                    color: PdfColors.green,
                                    shape: pw.BoxShape.circle,
                                  ),
                                  child: pw.Center(
                                    child: pw.Text(
                                      org.name.length >= 3
                                          ? org.name
                                              .substring(0, 3)
                                              .toUpperCase()
                                          : 'SSF',
                                      style: pw.TextStyle(
                                        color: PdfColors.white,
                                        fontSize: 18,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        // CASH RECEIPT title
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 10, left: 8),
                            child: pw.Text(
                              'CASH RECEIPT',
                              style: pw.TextStyle(
                                color: PdfColors.black,
                                fontSize: 26,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        // Receipt Number and Date - right aligned
                        pw.Container(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text(
                                    'No. ',
                                    style: pw.TextStyle(
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    receiptNo,
                                    style: const pw.TextStyle(
                                      fontSize: 13,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 6),
                              pw.Row(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text(
                                    'Date ',
                                    style: pw.TextStyle(
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                  pw.Text(
                                    _formatDate(deposit.date),
                                    style: const pw.TextStyle(
                                      fontSize: 13,
                                      color: PdfColors.black,
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

                  // Footer text above bottom blue bar
                  pw.Positioned(
                    left: contentPadding,
                    right: contentPadding,
                    bottom: barHeight + 8,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        org.name.isNotEmpty ? org.name.toUpperCase() : 'SSF',
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),

                  // Bottom blue bar - inset from page edges so there is white margin
                  pw.Positioned(
                    left: 8,
                    right: 8,
                    bottom: 6,
                    child: pw.Container(
                      height: barHeight,
                      color: blueColor,
                    ),
                  ),

                  // Main content - two column layout
                  // Main content between the blue bars
                  pw.Positioned.fill(
                    left: contentPadding,
                    right: contentPadding,
                    // Keep content nicely between top bar and footer
                    top: barHeight + topSpacing + 50,
                    // Slightly smaller gap so signature area is not clipped
                    bottom: barHeight + 10,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left Column - left aligned
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _labelValue(
                                label: 'Received From',
                                value: member.name,
                                labelWidth: 220,
                              ),
                              _labelValue(
                                label: 'For:',
                                value: deposit.reason ?? deposit.monthKey,
                                labelWidth: 220,
                              ),
                              _labelValue(
                                label: 'Received By:',
                                value: deposit.receivedBy,
                                labelWidth: 220,
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 50),
                        // Right Column - left aligned
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _labelValue(
                                label: 'Payment Method',
                                value: deposit.method.toUpperCase(),
                                labelWidth: 150,
                              ),
                              _labelValue(
                                label: 'Amount',
                                value: '${_formatMoney(deposit.amount)} BDT',
                                labelWidth: 150,
                              ),
                              pw.SizedBox(height: 22),
                              // Signature area with line above - right aligned
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.Container(
                                    width: 150,
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      mainAxisSize: pw.MainAxisSize.min,
                                      children: [
                                        // Line just above the signature
                                        pw.Container(
                                          height: 1,
                                          width: double.infinity,
                                          color: PdfColors.grey700,
                                          margin: const pw.EdgeInsets.only(
                                              bottom: 8),
                                        ),
                                        if (signatureBytes != null &&
                                            signatureBytes.isNotEmpty)
                                          pw.SizedBox(
                                            width: double.infinity,
                                            height: 55,
                                            child: pw.Image(
                                              pw.MemoryImage(signatureBytes),
                                              fit: pw.BoxFit.contain,
                                              alignment: pw.Alignment.center,
                                            ),
                                          )
                                        else
                                          pw.SizedBox(
                                            height: 32,
                                            child: pw.Center(
                                              child: pw.Text(
                                                'Signature',
                                                style: const pw.TextStyle(
                                                  fontSize: 10,
                                                  color: PdfColors.grey600,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
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
                ],
              ),
            );
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to generate receipt PDF: $e');
    }

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'receipts'));
    if (!await folder.exists()) await folder.create(recursive: true);

    // Generate filename: member name + month + date + time
    // Sanitize member name to remove invalid filename characters
    String sanitizedName = member.name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'),
            '_') // Replace invalid chars with underscore
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscore
        .trim();

    // Get month name from monthKey
    final monthName = monthKeyToName(deposit.monthKey).replaceAll(' ', '_');

    // Format date as YYYYMMDD
    final dateStr = DateFormat('yyyyMMdd').format(deposit.date);

    // Extract time from receipt serial or use deposit date time
    String timeStr;
    if (receiptSerialStr.length >= 14) {
      // Extract time from serial: HHMMSS
      timeStr = receiptSerialStr.substring(8, 14);
    } else {
      // Fallback: use deposit date time
      timeStr = DateFormat('HHmmss').format(deposit.date);
    }

    // Format: MemberName_Month_YYYYMMDD_HHMMSS.pdf
    // Example: John_Doe_January_2025_20251224_143025.pdf
    final fileName = '${sanitizedName}_${monthName}_${dateStr}_$timeStr.pdf';
    final file = File(p.join(folder.path, fileName));
    await file.writeAsBytes(await doc.save());
    return file;
  }

  // removed unused helper _kv

  Future<void> sharePdf(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text ?? 'PDF');
  }

  Future<void> printReceipt(File file) async {
    final pdfBytes = await file.readAsBytes();
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
    );
  }

  Future<void> printReceiptDirect({
    required OrganizationData org,
    required Member member,
    required Deposit deposit,
    required SettingsData settings,
  }) async {
    final file = await generateReceiptPdf(
      org: org,
      member: member,
      deposit: deposit,
      settings: settings,
    );
    await printReceipt(file);
  }
}
