import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

Future<String> writeJsonBackup(String jsonString) async {
  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dir.path, 'backups'));
  if (!await folder.exists()) await folder.create(recursive: true);

  final df = DateFormat('yyyyMMdd_HHmmss');
  final fileName = 'ssf_backup_${df.format(DateTime.now())}.json';
  final file = File(p.join(folder.path, fileName));
  await file.writeAsString(jsonString, encoding: utf8);
  return file.path;
}

Future<String> readBackupFile(String path) async {
  return File(path).readAsString(encoding: utf8);
}

void downloadJsonBackup(String jsonString, {String? fileName}) {
  throw UnsupportedError('downloadJsonBackup is only available on web');
}
