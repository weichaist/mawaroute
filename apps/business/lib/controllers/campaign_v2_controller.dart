import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/google_firestore_services.dart';
import '../enums.dart';
import '../models/campaign_model.dart';

class CampaignV2Controller extends GetxController {
  static CampaignV2Controller instance = Get.find<CampaignV2Controller>();

  RxList<CampaignModel> myCampaigns = <CampaignModel>[].obs;
  RxList<CampaignModel> activeCampaigns = <CampaignModel>[].obs;
  RxList<CampaignModel> recentlyCompletedCampaigns = <CampaignModel>[].obs;
  RxString selectedStatus = CampaignStatus.active.name.obs;
  FireStoreService api = FireStoreService();

  Future init() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      clear();
      selectedStatus.value = CampaignStatus.active.name;
      await fetchMyCampaigns(selectedStatus.value);
      await fetchActiveCampaigns();
      await fetchRecentlyCompletedCampaigns();
    });
  }

  Future fetchMyCampaigns(String status) async {
    try {
      myCampaigns.value = await api.fetchMyCampaigns(status: status);
    } catch (e) {
      myCampaigns.value = [];
    }
  }

  Future fetchActiveCampaigns() async {
    try {
      activeCampaigns.value = await api.fetchActiveCampaigns();
    } catch (e) {
      activeCampaigns.value = [];
    }
  }

  Future fetchRecentlyCompletedCampaigns() async {
    try {
      recentlyCompletedCampaigns.value = await api.fetchCompletedCampaigns();
    } catch (e) {
      recentlyCompletedCampaigns.value = [];
    }
  }

  void clear() {
    myCampaigns.value = [];
    activeCampaigns.value = [];
    recentlyCompletedCampaigns.value = [];
    selectedStatus.value = CampaignStatus.active.name;
  }
}
