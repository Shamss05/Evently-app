import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
}

extension IntExtention on int {
  String get formatedDate {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(this);
    return DateFormat("dd\nMMM").format(date);
  }
}
