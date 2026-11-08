import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/api/firestore_services.dart';
import 'package:mawaroute_shop/controllers/auth_controller.dart';
import 'package:mawaroute_shop/models/shop_model.dart';

import '../utils/enums.dart' as enums;

class TimeTableController extends GetxController {
  static TimeTableController instance = Get.find<TimeTableController>();
  final api = FireStoreService();
  final authController = AuthController.instance;
  List<String> days = enums.days;
  RxMap<String, Map<String, TimeOfDay?>> timeTableList =
      <String, Map<String, TimeOfDay?>>{}.obs;
  ShopModel shop = emptyShopModel;

  void init() {
    shop = Get.arguments["shop"];
    for (String day in days) {
      String key = day.substring(0, 3);
      timeTableList[day] = {"open": null, "close": null};
      for (String timeKey in ["open", "close"]) {
        String? timeString = shop.timeTable["${key}_$timeKey"];
        TimeOfDay? timeOfDay;
        if (timeString != null) {
          List<String> time = timeString.split(":");
          timeOfDay =
              TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
        }
        timeTableList[day]![timeKey] = timeOfDay;
      }
    }
  }

  Future<void> pickTime(BuildContext context, String day, String timeKey) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      cancelText: 'Cancel'.tr,
      helpText: 'Enter Time'.tr,
      hourLabelText: 'Hour'.tr,
      minuteLabelText: 'Minute'.tr,
      errorInvalidText: 'Invalid Time'.tr,
      confirmText: 'OK',
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (pickedTime != null) {
      timeTableList[day]![timeKey] = pickedTime;
      timeTableList.refresh();
    }
  }

  Future<void> updateTimeTable() async {
    Map<String, dynamic> obj = {};
    bool isValid = true;
    for (String day in days) {
      String key = day.substring(0, 3);
      for (String timeKey in ["open", "close"]) {
        if (timeTableList[day]![timeKey] != null) {
          int hour = timeTableList[day]![timeKey]!.hour;
          int minute = (timeTableList[day]![timeKey]!.minute);
          obj["${key}_$timeKey"] =
              "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
        } else {
          obj["${key}_$timeKey"] = null;
        }
        if (timeKey == "close") {
          if ((obj["${key}_open"] != null && obj["${key}_close"] == null) ||
              (obj["${key}_open"] == null && obj["${key}_close"] != null)) {
            isValid = false;
          }
        }
      }
    }
    if (!isValid) {
      EasyLoading.showToast('Please enter both open and close time'.tr);
    } else {
      EasyLoading.show();
      await api.updateShop(shopUid: shop.uid!, shopInfo: obj);
      EasyLoading.dismiss();
      Get.back();
    }
  }
}
