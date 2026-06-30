import 'dart:convert';
import 'dart:html' as html;

import 'package:intl/intl.dart';

Future<String> writeJsonBackup(String jsonString) async {
  final df = DateFormat('yyyyMMdd_HHmmss');
  final fileName = 'ssf_backup_${df.format(DateTime.now())}.json';
  downloadJsonBackup(jsonString, fileName: fileName);
  return jsonString;
}

Future<String> readBackupFile(String path) async {
  throw UnsupportedError('readBackupFile is not used on web');
}

void downloadJsonBackup(String jsonString, {String? fileName}) {
  final blob = html.Blob([jsonString]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute(
      'download',
      fileName ?? 'ssf_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    )
    ..click();
  html.Url.revokeObjectUrl(url);
}
