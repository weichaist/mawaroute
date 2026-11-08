import "package:cloud_firestore/cloud_firestore.dart";
import "package:cloud_functions/cloud_functions.dart";
import "package:file_picker/file_picker.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../api/google_firestore_services.dart";
import "../api/shop_service.dart";
import "../enums.dart";
import "../models/campaign_model.dart";
import "../models/campaign_task_image_model.dart";
import "../models/campaign_task_model.dart";
import "../models/shop_model.dart";
import "../pagination.dart";
import "../utility.dart";

class EditCampaignV2Controller extends GetxController {
  static EditCampaignV2Controller instance =
      Get.find<EditCampaignV2Controller>();
  Rx<CampaignModel> campaignToEdit = emptyCampaignModel.obs;

  final FireStoreService api = FireStoreService();
  final ShopService shopApi = ShopService();

  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Rx<TextEditingController> title = TextEditingController().obs;
  Rx<TextEditingController> description = TextEditingController().obs;
  Rx<TextEditingController> rule = TextEditingController().obs;
  Rx<DateTime> startTime = DateTime.now().obs;
  Rx<TextEditingController> campaignTimeLimit = TextEditingController().obs;
  Rx<TextEditingController> maximumTaskNumber = TextEditingController().obs;
  RxList<CampaignModel> campaigns = <CampaignModel>[].obs;
  late final bannerImageFile = PlatformFile(name: "", size: 0).obs;
  late final imageFile = PlatformFile(name: "", size: 0).obs;
  Rx<TextEditingController> taskType =
      TextEditingController(text: TaskType.imageMatching.name).obs;
  Rx<TextEditingController> targetUser =
      TextEditingController(text: TargetUser.allCustomer.name).obs;
  RxString selectedTargetUser = "All customers".obs;
  Rx<TextEditingController> targetUserText =
      TextEditingController(text: targetUserString[TargetUser.allCustomer.name])
          .obs;

  // For Element List
  RxList<CampaignTaskModel> campaignTasks = <CampaignTaskModel>[].obs;

  Rx<Pagination<CampaignTaskImageModel>> campaignTaskImages =
      Pagination<CampaignTaskImageModel>(fromJson: null, query: null).obs;
  Rx<Pagination<CampaignTaskImageModel>> shopImages =
      Pagination<CampaignTaskImageModel>(fromJson: null, query: null).obs;
  // For storing data
  Rx<Pagination<ShopModel>> shops =
      Pagination<ShopModel>(fromJson: null, query: null).obs;

  RxInt selectedTab = 0.obs;
  RxString uid = "".obs;
  CampaignTaskImageModel? selectedTaskImage;

  // For task edit dialog
  Rx<TextEditingController> hintTextController = TextEditingController().obs;
  Rx<TextEditingController> latController = TextEditingController().obs;
  Rx<TextEditingController> lngController = TextEditingController().obs;
  late final campaignTaskFile = PlatformFile(name: "", size: 0).obs;

  // Flag for tabs
  RxBool basicInfoFlag = false.obs;
  RxBool imageInfoFlag = false.obs;
  RxBool targetUerGroupInfo = false.obs;
  RxBool tasksListInfo = false.obs;
  RxInt completedTaskFlagCount = 0.obs;

  Future init() async {
    uid.value = Get.parameters["campaignId"] as String;
    selectedTab.value = 0;
    campaignTasks.clear();
    await fetchCampaign();
    await fetchCampaignTaskImages(init: true);
    await fetchShopImages(init: true);
  }

  void updateFlagInfo() {
    completedTaskFlagCount.value = 0;
    basicInfoFlag.value = campaignToEdit.value.title.isNotEmpty &&
        campaignToEdit.value.description.isNotEmpty;
    imageInfoFlag.value = campaignToEdit.value.downloadUrl.isNotEmpty;
    targetUerGroupInfo.value = campaignToEdit.value.targetUser.isNotEmpty;
    tasksListInfo.value = campaignToEdit.value.taskCount != 0;

    if (basicInfoFlag.isTrue) {
      completedTaskFlagCount++;
    }
    if (imageInfoFlag.isTrue) {
      completedTaskFlagCount++;
    }
    if (targetUerGroupInfo.isTrue) {
      completedTaskFlagCount++;
    }
    if (tasksListInfo.isTrue) {
      completedTaskFlagCount++;
    }
  }

