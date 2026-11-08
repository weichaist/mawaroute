import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void showSuccess(String msg) {
  SmartDialog.showNotify(msg: msg, notifyType: NotifyType.success);
}

void showAlert(String msg) {
  SmartDialog.showNotify(msg: msg, notifyType: NotifyType.alert);
}

void showError(String msg) {
  SmartDialog.showNotify(msg: msg, notifyType: NotifyType.failure);
}

void showLoading(String msg) {
  SmartDialog.showLoading(msg: msg, clickMaskDismiss: false);
}

void showToast(String msg) {
  SmartDialog.showToast(msg);
}

void showDismiss() {
  SmartDialog.dismiss();
}
