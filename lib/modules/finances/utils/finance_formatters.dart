/// Set this to your currency symbol, e.g. 'Rs', '\$', '£'. Empty = numbers only.
const String kCurrencySymbol = '';

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// 3500 -> "3,500", 1234.5 -> "1,234.50"
String formatAmount(double value, {bool withSymbol = true}) {
  final isWhole = value == value.roundToDouble();
  final fixed = value.abs().toStringAsFixed(isWhole ? 0 : 2);
  final parts = fixed.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final decimals = parts.length > 1 ? '.${parts[1]}' : '';
  final sign = value < 0 ? '-' : '';
  final symbol =
      withSymbol && kCurrencySymbol.isNotEmpty ? '$kCurrencySymbol ' : '';
  return '$sign$symbol$intPart$decimals';
}

/// "14 Nov 2026"
String formatDate(DateTime d) =>
    '${d.day} ${_monthNames[d.month - 1].substring(0, 3)} ${d.year}';

/// "14 Nov 2026, 3:05 PM"
String formatDateTime(DateTime d) {
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? 'PM' : 'AM';
  return '${formatDate(d)}, $hour12:$minute $period';
}

/// "November 2026"
String formatMonth(DateTime d) => '${_monthNames[d.month - 1]} ${d.year}';

DateTime monthStart(DateTime d) => DateTime(d.year, d.month);

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;
