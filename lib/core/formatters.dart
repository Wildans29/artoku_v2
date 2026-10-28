import 'package:intl/intl.dart';

final _rupiah =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
final _numberOnly = NumberFormat('#,###', 'id_ID');

String formatRupiah(int amount) => _rupiah.format(amount);

String formatNumber(int amount) => _numberOnly.format(amount);

String formatDate(DateTime date) =>
    DateFormat('d MMM yyyy', 'id_ID').format(date);

String formatDateTime(DateTime date) =>
    DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);

String formatMonthYear(DateTime date) =>
    DateFormat('MMMM yyyy', 'id_ID').format(date);

String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;

  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  if (diff == -1) return 'Besok';
  return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date);
}

int parseNumber(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(cleaned) ?? 0;
}
