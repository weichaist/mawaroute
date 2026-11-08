import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/cupertino.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
import "package:flutter_smart_dialog/flutter_smart_dialog.dart";
import "package:get/get.dart";
import "package:mawaroute_shop/models/shop_image_model.dart";
import "package:wechat_assets_picker/wechat_assets_picker.dart";

import "../api/firestore_services.dart";
import "../utils/compress_image_file.dart";
import "auth_controller.dart";

class HomeController extends GetxController {
  static HomeController instance = Get.find<HomeController>();

  final selectedBottomNavBarIndex = 0.obs;
  final selectedImages = <AssetEntity>[].obs;

  final FireStoreService api = FireStoreService();
  final FirebaseStorage storage = FirebaseStorage.instance;
  DocumentSnapshot? snapshot;
  RxBool isLastPage = false.obs;
  RxList<String> selectedPictures = <String>[].obs;

  RxBool multipleSelectionMode = false.obs;

  // For uploading
  final descriptionController = TextEditingController();
  final typeController = TextEditingController();

  // For Listing
  final RxMap<DateTime, List<ShopImageModel>> shopImages =
      <DateTime, List<ShopImageModel>>{}.obs;
  List<ShopImageModel> shopImagesList = <ShopImageModel>[].obs;

  String shopUid = "";

  final authController = AuthController.instance;

  void initList() async {
    await authController.fetchShop();
    shopUid = authController.shop.value.uid!;
    shopImages.value = {};
    shopImagesList.clear();
    snapshot = null;
    await fetchShopImages();
  }

  void initUpload() async {
    await authController.fetchShop();
    shopUid = authController.shop.value.uid!;
  }

  Future fetchShopImages() async {
    EasyLoading.show(status: "Loading");
    const limit = 15;
    Map<dynamic, dynamic> output = await api.fetchShopImages(
      limit: limit,
      snapshot: snapshot,
      shopUid: shopUid,
    );
    List<ShopImageModel> result = output["results"];
    shopImagesList = result;
    snapshot = output["snapshot"];
    isLastPage.value = result.length < limit;
    for (var element in result) {
      DateTime dateTime = DateTime(element.createdAt.year,
          element.createdAt.month, element.createdAt.day);
      if (shopImages[dateTime] == null) {
        shopImages[dateTime] = [];
      }
      shopImages[dateTime]!.add(element);
    }
    shopImages.refresh();
    EasyLoading.dismiss();
  }

  Future deleteImages() async {
    try {
      EasyLoading.show(status: "Deleting images");
      await api.deleteShopImages(
        imagesUid: selectedPictures,
        shopUid: shopUid,
      );
      for (var entry in shopImages.entries) {
        List<ShopImageModel> temp = [];
        for (ShopImageModel campaignTaskImage in entry.value) {
          if (!selectedPictures.contains(campaignTaskImage.uid)) {
            temp.add(campaignTaskImage);
          }
        }
        shopImages[entry.key] = temp;
      }
      selectedPictures.clear();
    } catch (e) {
      debugPrint("$e");
      EasyLoading.showError("Deleting images failed");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<List<String>> uploadTaskImage({required File file}) async {
    String url = "";
    String downloadUrl = "";
    try {
      final ref = storage.ref(
          "v1-media/shop_campaign_tasks/$shopUid/${DateTime.now().toString()}.jpg");
      await ref.putFile(file).timeout(const Duration(seconds: 10));
      downloadUrl = await ref.getDownloadURL();
      url = ref.fullPath;
      return [url, downloadUrl];
    } catch (e) {
      debugPrint("$e");
      return [];
    }
  }

  Future upload() async {
    if (selectedImages.isEmpty) {
      SmartDialog.showToast("Add at least one image file");
      return;
    }
    try {
      EasyLoading.show(status: "Uploading");
      List<Map<String, dynamic>> shopImages = [];
      int imageCounter = 1;
      for (AssetEntity imageFile in selectedImages) {
        SmartDialog.showToast(
          "Uploading $imageCounter / ${selectedImages.length} shop images",
          alignment: Alignment.bottomCenter,
        );
        File? image = await imageFile.file;
        File compressedImage = await compressImageFile(image!);
        List<String> imageLinks = await uploadTaskImage(file: compressedImage);
        if (imageLinks.length != 2) {
          SmartDialog.dismiss();
          SmartDialog.showToast("Could not upload file.");
          return;
        }
        shopImages.add(ShopImageModel(
          imageLink: imageLinks[0],
          downloadUrl: imageLinks[1],
          shopUid: shopUid,
          index: 0,
          createdAt: DateTime.now(),
        ).toJson());
        imageCounter += 1;
      }
      await api.addShopImages(shopUid: shopUid, shopImages: shopImages);

      SmartDialog.dismiss();
      SmartDialog.showToast("Successfully added shop image.");
      clear();
      EasyLoading.dismiss();
    } catch (e) {
      debugPrint("$e");
      EasyLoading.dismiss();
      SmartDialog.dismiss();
      SmartDialog.showToast("Failed to add shop image.");
    }
  }

  void clear() {
    selectedImages.value = [];
    descriptionController.clear();
    typeController.clear();
  }
}
