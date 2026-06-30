import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('#,##,###');
final _currencyFormat = NumberFormat('#,##,###.00');

String formatNumber(int value) => _numberFormat.format(value);

String formatCurrency(int value) => '${_currencyFormat.format(value)} BDT';

String formatCurrencyCompact(int value) => '${_numberFormat.format(value)} BDT';

String formatPhone(String? phone) {
  if (phone == null || phone.isEmpty) return 'N/A';
  // Format: 01XXXXXXXXX -> 01XX-XXXXXXX
  if (phone.length == 11 && phone.startsWith('01')) {
    return '${phone.substring(0, 4)}-${phone.substring(4)}';
  }
  return phone;
}



























