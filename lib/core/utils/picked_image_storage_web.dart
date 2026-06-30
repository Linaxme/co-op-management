import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

const _maxSyncBytes = 450000;

/// Web: store as data URI (no local filesystem).
Future<String> savePickedImage(
  XFile image, {
  required String folderName,
  required String filePrefix,
}) async {
  final bytes = await image.readAsBytes();
  final compressed = _compressForSync(Uint8List.fromList(bytes));
  if (compressed == null) {
    throw Exception('Image is too large. Please choose a smaller photo.');
  }
  return 'data:image/jpeg;base64,${base64Encode(compressed)}';
}

Uint8List? _compressForSync(Uint8List raw) {
  final decoded = img.decodeImage(raw);
  if (decoded == null) {
    return raw.length <= _maxSyncBytes ? Uint8List.fromList(raw) : null;
  }

  var resized = decoded;
  if (decoded.width > 800) {
    resized = img.copyResize(decoded, width: 800);
  }

  var quality = 75;
  var out = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  while (out.length > _maxSyncBytes && quality > 30) {
    quality -= 10;
    out = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }
  if (out.length > _maxSyncBytes) {
    resized = img.copyResize(resized, width: 400);
    out = Uint8List.fromList(img.encodeJpg(resized, quality: 60));
  }
  return out.length <= _maxSyncBytes ? out : null;
}

bool isRemoteImagePath(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  final trimmed = path.trim();
  return trimmed.startsWith('http://') || trimmed.startsWith('https://');
}