  void setCampaignTaskForEditing(int index) {
    CampaignTaskModel oldTask = campaignTasks[index];
    hintTextController.value.text = oldTask.description;
    latController.value.text = oldTask.lat.toString();
    lngController.value.text = oldTask.lng.toString();
    String name = oldTask.downloadUrl!;
    if (oldTask.image != null) {
      campaignTaskFile.value = oldTask.image!;
    } else if (name != "") {
      campaignTaskFile.value = PlatformFile(name: name, size: 1);
    }
  }

  void clearCampaignTaskImageSelection() {
    latController.value.clear();
    lngController.value.clear();
    selectedTaskImage = null;
  }

  void clearCampaignTaskForEditing() {
    clearCampaignTaskImageSelection();
    hintTextController.value.clear();
    campaignTaskFile.value = PlatformFile(name: "", size: 0);
  }

  void removeCampaignTask(int index) {
    campaignTasks.removeAt(index);
    campaignTasks.refresh();
    Get.back();
  }

  void updateCampaignTaskImage({int? index}) {
    if (hintTextController.value.text.isNotEmpty &&
        latController.value.text.isNotEmpty &&
        lngController.value.text.isNotEmpty &&
        campaignTaskFile.value.name.isNotEmpty) {
      double newLat = latController.value.text != ""
          ? double.parse(latController.value.text)
          : double.nan;
      double newLng = lngController.value.text != ""
          ? double.parse(lngController.value.text)
          : double.nan;
      PlatformFile? image = campaignTaskFile.value;
      if (isFile500KPlus(campaignTaskFile.value)) {
        showToast("Image file size can not be more than 500K");
        return;
      }
      CampaignTaskModel newTask = CampaignTaskModel(
        description: hintTextController.value.text,
        lat: newLat,
        lng: newLng,
        imageLink:
            selectedTaskImage != null ? selectedTaskImage!.imageLink : "",
        downloadUrl:
            selectedTaskImage != null ? selectedTaskImage!.downloadUrl : "",
        image: image,
        index: campaignTasks.length,
        shopUid: selectedTaskImage!.shopUid,
      );
      if (index != null) {
        campaignTasks[index] = newTask;
      } else {
        campaignTasks.add(newTask);
      }
      Get.back();
    } else {
      showToast("Fill all required fields".tr);
    }
  }

  void selectTaskImageFromGallery(CampaignTaskImageModel taskImage) {
    latController.value.text = taskImage.lat.toString();
    lngController.value.text = taskImage.lng.toString();
    if (taskImage.shopUid!.isNotEmpty) {
      String shopName = shops.value.results
          .where((p0) => p0.uid == taskImage.shopUid)
          .first
          .name;
      hintTextController.value.text = shopName;
    }
    campaignTaskFile.value = PlatformFile(
      name: taskImage.downloadUrl,
      size: 1,
    );
    selectedTaskImage = taskImage;
  }

  void changeSelectedTargetUser(String text) {
    targetUserText.value.text = text;
    selectedTargetUser.value = text;
  }

