import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

RegExp doubleFormat = RegExp(r'(^[+-]?\d*\.?\d*)');
MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(
  mask: '####/##/##',
  filter: {'#': RegExp(r'\d')},
  type: MaskAutoCompletionType.lazy,
);

String dateString(DateTime? datetime) {
  final outputFormat = DateFormat('yyyy/MM/dd hh:mm a');
  return outputFormat.format(datetime!);
}

int? stringToInt({required String text}) {
  int? value = text.isNotEmpty ? int.parse(text) : null;
  return value;
}

String intToString({required int? num}) {
  String value = num != null ? num.toString() : "";
  return value;
}

String getFileSize(int bytes, {int decimals = 1}) {
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  int i = 0;
  double value = bytes.toDouble();
  if (bytes > 0) {
    i = (log(bytes) / log(1024)).floor();
    value = bytes / pow(1024, i);
  }
  return '${value.toStringAsFixed(decimals)} ${suffixes[i]}';
}

int size500K = 1024 * 800;

bool shouldUploadImage(String name) {
  return !(name.contains("https://") | name.isEmpty);
}

bool isFile500KPlus(PlatformFile image) {
  if (shouldUploadImage(image.name)) {
    if (image.size > size500K) {
      return true;
    }
  }
  return false;
}

String generateRandomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

String reverseString(String input) {
  return input.split('').reversed.join('');
}

dynamic getParameterValue(Map parameters, String key) {
  if (parameters.containsKey(key)) {
    return parameters[key];
  } else {
    return "";
  }
}

void showSuccess(String msg) {
  SmartDialog.showNotify(
    msg: msg,
    notifyType: NotifyType.success,
  );
}

void showAlert(String msg) {
  SmartDialog.showNotify(
    msg: msg,
    notifyType: NotifyType.alert,
  );
}

void showError(String msg) {
  SmartDialog.showNotify(
    msg: msg,
    notifyType: NotifyType.failure,
  );
}

void showLoading(String msg) {
  SmartDialog.showLoading(
    msg: msg,
    clickMaskDismiss: false,
  );
}

void showToast(String msg) {
  SmartDialog.showToast(msg);
}

void showDismiss() {
  SmartDialog.dismiss();
}

class CustomException implements Exception {
  final String message;
  CustomException(this.message);
}
