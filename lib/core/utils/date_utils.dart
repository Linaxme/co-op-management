import 'package:intl/intl.dart';

String monthKey(DateTime d) => DateFormat('yyyy-MM').format(DateTime(d.year, d.month));
DateTime parseMonthKey(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]));
}

/// Convert monthKey (yyyy-MM) to month name (e.g., "2025-01" -> "January 2025")
String monthKeyToName(String monthKey) {
  try {
    final date = parseMonthKey(monthKey);
    return DateFormat('MMMM yyyy').format(date);
  } catch (e) {
    return monthKey; // Return original if parsing fails
  }
}

List<String> monthKeysBetweenInclusive(DateTime start, DateTime end) {
  final s = DateTime(start.year, start.month);
  final e = DateTime(end.year, end.month);
  final keys = <String>[];
  var cur = s;
  while (!cur.isAfter(e)) {
    keys.add(monthKey(cur));
    cur = DateTime(cur.year, cur.month + 1);
  }
  return keys;
}

/// Years available for due/deposit month selection (newest first).
List<int> availableYears({int firstYear = 2025}) {
  final currentYear = DateTime.now().year;
  return [for (var y = currentYear; y >= firstYear; y--) y];
}

/// All 12 month keys for a calendar year, including months with zero collection.
Map<String, int> monthKeysForYear(int year, Map<String, int> data) {
  final result = <String, int>{};
  for (var m = 1; m <= 12; m++) {
    final mk = monthKeyFromYearMonth(year, m);
    result[mk] = data[mk] ?? 0;
  }
  return result;
}

String monthKeyFromYearMonth(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';

int yearFromMonthKey(String key) => int.parse(key.split('-')[0]);

int monthFromMonthKey(String key) => int.parse(key.split('-')[1]);

String calendarMonthName(int month) =>
    DateFormat('MMMM').format(DateTime(2000, month));