  Future fetchCampaign() async {
    try {
      campaignToEdit.value = await api.fetchCampaignByUid(uid: uid.value);
      title.value.text = campaignToEdit.value.title;
      description.value.text = campaignToEdit.value.description;
      if (campaignToEdit.value.targetUser.isNotEmpty) {
        targetUser.value.text = campaignToEdit.value.targetUser;
      }
      if (campaignToEdit.value.downloadUrl != "") {
        imageFile.value =
            PlatformFile(name: campaignToEdit.value.downloadUrl, size: 1);
      } else {
        imageFile.value = PlatformFile(name: "", size: 0);
      }
      if (campaignToEdit.value.bannerDownloadUrl != "") {
        bannerImageFile.value =
            PlatformFile(name: campaignToEdit.value.bannerDownloadUrl, size: 1);
      } else {
        bannerImageFile.value = PlatformFile(name: "", size: 0);
      }
      startTime.value = campaignToEdit.value.startTime;
      campaignTimeLimit.value.text =
          intToString(num: campaignToEdit.value.campaignTimeLimit);
      maximumTaskNumber.value.text =
          intToString(num: campaignToEdit.value.maximumTaskNumber);
    } catch (e) {
      campaignToEdit.value = emptyCampaignModel;
    }
    try {
      campaignTasks.value = await api.fetchMyCampaignTasks(uid: uid.value);
    } catch (e) {
      campaignTasks.value = [];
    }
    updateFlagInfo();
  }

  Future fetchCampaignTaskImages({bool init = false}) async {
    if (init == true) {
      campaignTaskImages.value = Pagination<CampaignTaskImageModel>(
          fromJson: (json, id) => CampaignTaskImageModel.fromJson(json, id),
          query: _db
              .collection("campaign_task_images")
              .where("userUid", isEqualTo: _auth.currentUser!.uid)
              .orderBy('createdAt', descending: true));
    }
    await campaignTaskImages.value.fetch();
    campaignTaskImages.refresh();
  }

  Future fetchShopImages({bool init = false}) async {
    if (init == true) {
      shopImages.value =
          Pagination<CampaignTaskImageModel>(fromJson: null, query: null);
      shops.value = Pagination<ShopModel>(
        fromJson: (json, id) => ShopModel.fromJson(json, id),
        query: _db
            .collection('shops')
            .where('placeUid', isEqualTo: _auth.currentUser!.uid)
            .orderBy('createdAt', descending: true),
      );
    }
    await shops.value.fetch();
    shopImages.value.isLast = shops.value.isLast;
    shopImages.value.results = shops.value.results
        .map((result) => CampaignTaskImageModel(
              userUid: "",
              imageLink: result.imageLink!,
              downloadUrl: result.downloadUrl!,
              lat: result.lat!.toDouble(),
              lng: result.lng!.toDouble(),
              createdAt: result.createdAt,
              shopUid: result.uid,
            ))
        .toList();
    shopImages.refresh();
  }

