import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../api/google_firestore_services.dart';
import '../models/app_info_model.dart';
import '../models/m_avatar_model.dart';
import '../utilis/pagination.dart';

class AICharacterListController extends GetxController {
  static AICharacterListController instance =
      Get.find<AICharacterListController>();

  final _db = FirebaseFirestore.instance;
  FirestoreService f = FirestoreService();
  RxList<MAvatarModel> characters = <MAvatarModel>[].obs;
  String placeUid = "";
  RxBool isLoading = false.obs;

  final isAppUpToDate = true.obs;
  final Rx<AppInfoModel> appInfo = emptyAppInfo.obs;

  late Query<Map<String, dynamic>> queryForDisplay;

  final List<String> filterChips = ['All', 'Shopping', 'Sightseeing'];
  final RxInt selectedChip = 0.obs;
  Pagination<MAvatarModel> all = Pagination<MAvatarModel>(
    query: null,
    fromJson: null,
  );
  Pagination<MAvatarModel> shopping = Pagination<MAvatarModel>(
    query: null,
    fromJson: null,
  );
  Pagination<MAvatarModel> sightseeing = Pagination<MAvatarModel>(
    query: null,
    fromJson: null,
  );

  Future<void> init() async {
    if (isLoading.value == true) return;
    await checkCurrentVersionIsUpToDate();
    isLoading.value = true;
    clear();
    all = Pagination(
      query: _db
          .collection('m_avatars')
          .where('invited', isEqualTo: true)
          .orderBy('knowledgePointCounter', descending: true),
      fromJson: (json, id) => MAvatarModel.fromJson(json, id),
    );
    shopping = Pagination(
      query: _db
          .collection('m_avatars')
          .where('filters', arrayContains: 'shopping')
          .orderBy('knowledgePointCounter', descending: true),
      fromJson: (json, id) => MAvatarModel.fromJson(json, id),
    );
    sightseeing = Pagination(
      query: _db
          .collection('m_avatars')
          .where('filters', arrayContains: 'sightseeing')
          .orderBy('knowledgePointCounter', descending: true),
      fromJson: (json, id) => MAvatarModel.fromJson(json, id),
    );
    await fetchData();
    isLoading.value = false;
  }

  Future<void> setValue(int index) async {
    selectedChip.value = index;
    List<MAvatarModel> list = [];
    if (index == 0) {
      list = all.results;
    } else if (index == 1) {
      list = shopping.results;
    } else {
      list = sightseeing.results;
    }
    characters.value = list;
    characters.refresh();
  }

  Future<void> fetchData() async {
    if (selectedChip.value == 0) {
      await all.fetch();
    } else if (selectedChip.value == 1) {
      await shopping.fetch();
    } else {
      await sightseeing.fetch();
    }
    setValue(selectedChip.value);
  }

  Future<void> addMore() async {
    if (isLoading.isTrue) return;
    isLoading.value = true;
    await fetchData();
    isLoading.value = false;
  }

  Future<void> checkCurrentVersionIsUpToDate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    try {
      appInfo.value = await f.getAppInfo();
    } catch (e) {
      if (kDebugMode) print(e);
    }
    if (version.compareTo(appInfo.value.version) == 0) {
      return;
    } else if (version.compareTo(appInfo.value.version) < 0) {
      isAppUpToDate.value = false;
    } else {
      return;
    }
  }

  void clear() {
    selectedChip.value = 0;
    all = Pagination<MAvatarModel>(query: null, fromJson: null);
    shopping = Pagination<MAvatarModel>(query: null, fromJson: null);
    sightseeing = Pagination<MAvatarModel>(query: null, fromJson: null);
  }
}
