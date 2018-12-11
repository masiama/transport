import 'package:string_scanner/string_scanner.dart';

const _MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

final _shortWeekdayRegExp = RegExp(r'Mon|Tue|Wed|Thu|Fri|Sat|Sun');
final _longWeekdayRegExp = RegExp(r'Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday');
final _monthRegExp = RegExp(r'Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec');
final _digitRegExp = RegExp(r'\d+');

DateTime parseHttpDate(String date) {
  final StringScanner scanner = StringScanner(date);

  if (scanner.scan(_longWeekdayRegExp)) {
    scanner.expect(', ');
    final int day = _parseInt(scanner, 2);
    scanner.expect('-');
    final int month = _parseMonth(scanner);
    scanner.expect('-');
    final int year = 1900 + _parseInt(scanner, 2);
    scanner.expect(' ');
    final DateTime time = _parseTime(scanner);
    scanner.expect(' GMT');
    scanner.expectDone();

    return _makeDateTime(year, month, day, time);
  }
  
  scanner.expect(_shortWeekdayRegExp);
  if (scanner.scan(', ')) {
    final int day = _parseInt(scanner, 2);
    scanner.expect(' ');
    final int month = _parseMonth(scanner);
    scanner.expect(' ');
    final int year = _parseInt(scanner, 4);
    scanner.expect(' ');
    final DateTime time = _parseTime(scanner);
    scanner.expect(' GMT');
    scanner.expectDone();

    return _makeDateTime(year, month, day, time);
  }
  
  scanner.expect(' ');
  final int month = _parseMonth(scanner);
  scanner.expect(' ');
  final int day = scanner.scan(' ') ? _parseInt(scanner, 1) : _parseInt(scanner, 2);
  scanner.expect(' ');
  final DateTime time = _parseTime(scanner);
  scanner.expect(' ');
  final int year = _parseInt(scanner, 4);
  scanner.expectDone();

  return _makeDateTime(year, month, day, time);
}

int _parseMonth(StringScanner scanner) {
  scanner.expect(_monthRegExp);
  return _MONTHS.indexOf(scanner.lastMatch[0]) + 1;
}

int _parseInt(StringScanner scanner, int digits) {
  scanner.expect(_digitRegExp);
  if (scanner.lastMatch[0].length != digits) scanner.error('expected a $digits-digit number.');
  return int.parse(scanner.lastMatch[0]);
}

DateTime _parseTime(StringScanner scanner) {
  final int hours = _parseInt(scanner, 2);
  if (hours >= 24) scanner.error('hours may not be greater than 24.');
  scanner.expect(':');

  final int minutes = _parseInt(scanner, 2);
  if (minutes >= 60) scanner.error('minutes may not be greater than 60.');
  scanner.expect(':');

  final int seconds = _parseInt(scanner, 2);
  if (seconds >= 60) scanner.error('seconds may not be greater than 60.');

  return DateTime(1, 1, 1, hours, minutes, seconds);
}

DateTime _makeDateTime(int year, int month, int day, DateTime time) {
  final DateTime dateTime = DateTime.utc(year, month, day, time.hour, time.minute, time.second);
  if (dateTime.month != month) throw FormatException('invalid day $day for month $month.');
  return dateTime;
}
