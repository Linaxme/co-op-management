import 'package:cloud_firestore/cloud_firestore.dart';

DateTime parseFirestoreDateTime(dynamic value, {DateTime? fallback}) {
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String && value.isNotEmpty) return DateTime.parse(value);
  if (fallback != null) return fallback;
  throw FormatException('Invalid Firestore date: $value');
}

DateTime? parseFirestoreDateTimeOrNull(dynamic value) {
  if (value == null) return null;
  return parseFirestoreDateTime(value);
}

String parseFirestoreString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  if (value is String) return value;
  return value.toString();
}

String? parseFirestoreStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

int parseFirestoreInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

bool parseFirestoreBool(dynamic value, {bool defaultValue = true}) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return defaultValue;
}
