import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'picked_image_storage.dart';

/// Firestore document field limit is 1 MiB — keep synced images smaller.
const _maxSyncBytes = 450000;

bool isDataImagePath(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  return path.trim().startsWith('data:image/');
}

bool isLocalFileImagePath(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  final trimmed = path.trim();
  return !isRemoteImagePath(trimmed) && !isDataImagePath(trimmed);
}

/// Encodes a local image file into a Firestore-safe data URI (no Firebase Storage).
Future<String?> encodeLocalImageForSync(String? path) async {
  final trimmed = path?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (isRemoteImagePath(trimmed) || isDataImagePath(trimmed)) return trimmed;

  if (kIsWeb) {
    try {
      final bytes = await readImageBytes(trimmed);
      if (bytes == null || bytes.isEmpty) return trimmed;
      final compressed = _compressForSync(bytes);
      if (compressed == null) return trimmed;
      return 'data:image/jpeg;base64,${base64Encode(compressed)}';
    } catch (e) {
      debugPrint('Web image encode failed: $e');
      return trimmed;
    }
  }

  try {
    final bytes = await readImageBytes(trimmed);
    if (bytes == null || bytes.isEmpty) return null;
    final compressed = _compressForSync(bytes);
    if (compressed == null) {
      debugPrint('Image too large to sync via Firestore: $trimmed');
      return trimmed;
    }
    return 'data:image/jpeg;base64,${base64Encode(compressed)}';
  } catch (e) {
    debugPrint('Image encode for sync failed: $e');
    return trimmed;
  }
}

Uint8List? _compressForSync(Uint8List raw) {
  final decoded = img.decodeImage(raw);
  if (decoded == null) {
    return raw.length <= _maxSyncBytes ? raw : null;
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

Future<Uint8List?> readImageBytes(String? path) async {
  final trimmed = path?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  if (isDataImagePath(trimmed)) {
    final comma = trimmed.indexOf(',');
    if (comma < 0) return null;
    try {
      return base64Decode(trimmed.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  if (isRemoteImagePath(trimmed) || kIsWeb) return null;

  final file = File(trimmed);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}

ImageProvider? imageProviderForPath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;

  if (isDataImagePath(trimmed)) {
    final comma = trimmed.indexOf(',');
    if (comma < 0) return null;
    try {
      final bytes = base64Decode(trimmed.substring(comma + 1));
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  if (isRemoteImagePath(trimmed)) return NetworkImage(trimmed);
  if (kIsWeb) return null;
  return FileImage(File(trimmed));
}
