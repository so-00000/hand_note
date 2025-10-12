// lib/utils/date_formatter.dart
import 'package:intl/intl.dart';

String formatDateTime(dynamic input) {
  if (input == null) return '';
  DateTime date;

  // DateTime型ならそのまま
  if (input is DateTime) {
    date = input;
  }
  // String型（DBから返るとき）も対応
  else if (input is String) {
    try {
      date = DateTime.parse(input);
    } catch (_) {
      return input.toString();
    }
  }
  else {
    return input.toString();
  }

  return DateFormat('yyyy/MM/dd HH:mm').format(date);
}
