import 'dart:math';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../config/app_config.dart';

String formatDateTime(DateTime dateTime) {
  return DateFormat("yyyy-MM-dd HH:mm").format(dateTime);
}

int tokenMultiplier(int? maxTaskNumber, int taskNumber) {
  if (maxTaskNumber != null) {
    if (maxTaskNumber > taskNumber) {
      return taskNumber;
    } else {
      return maxTaskNumber;
    }
  } else {
    return taskNumber;
  }
}

String formatTimeAgo(DateTime timestamp) {
  // final fifteenAgo = DateTime.now().difference(timestamp);
  if (Get.locale?.languageCode == 'ja') {
    return timeago.format(timestamp, locale: 'ja');
  } else {
    return timeago.format(timestamp, locale: 'en_short');
  }
}

String gsUrl(String text) {
  return "gs://${AppConfig.firebaseStorageBucket}/$text";
}

String getStorageLocationFromUrl(String url) {
  Uri parsedUri = Uri.parse(url);
  String remainingPath = "";

  int v1MediaIndex = parsedUri.pathSegments.indexOf("v1-media");
  if (v1MediaIndex != -1 && v1MediaIndex + 1 < parsedUri.pathSegments.length) {
    remainingPath =
        "v1-media/${parsedUri.pathSegments.sublist(v1MediaIndex + 1).join("/")}";
  }
  return remainingPath;
}

int convertTimeToInt(String timeString) {
  List<String> time = timeString.split(":");
  int timeInt = int.parse(time[0]) * 100 + int.parse(time[1]);
  return timeInt;
}

String reverseString(String input) {
  return input.split('').reversed.join('');
}

String generateRandomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random rnd = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ),
  );
}

String getArgument(String key) {
  String chatUid = "";
  if (Get.arguments != null && Get.arguments.containsKey(key)) {
    chatUid = Get.arguments[key];
  }
  return chatUid;
}

String convertNumber(int number) {
  if (number >= 1000000) {
    return "${(number / 1000000).toStringAsFixed(1)}m";
  } else if (number >= 1000) {
    return "${(number / 1000).toStringAsFixed(1)}k";
  } else {
    return number.toString();
  }
}
