import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController {
  static PermissionController instance = Get.find();

  Future<void> initPermissionRequest(String type) async {
    if (type == 'camera') {
      await Permission.camera.request();
    } else if (type == 'photos') {
      await Permission.photos.request();
    } else if (type == 'location') {
      await Permission.location.request();
    } else {
      await Permission.notification.request();
    }
    await initPermissionChecking(type);
  }

  PageController pageController = PageController();

  RxBool cameraPermissionGranted = false.obs;
  RxString cameraPermissionText = ''.obs;

  RxBool photoPermissionGranted = false.obs;
  RxString photoPermissionText = ''.obs;

  RxBool locationPermissionGranted = false.obs;
  RxString locationPermissionText = ''.obs;

  RxBool notificationPermissionGranted = false.obs;
  RxString notificationPermissionText = ''.obs;

  final List<String> allPermissions = [
    'camera',
    'photos',
    'location',
    'notification',
  ];

  Future<void> init(String type) async {
    final int page = allPermissions.indexOf(type);
    pageController = PageController(initialPage: page);
  }

  Future<void> initCameraPermission() async {
    await getCameraPermission();
  }

  Future<void> initLocationPermission() async {
    await getLocationPermission();
  }

  Future<void> initNotificationPermission() async {
    await getNotificationPermission();
  }

  Future<void> initPermissionChecking(String type) async {
    if (type == 'camera') {
      await initCameraPermission();
    } else if (type == 'photos') {
      await getPhotoPermission();
    } else if (type == 'location') {
      await initLocationPermission();
    } else {
      await initNotificationPermission();
    }
  }

  Future<void> initPhotoPermission() async {
    await getPhotoPermission();
  }

  Future getPhotoPermission() async {
    PermissionStatus photoPermission = await Permission.photos.status;
    if (photoPermission.isGranted) {
      photoPermissionGranted.value = true;
      photoPermissionText.value = 'Permission Is granted';
    } else if (photoPermission.isLimited) {
      photoPermissionGranted.value = true;
      photoPermissionText.value = 'Limited Permission Is Granted';
    } else {
      photoPermissionGranted.value = false;
      photoPermissionText.value = 'No Permission Is Granted';
    }
  }

  Future getCameraPermission() async {
    PermissionStatus cameraPermission = await Permission.camera.status;
    if (cameraPermission.isGranted) {
      cameraPermissionGranted.value = true;
      cameraPermissionText.value = 'Permission Is granted';
    } else if (cameraPermission.isLimited) {
      cameraPermissionGranted.value = true;
      cameraPermissionText.value = 'Limited Permission Is Granted';
    } else {
      cameraPermissionGranted.value = false;
      cameraPermissionText.value = 'No Permission Is Granted';
    }
  }

  Future getLocationPermission() async {
    PermissionStatus locationPermission = await Permission.location.status;
    if (locationPermission.isGranted) {
      locationPermissionGranted.value = true;
      locationPermissionText.value = 'Permission Is granted';
    } else if (locationPermission.isLimited) {
      locationPermissionGranted.value = true;
      locationPermissionText.value = 'Limited Permission Is Granted';
    } else {
      locationPermissionGranted.value = false;
      locationPermissionText.value = 'No Permission Is Granted';
    }
  }

  Future getNotificationPermission() async {
    PermissionStatus notificationPermission =
        await Permission.notification.status;
    if (notificationPermission.isGranted) {
      notificationPermissionGranted.value = true;
      notificationPermissionText.value = 'Permission Is granted';
    } else if (notificationPermission.isLimited) {
      notificationPermissionGranted.value = true;
      notificationPermissionText.value = 'Limited Permission Is Granted';
    } else {
      notificationPermissionGranted.value = false;
      notificationPermissionText.value = 'No Permission Is Granted';
    }
  }
}
