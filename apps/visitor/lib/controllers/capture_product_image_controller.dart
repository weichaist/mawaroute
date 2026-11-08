import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/models/shop_model.dart';
import 'package:mawaroute_visitor/utilis/compress_image_file.dart';

import '../utilis/current_localtion.dart';
import '../utilis/formatter.dart';
import '../utilis/image_matching.dart' as image_matching;
import 'auth_controller.dart';

class CaptureProductImageController extends GetxController {
  static CaptureProductImageController instance =
      Get.find<CaptureProductImageController>();
  final AuthController authController = AuthController.instance;

  final _db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  final isLoading = false.obs;
  String googlePlaceId = "";
  RxString url = "".obs;
  double lat = 0.0;
  double lng = 0.0;
  final capturedImagePath = ''.obs;
  final capturedImageUploadedUrl = ''.obs;
  final similarityScore = 0.0.obs;
  late Rx<Position> currentPosition;
  //todo change it back after demo
  final similarityThreshold = 0.5;
  final thresholdDistance = 500;

  dynamic targetAnnotation = {
    "fullTextAnnotation": null,
    "labelAnnotations": null,
    "localizedObjectAnnotations": null,
  };
  Future<void> init() async {
    targetAnnotation = {
      "fullTextAnnotation": null,
      "labelAnnotations": null,
      "localizedObjectAnnotations": null,
    };
    clear();
    if (Get.arguments != null) {
      try {
        url.value = "";
        googlePlaceId = Get.arguments["googlePlaceId"];
        lat = Get.arguments["lat"];
        lng = Get.arguments["lng"];
        isLoading.value = true;
        await fetchShopUrl();
        if (url.isEmpty) {
          SmartDialog.showNotify(msg: 'Error', notifyType: NotifyType.error);
          throw ('Url Error');
        }
        targetAnnotation = await image_matching
            .cloudAPIExtractTextDataFromImage(
              uri: gsUrl(getStorageLocationFromUrl(url.value)),
            );
        currentPosition = (await getUserCurrentPosition()).obs;
      } catch (e) {
        if (kDebugMode) print(e);
      } finally {
        isLoading.value = false;
      }
    }
  }

  void clear() {
    capturedImagePath.value = '';
    capturedImageUploadedUrl.value = '';
    similarityScore.value = 0.0;
  }

  double calculateDistance() {
    double distance = Geolocator.distanceBetween(
      lat.toDouble(),
      lng.toDouble(),
      currentPosition.value.latitude,
      currentPosition.value.longitude,
    );
    return distance;
  }

  Future<void> runAISimilarityCalculation() async {
    try {
      String capturedImageUploadedGsUrl = await uploadImage();
      final userFileAnnotation = await image_matching
          .cloudAPIExtractTextDataFromImage(uri: capturedImageUploadedGsUrl);
      similarityScore.value = await image_matching.getSimilarityScore(
        targetAnnotation,
        userFileAnnotation,
      );
    } catch (e) {
      if (kDebugMode) print(e);
      return;
    }
  }

  Future uploadImage() async {
    String now = DateTime.now().toIso8601String();
    Reference ref = storage.ref(
      "v1-media/uploaded_product_pictures/${auth.currentUser!.uid}/img-$now.jpg",
    );
    try {
      File compressedImage = await compressImageFile(
        File(capturedImagePath.value),
      );
      await ref.putFile(compressedImage).timeout(const Duration(seconds: 10));
      String downloadUrl = await ref.getDownloadURL();
      capturedImageUploadedUrl.value = downloadUrl;
      return gsUrl(ref.fullPath);
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future<void> addFailedTask() async {
    try {
      await _db.collection('image_to_be_deleted').add({
        "url": capturedImageUploadedUrl.value,
      });
    } catch (e) {
      if (kDebugMode) print(e);
      if (kDebugMode) print("Error occurred during task completion");
    }
  }

  Future<void> fetchShopUrl() async {
    try {
      await _db
          .collection('shops')
          .where("googlePlaceId", isEqualTo: googlePlaceId)
          .get()
          .then((value) {
            if (value.docs.isNotEmpty) {
              ShopModel shop = ShopModel.fromJson(
                value.docs.first.data(),
                value.docs.first.id,
              );
              url.value = shop.downloadUrl!;
            }
          });
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}
