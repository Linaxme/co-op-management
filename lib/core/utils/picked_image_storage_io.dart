import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Saves a picked image into app documents (Android/iOS/desktop).
Future<String> savePickedImage(
  XFile image, {
  required String folderName,
  required String filePrefix,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dir.path, folderName));
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }

  final fileName = '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final dest = File(p.join(folder.path, fileName));
  final bytes = await image.readAsBytes();
  await dest.writeAsBytes(bytes, flush: true);
  return dest.path;
}

bool isRemoteImagePath(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  final trimmed = path.trim();
  return trimmed.startsWith('http://') || trimmed.startsWith('https://');
}
