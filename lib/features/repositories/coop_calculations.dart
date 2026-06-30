import '../../core/db/app_db.dart';
import '../../core/utils/date_utils.dart';

List<String> parseDepositMonths(String? reason, String monthKey) {
  if (reason == null || reason.trim().isEmpty) {
    return [monthKey];
  }

  const monthNames = [
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
    'December',
  ];

  if (reason.toLowerCase().contains(' to ')) {
    final parts = reason.split(' to ');
    if (parts.length == 2) {
      final fromIndex = monthNames.indexOf(parts[0].trim());
      final toIndex = monthNames.indexOf(parts[1].trim());
      if (fromIndex >= 0 && toIndex >= fromIndex) {
        final year = monthKey.split('-')[0];
        return [
          for (var i = fromIndex; i <= toIndex; i++)
            '$year-${(i + 1).toString().padLeft(2, '0')}',
        ];
      }
    }
  }

  return [monthKey];
}

int totalCollectionFromDeposits(List<Deposit> deposits) {
  var total = 0;
  for (final d in deposits) {
    if (d.deletedAt == null) total += d.amount;
  }
  return total;
}

int collectionForMonthFromDeposits(List<Deposit> deposits, String monthKey) {
  var total = 0;
  for (final d in deposits) {
    if (d.deletedAt != null) continue;
    final months = parseDepositMonths(d.reason, d.monthKey);
    if (months.contains(monthKey)) {
      total += d.amount ~/ months.length;
    }
  }
  return total;
}

Map<String, int> collectionByMonthFromDeposits(List<Deposit> deposits) {
  final map = <String, int>{};
  for (final d in deposits) {
    if (d.deletedAt != null) continue;
    final months = parseDepositMonths(d.reason, d.monthKey);
    final amountPerMonth = d.amount ~/ months.length;
    for (final mk in months) {
      map[mk] = (map[mk] ?? 0) + amountPerMonth;
    }
  }
  final keys = map.keys.toList()..sort();
  return {for (final k in keys) k: map[k]!};
}

Map<String, int> collectionByMonthForYearFromDeposits(
  List<Deposit> deposits,
  int year,
) {
  final yearPrefix = '$year-';
  final map = <String, int>{};
  for (final d in deposits) {
    if (d.deletedAt != null) continue;
    final depositMonths = parseDepositMonths(d.reason, d.monthKey);
    final yearMonths =
        depositMonths.where((mk) => mk.startsWith(yearPrefix)).toList();
    if (yearMonths.isEmpty) continue;
    final amountPerMonth = d.amount ~/ depositMonths.length;
    for (final mk in yearMonths) {
      map[mk] = (map[mk] ?? 0) + amountPerMonth;
    }
  }
  final keys = map.keys.toList()..sort();
  return {for (final k in keys) k: map[k]!};
}

Map<String, dynamic> dueSummaryFromData({
  required List<Member> members,
  required List<Deposit> deposits,
  required DateTime start,
  required DateTime endInclusive,
}) {
  final activeMembers =
      members.where((m) => m.deletedAt == null && m.isActive).toList();
  final activeDeposits = deposits.where((d) => d.deletedAt == null).toList();

  final paidByMemberMonth = <String, Map<String, int>>{};
  for (final d in activeDeposits) {
    final mm =
        paidByMemberMonth.putIfAbsent(d.memberUuid, () => <String, int>{});
    final depositMonths = parseDepositMonths(d.reason, d.monthKey);
    final amountPerMonth = d.amount ~/ depositMonths.length;
    for (final mk in depositMonths) {
      mm[mk] = (mm[mk] ?? 0) + amountPerMonth;
    }
  }

  final months = monthKeysBetweenInclusive(start, endInclusive);
  var totalDue = 0;
  final memberDueDetails = <Map<String, dynamic>>[];
  for (final m in activeMembers) {
    final dueMonths = <String, int>{};
    for (final mk in months) {
      final paid = paidByMemberMonth[m.uuid]?[mk] ?? 0;
      final due = m.monthlyAmount - paid;
      if (due > 0) dueMonths[mk] = due;
    }
    final memberDue = dueMonths.values.fold<int>(0, (a, b) => a + b);
    totalDue += memberDue;
    memberDueDetails.add({
      'member': m,
      'totalDue': memberDue,
      'dueMonths': dueMonths,
    });
  }

  memberDueDetails
      .sort((a, b) => (b['totalDue'] as int).compareTo(a['totalDue'] as int));

  return {
    'totalDue': totalDue,
    'members': memberDueDetails,
    'months': months,
  };
}

Map<String, dynamic> dueForOneMemberFromData({
  required Member member,
  required List<Deposit> deposits,
  required DateTime start,
  required DateTime endInclusive,
}) {
  final memberDeposits = deposits
      .where((d) => d.deletedAt == null && d.memberUuid == member.uuid)
      .toList();

  final paidByMonth = <String, int>{};
  for (final d in memberDeposits) {
    final depositMonths = parseDepositMonths(d.reason, d.monthKey);
    final amountPerMonth = d.amount ~/ depositMonths.length;
    for (final mk in depositMonths) {
      paidByMonth[mk] = (paidByMonth[mk] ?? 0) + amountPerMonth;
    }
  }

  final months = monthKeysBetweenInclusive(start, endInclusive);
  final dueMonths = <String, int>{};
  for (final mk in months) {
    final paid = paidByMonth[mk] ?? 0;
    final due = member.monthlyAmount - paid;
    if (due > 0) dueMonths[mk] = due;
  }
  final totalDue = dueMonths.values.fold<int>(0, (a, b) => a + b);
  return {
    'totalDue': totalDue,
    'dueMonths': dueMonths,
    'months': months,
    'member': member,
  };
}
