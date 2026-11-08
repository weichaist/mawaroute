import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../api/firestore_services.dart';
import '../models/shop_model.dart';
import '../models/user_visit_model.dart';
import '../utils/enums.dart';
import 'auth_controller.dart';

class VisitorListController extends GetxController {
  static VisitorListController instance = Get.find<VisitorListController>();
  FirebaseFunctions cloudFunction = FirebaseFunctions.instance;
  final FireStoreService api = FireStoreService();
  final authController = AuthController.instance;

  DocumentSnapshot? snapshot;
  RxBool isLastPage = false.obs;
  RxList<UserVisitModel> visitors = <UserVisitModel>[].obs;
  Rx<ShopModel> shop = emptyShopModel.obs;
  final salesAssistant = ''.obs;
  Rx<String> timeframe = Timeframe.today.name.obs;

  Future<void> init() async {
    clear();
    timeframe.value = Get.parameters["timeframe"]!;
    await authController.fetchShop();
    shop.value = authController.shop.value;
    await fetchShopVisitor();
  }

  Future fetchShopVisitor() async {
    EasyLoading.show(status: "Loading");
    const limit = 15;
    Map<dynamic, dynamic> output = await api.fetchShopVisits(
      limit: limit,
      snapshot: snapshot,
      shopUid: shop.value.uid,
      timeframe: timeframe.value,
    );
    List<UserVisitModel> result = output["results"];
    visitors.value += result;
    snapshot = output["snapshot"];
    isLastPage.value = result.length < limit;
    EasyLoading.dismiss();
  }

  Future<void> fetchVisitorPreferenceSuggestions() async {
    try {
      HttpsCallable descriptionToTags =
          cloudFunction.httpsCallable('FindCompatibilityBetweenUserAndShop');
      final result = await descriptionToTags.call({
        "userTags":
            'American casual style, matcha offerings, attention to detail, relaxing environment, boutique fashion, traditional arts, eco-friendly products, contemplative environment, natural light, ethical sourcing, patient instructors, modern interpretations, engaging conversation, dark roast, brewing techniques, creative spaces, skilled baristas, well-lit space, unique blends, curated selection, warm and inviting, peaceful ambiance, well-organized spaces, artistic talents, cultural experiences, urban exploration, minimalistic design',
        'shopDescription':
            "This place boasts a consistently interesting atmosphere and top-notch customer service. The product selection is thoughtfully curated and the staff are knowledgeable about the brands and materials they carry. They strike the perfect balance between providing helpful advice without being pushy. The store is perfect for those who appreciate trendy, American casual fashion. Customers may unintentionally find themselves making purchases thanks to the compelling merchandise, but the experience is well worth it.",
        'language': 'Japanese'
      });
      salesAssistant.value = result.data.toString().trim();
    } catch (e) {
      debugPrint("$e");
      salesAssistant.value = 'Error';
    }
  }

  void clear() {
    snapshot = null;
    isLastPage.value = false;
    visitors.value = [];
    timeframe.value = Timeframe.today.name;
  }
}