  Future<List<String>> uploadFileForCampaign(
      {required PlatformFile file}) async {
    String url = "";
    String downloadUrl = "";
    try {
      final ref =
          storage.ref("v1-media/campaigns/${DateTime.now().toString()}.jpg");
      await ref.putData(file.bytes as Uint8List);
      downloadUrl = await ref.getDownloadURL();
      url = ref.fullPath;
      return [url, downloadUrl];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> uploadFileForCampaignTask(
      {required PlatformFile file}) async {
    String url = "";
    String downloadUrl = "";
    try {
      final ref = storage
          .ref("v1-media/campaign_tasks/${DateTime.now().toString()}.jpg");
      await ref.putData(file.bytes as Uint8List);
      downloadUrl = await ref.getDownloadURL();
      url = ref.fullPath;
      return [url, downloadUrl];
    } catch (e) {
      return [];
    }
  }

  Future onSaveBasicInfo() async {
    if (title.value.text.isEmpty | description.value.text.isEmpty) {
      showToast("Please add title, description, token cap and start time.".tr);
      return;
    }

    try {
      Map<String, dynamic> campaignModel = {
        "title": title.value.text,
        "description": description.value.text,
        "startTime": startTime.value,
        "campaignTimeLimit": stringToInt(text: campaignTimeLimit.value.text),
        "maximumTaskNumber": stringToInt(text: maximumTaskNumber.value.text),
      };
      await api.updateCampaign(uid: uid.value, campaignObject: campaignModel);
      showDismiss();
      showToast("Successfully updated campaign.".tr);
    } catch (e) {
      showError("Failed to update campaign!.".tr);
    }
  }

  Future onSaveTargetUserInfo() async {
    if (targetUser.value.text.isEmpty) {
      showToast("Select target User.");
      return;
    }
    try {
      Map<String, dynamic> campaignModel = {
        "targetUser": targetUser.value.text
      };
      await api.updateCampaign(uid: uid.value, campaignObject: campaignModel);
      showDismiss();
      showToast("Successfully updated campaign.".tr);
    } catch (e) {
      showToast("Failed to update campaign!.".tr);
    }
  }

  Future onSaveImageInfo() async {
    Map<String, dynamic> campaignModel = {};
    if (imageFile.value.name.isEmpty) {
      showToast("Add image file.");
      return;
    }
    if (isFile500KPlus(imageFile.value)) {
      showToast("Image file size can not be more than 500K".tr);
      return;
    }
    if (isFile500KPlus(bannerImageFile.value)) {
      showToast("Image file size can not be more than 500K".tr);
      return;
    }

    showLoading("Updating campaign".tr);

    PlatformFile image = imageFile.value;
    if (shouldUploadImage(image.name)) {
      List<String> imageLinks = await uploadFileForCampaign(file: image);
      if (imageLinks.length != 2) {
        showDismiss();
        showToast("Could not upload image file.");
        return;
      }
      campaignModel["imageLink"] = imageLinks[0];
      campaignModel["downloadUrl"] = imageLinks[1];
    }

    PlatformFile bannerImage = bannerImageFile.value;
    if (shouldUploadImage(bannerImage.name)) {
      List<String> bannerImageLinks =
          await uploadFileForCampaign(file: bannerImage);
      if (bannerImageLinks.length != 2) {
        showDismiss();
        showToast("Could not upload image file.");
        return;
      }
      campaignModel["bannerImageLink"] = bannerImageLinks[0];
      campaignModel["bannerDownloadUrl"] = bannerImageLinks[1];
    } else {
      campaignModel["bannerImageLink"] = '';
      campaignModel["bannerDownloadUrl"] = '';
    }
    if (campaignModel.isNotEmpty) {
      try {
        await api.updateCampaign(uid: uid.value, campaignObject: campaignModel);
        showDismiss();
        showToast("Successfully updated campaign.".tr);
      } catch (e) {
        showToast("Failed to update campaign!.".tr);
      }
    }
  }

  Future<List<Map<String, dynamic>>> uploadCampaignTaskImages() async {
    List<Map<String, dynamic>> pElementSet = [];
    for (CampaignTaskModel campaignTask in campaignTasks) {
      pElementSet.add(campaignTask.toJson());
    }
    return pElementSet;
  }

  Future<Map<String, dynamic>> getGeoHash() async {
    double latSum = 0.0;
    double lngSum = 0.0;
    double? lat;
    double? lng;
    String? geoHash;
    if (campaignTasks.isNotEmpty) {
      for (CampaignTaskModel campaignTask in campaignTasks) {
        latSum += campaignTask.lat;
        lngSum += campaignTask.lng;
      }
      lat = latSum / campaignTasks.length;
      lng = lngSum / campaignTasks.length;
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable("GeoHash");
      final resp = await callable.call(<String, dynamic>{
        'lat': lat,
        'lng': lng,
      });
      geoHash = resp.data["hash"];
    }
    return {"lat": lat, "lng": lng, "geoHash": geoHash};
  }

  Future onSaveCampaignTaskInfo() async {
    if (campaignTasks.isEmpty) {
      showToast("Add some tasks".tr);
      return;
    }
    showLoading("Updating campaign".tr);
    try {
      Map<String, dynamic> center = await getGeoHash();
      List<Map<String, dynamic>> pElementSet = await uploadCampaignTaskImages();
      Map<String, dynamic> campaignModel = {
        "taskCount": pElementSet.length,
        "lat": center["lat"],
        "lng": center["lng"],
        "geoHash": center["geoHash"],
      };
      await api.updateCampaignTasks(
          uid: uid.value, campaignTasksObject: pElementSet);
      await api.updateCampaign(uid: uid.value, campaignObject: campaignModel);
      showDismiss();
      showToast("Successfully updated campaign.".tr);
    } catch (e) {
      if (kDebugMode) print(e);
      showToast("Failed to update campaign!.".tr);
      showDismiss();
    }
  }

  Future launchCampaign() async {
    try {
      if (completedTaskFlagCount.value == 4) {
        showLoading("Launching current campaign.".tr);
        Map<String, dynamic> campaignModel = {
          "status": CampaignStatus.active.name
        };
        await api.updateCampaign(uid: uid.value, campaignObject: campaignModel);
        showDismiss();
        showToast("Successfully launched the campaign.".tr);
      } else {
        showToast("Checklist is not complete".tr);
      }
    } catch (e) {
      showToast("Failed to launch the campaign!.".tr);
    }
  }

  Future undoLaunchCampaign() async {
    try {
      showLoading("Undo launch current campaign.".tr);
      Map<String, dynamic> campaignModel = {
        "status": CampaignStatus.draft.name
      };
      await api.updateCampaign(uid: uid.value, campaignObject: campaignModel);
      showDismiss();
      showToast("Undo launch the campaign.".tr);
    } catch (e) {
      showToast("Failed to undo launch the campaign!.".tr);
    }
  }

  Future saveCampaignForLater() async {
    try {
      showLoading("Saving the campaign for later".tr);
      Map<String, dynamic> campaignModel = {
        "title": title.value.text,
        "description": description.value.text,
        "targetUser": targetUser.value.text,
      };

      PlatformFile image = imageFile.value;
      if (shouldUploadImage(image.name)) {
        List<String> imageLinks = await uploadFileForCampaign(file: image);
        if (imageLinks.length != 2) {
          showDismiss();
          showToast("Could not upload file.".tr);
          return;
        }
        campaignModel["imageLink"] = imageLinks[0];
        campaignModel["downloadUrl"] = imageLinks[1];
      }

      PlatformFile bannerImage = bannerImageFile.value;
      if (shouldUploadImage(bannerImage.name)) {
        List<String> bannerImageLinks =
            await uploadFileForCampaign(file: bannerImage);
        if (bannerImageLinks.length != 2) {
          showDismiss();
          showToast("Could not upload file.".tr);
          return;
        }
        campaignModel["bannerImageLink"] = bannerImageLinks[0];
        campaignModel["bannerDownloadUrl"] = bannerImageLinks[1];
      }
      List<Map<String, dynamic>> pElementSet = await uploadCampaignTaskImages();
      campaignModel["taskCount"] = pElementSet.length;
      await api.updateCampaignTasks(
          uid: uid.value, campaignTasksObject: pElementSet);
      await api.updateCampaign(uid: uid.value, campaignObject: campaignModel);
      showDismiss();
      showToast("Successfully saved the campaign for later.".tr);
    } catch (e) {
      showDismiss();
      showToast("Failed saved the campaign for later!".tr);
    }
  }

  void changeImage(PlatformFile? file) async {
    imageFile.value = file!;
    imageFile.update((value) {
      value = file;
    });
  }

  void changeBannerImage(PlatformFile? file) async {
    bannerImageFile.value = file!;
    bannerImageFile.update((value) {
      value = file;
    });
  }

  //Functions for Tasks
  void moveTaskDownInOrder(int index) {
    if (campaignTasks.length != index + 1) {
      if (campaignTasks.length > 1) {
        final currentCampaign = campaignTasks.removeAt(index);
        campaignTasks.insert(index + 1, currentCampaign);
      }
    }
  }

  @override
  void dispose() {
    title.value.dispose();
    description.value.dispose();
    rule.value.dispose();
    taskType.value.dispose();
    targetUser.value.dispose();
    targetUserText.value.dispose();
    hintTextController.value.dispose();
    latController.value.dispose();
    lngController.value.dispose();
    campaignTimeLimit.value.dispose();
    maximumTaskNumber.value.dispose();
    super.dispose();
  }
}
