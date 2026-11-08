import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

String dateString(DateTime? datetime) {
  final outputFormat = DateFormat('yyyy/MM/dd hh:mm');
  return outputFormat.format(datetime!);
}

String formatTimeAgo(DateTime timestamp) {
  // final fifteenAgo = DateTime.now().difference(timestamp);
  return timeago.format(timestamp, locale: 'en_short');
}
