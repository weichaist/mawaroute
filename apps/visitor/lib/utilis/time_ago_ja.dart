import 'package:timeago/timeago.dart';

class JaShortMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => '今';
  @override
  String aboutAMinute(int minutes) => '1分前';
  @override
  String minutes(int minutes) => '$minutes分前';
  @override
  String aboutAnHour(int minutes) => '1時間前';
  @override
  String hours(int hours) => '$hours時間前';
  @override
  String aDay(int hours) => '1日前';
  @override
  String days(int days) => '$days日前';
  @override
  String aboutAMonth(int days) => '1ヶ月前';
  @override
  String months(int months) => '$monthsヶ月前';
  @override
  String aboutAYear(int year) => '1年前';
  @override
  String years(int years) => '$years年前';
  @override
  String wordSeparator() => ' ';
}
