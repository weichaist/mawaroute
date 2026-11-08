import 'package:web/web.dart' as web;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/google_firestore_services.dart';
import '../api/shop_service.dart';
import '../enums.dart';
import '../models/reward_model.dart';
import '../models/reward_receiver_model.dart';
import '../models/shop_model.dart';
import '../pagination.dart';
import '../utility.dart';

class RewardController extends GetxController {
  static RewardController instance = Get.find<RewardController>();
  FireStoreService api = FireStoreService();
  ShopService shopServiceApi = ShopService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Rx<TextEditingController> title = TextEditingController().obs;
  Rx<TextEditingController> description = TextEditingController().obs;
  Rx<TextEditingController> status = TextEditingController().obs;
  Rx<TextEditingController> tokenNumber = TextEditingController().obs;
  Rx<TextEditingController> upperLimit = TextEditingController().obs;
  Rx<TextEditingController> maxNumberPerUser = TextEditingController().obs;
  Rx<TextEditingController> rewardDistributionType =
      TextEditingController().obs;
  late final imageFile = PlatformFile(name: "", size: 0).obs;
  RxString selectedStatus = RewardType.active.name.obs;
  RxString selectedRewardDistributionType =
      RewardDistributionType.email.name.obs;
  RewardModel rewardToEdit = emptyReward;
  RxList<RewardModel> rewards = <RewardModel>[].obs;
  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<DateTime> endTime = DateTime.now().obs;

  Rx<Pagination<RewardReceiverModel>> rewardReceivers =
      Pagination<RewardReceiverModel>(fromJson: null, query: null).obs;

  RxList<ShopModel> shops = <ShopModel>[].obs;
  Rx<ShopModel> selectedShop = emptyShopModel.obs;

  void changeImage(PlatformFile? file) async {
    imageFile.value = file!;
    imageFile.update((value) {
      value = file;
    });
  }

  Future<void> init() async {
    clear();
    status.value.text = RewardType.active.name.capitalize!.tr;
    rewardDistributionType.value.text =
        RewardDistributionType.email.name.capitalize!.tr;
    tokenNumber.value.text = "0";
    upperLimit.value.text = "0";
    maxNumberPerUser.value.text = "0";
    await fetchShops();
  }

