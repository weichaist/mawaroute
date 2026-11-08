import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../api/google_firestore_services.dart';

class TokenHolder {
  final String title;
  final String username;
  final String url;
  final int tokenNumber;

  TokenHolder({
    required this.title,
    required this.username,
    required this.url,
    required this.tokenNumber,
  });
}

class TopTokenHolderScreenController extends GetxController {
  static TopTokenHolderScreenController instance =
      Get.find<TopTokenHolderScreenController>();
  FireStoreService api = FireStoreService();

  RxList<TokenHolder> tokenHolders = <TokenHolder>[].obs;
  final isLoading = false.obs;

  Future<void> init() async {
    tokenHolders.clear();
    await fetchTop30TokenHolder();
    sortTokenHolders();
  }

  void sortTokenHolders() {
    tokenHolders.sort(
      (a, b) => b.tokenNumber.compareTo(a.tokenNumber),
    );
  }

  Future fetchTop30TokenHolder() async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable("GetTopGGMTHolders");
    final resp = await callable.call();
    List topHolders = resp.data;
    Map initialData = {};
    List<String> addressList = [];
    for (var topHolder in topHolders) {
      String address = topHolder["address"].toString().toLowerCase();
      initialData[address] = topHolder["value"];
      addressList.add(address);
    }
    Map finalData =
        await api.getProfileFromPublicAddress(addresses: addressList);

    try {
      List<TokenHolder> list = [];
      finalData.forEach((key, value) {
        list.add(TokenHolder(
          title: key,
          username: value['username'],
          url: value['image'].contains('.svg?')
              ? '' // SVG avatars can't be drawn by NetworkImage; show no image.
              : value['image'],
          tokenNumber: int.parse(initialData[key]),
        ));
      });
      tokenHolders.value = list;
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}