  Future fetchShops() async {
    try {
      shops.value = await shopServiceApi.listAllShops(
        placeUid: _auth.currentUser!.uid,
      );
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future fetchRewards(String status) async {
    try {
      rewards.value = await api.fetchRewards(status: status);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void initRewardReceivers(String rewardUid) {
    rewardReceivers.value = Pagination<RewardReceiverModel>(
      fromJson: (json, id) => RewardReceiverModel.fromJson(json, id),
      query: _db
          .collection("rewards")
          .doc(rewardUid)
          .collection("reward_receivers")
          .orderBy('timestamp', descending: true),
    );
  }

  List<List<dynamic>> _prepareData() {
    List<List<dynamic>> rows = [];
    rows.add(["Email", "Token Transferred", "Timestamp"]);
    for (var rewardReceiver in rewardReceivers.value.results) {
      rows.add([
        rewardReceiver.email,
        rewardReceiver.tokenTransferred.toString(),
        dateString(rewardReceiver.timestamp)
      ]);
    }
    return rows;
  }

  void exportCSVRewardReceivers() {
    List<List<dynamic>> rows = _prepareData();
    String csvText = csv.encode(rows);
    web.HTMLAnchorElement()
      ..href = "data:text/csv;charset=utf-8,$csvText"
      ..setAttribute("download", "${DateTime.now().toLocal()}.csv")
      ..click();
  }

  Future fetchRewardReceivers() async {
    await rewardReceivers.value.fetch();
    rewardReceivers.refresh();
  }

  Future<void> initList() async {
    clear();
    await fetchRewards(selectedStatus.value);
  }

  Future<void> initUpdate() async {
    clear();
    try {
      String uid = Get.parameters["rewardId"] as String;
      rewardToEdit = (await api.fetchRewardByUid(uid: uid))!;
      title.value.text = rewardToEdit.title;
      description.value.text = rewardToEdit.description;
      imageFile.value = PlatformFile(name: rewardToEdit.downloadUrl, size: 1);
      status.value.text = rewardToEdit.status.capitalizeFirst!.tr;
      selectedStatus.value = rewardToEdit.status;
      rewardDistributionType.value.text =
          rewardToEdit.rewardDistributionType.capitalizeFirst!.tr;
      selectedRewardDistributionType.value =
          rewardToEdit.rewardDistributionType;
      startTime.value = rewardToEdit.startTime;
      endTime.value = rewardToEdit.endTime;
      tokenNumber.value.text = rewardToEdit.tokenNumber.toString();
      upperLimit.value.text = rewardToEdit.upperLimit.toString();
      maxNumberPerUser.value.text = rewardToEdit.maxNumberPerUser.toString();
      await fetchShops();

      ShopModel? selectedShopTemp = shops
          .where((ShopModel shop) => shop.uid == rewardToEdit.couponShopUid)
          .firstOrNull;
      selectedShop.value = selectedShopTemp ?? emptyShopModel;
    } catch (e) {
      showToast("Invalid id");
    }
  }

  Future<List<String>> uploadFileForReward({required Uint8List file}) async {
    String url = "";
    String downloadUrl = "";
    try {
      final ref = FirebaseStorage.instance
          .ref("v1-media/rewards/${DateTime.now().toString()}.jpg");
      await ref.putData(file);
      downloadUrl = await ref.getDownloadURL();
      url = ref.fullPath;
      return [url, downloadUrl];
    } catch (e) {
      return [];
    }
  }

  Future onCreate() async {
    if (title.value.text.isEmpty |
        description.value.text.isEmpty |
        selectedStatus.value.isEmpty |
        imageFile.value.name.isEmpty |
        tokenNumber.value.text.isEmpty |
        upperLimit.value.text.isEmpty |
        maxNumberPerUser.value.text.isEmpty) {
      showToast("Add image file and other info.".tr);
      return;
    }
    if (isFile500KPlus(imageFile.value)) {
      showToast("Image file size can not be more than 500K".tr);
      return;
    }
    if (selectedRewardDistributionType.value ==
            RewardDistributionType.coupon.name &&
        selectedShop.value.uid == "") {
      showToast("Select shop for coupon".tr);
      return;
    }
    try {
      showLoading("Creating reward".tr);
      Uint8List image = imageFile.value.bytes as Uint8List;
      List<String> imageLinks = await uploadFileForReward(file: image);

      if (imageLinks.length != 2) {
        showDismiss();
        showToast("Could not upload file.".tr);
        return;
      }
      RewardModel reward = RewardModel(
        placeUid: _auth.currentUser!.uid,
        title: title.value.text,
        description: description.value.text,
        imageLink: imageLinks[0],
        downloadUrl: imageLinks[1],
        status: selectedStatus.value,
        rewardDistributionType: selectedRewardDistributionType.value,
        startTime: startTime.value,
        endTime: endTime.value,
        tokenNumber: int.parse(tokenNumber.value.text),
        maxNumberPerUser: int.parse(maxNumberPerUser.value.text),
        upperLimit: int.parse(upperLimit.value.text),
        couponShopUid: selectedShop.value.uid!,
        couponShopGeoHash: selectedShop.value.geoHash!,
      );
      await api.addReward(rewardObject: reward.toJson());
      clear();
      Get.offNamed("/rewards");
      showDismiss();
      showToast("Successfully created reward.".tr);
    } catch (e) {
      showDismiss();
      showToast("Failed to create reward!.".tr);
    }
  }

  Future onUpdate() async {
    if (title.value.text.isEmpty |
        description.value.text.isEmpty |
        selectedStatus.value.isEmpty |
        imageFile.value.name.isEmpty |
        tokenNumber.value.text.isEmpty |
        upperLimit.value.text.isEmpty |
        maxNumberPerUser.value.text.isEmpty) {
      showToast("Add image file and other info.".tr);
      return;
    }
    if (isFile500KPlus(imageFile.value)) {
      showToast("Image file size can not be more than 500K".tr);
      return;
    }
    if (selectedRewardDistributionType.value ==
            RewardDistributionType.coupon.name &&
        selectedShop.value.uid == "") {
      showToast("Select shop for coupon".tr);
      return;
    }
    try {
      showLoading("Updating reward".tr);
      String imageLink = rewardToEdit.imageLink;
      String downloadUrl = rewardToEdit.downloadUrl;
      if (!imageFile.value.name.startsWith("https://")) {
        Uint8List image = imageFile.value.bytes as Uint8List;
        List<String> imageLinks = await uploadFileForReward(file: image);

        if (imageLinks.length != 2) {
          showDismiss();
          showToast("Could not upload file.".tr);
          return;
        }
        imageLink = imageLinks[0];
        downloadUrl = imageLinks[1];
      }

      RewardModel reward = RewardModel(
        placeUid: _auth.currentUser!.uid,
        title: title.value.text,
        description: description.value.text,
        imageLink: imageLink,
        downloadUrl: downloadUrl,
        status: selectedStatus.value,
        rewardDistributionType: selectedRewardDistributionType.value,
        startTime: startTime.value,
        endTime: endTime.value,
        tokenNumber: int.parse(tokenNumber.value.text),
        upperLimit: int.parse(upperLimit.value.text),
        maxNumberPerUser: int.parse(maxNumberPerUser.value.text),
        couponShopUid: selectedShop.value.uid!,
        couponShopGeoHash: selectedShop.value.geoHash!,
      );
      await api.updateReward(
        rewardObject: reward.toJson(),
        uid: rewardToEdit.uid as String,
      );
      showDismiss();
      showToast("Successfully updated reward.".tr);
    } catch (e) {
      if (kDebugMode) print(e);
      showDismiss();
      showToast("Failed to update reward!.".tr);
    }
  }

  void clear() {
    shops.clear();
    selectedShop.value = emptyShopModel;
    rewards.clear();
    title.value.clear();
    description.value.clear();
    status.value.text = RewardType.active.name.capitalize!;
    imageFile.value = PlatformFile(name: "", size: 0);
    startTime.value = DateTime.now();
    endTime.value = DateTime.now();
    selectedStatus.value = RewardType.active.name;
    selectedRewardDistributionType.value = RewardDistributionType.email.name;
    tokenNumber.value.clear();
    upperLimit.value.clear();
    maxNumberPerUser.value.clear();
    rewardDistributionType.value.clear();
  }

  @override
  void dispose() {
    title.value.dispose();
    description.value.dispose();
    status.value.dispose();
    tokenNumber.value.dispose();
    upperLimit.value.dispose();
    maxNumberPerUser.value.dispose();
    rewardDistributionType.value.dispose();
    super.dispose();
  }
}
