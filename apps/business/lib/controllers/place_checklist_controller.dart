import 'package:get/get.dart';

import '../api/google_firestore_services.dart';
import '../api/shop_service.dart';
import '../models/place_model.dart';
import '../utility.dart';

class PlaceCheckListController extends GetxController {
  static PlaceCheckListController instance =
      Get.find<PlaceCheckListController>();
  Rx<PlaceModel> place = emptyPlaceModel.obs;
  RxBool firstCampaign = false.obs;
  RxBool has10Shops = false.obs;
  FireStoreService api = FireStoreService();
  ShopService shopApi = ShopService();

  Future<void> init() async {
    clear();
    place.value = await api.fetchPlace();
    String placeUid = place.value.uid!;
    if (placeUid.isNotEmpty) {
      int count = await api.fetchCampaignByPlaceUid(placeUid: placeUid);
      firstCampaign.value = count > 0;
      count = await shopApi.numberOfShops(placeUid: placeUid);
      has10Shops.value = count > 10;
    }
  }

  Future makePlacePublic() async {
    if (place.value.name.isEmpty |
        place.value.address.isEmpty |
        place.value.profileUrl.isEmpty |
        place.value.downloadUrl.isEmpty |
        (firstCampaign.isFalse && has10Shops.isFalse)) {
      showError('Condition not satisfied to make campaign public'.tr);
      return;
    }

    try {
      showLoading('Making place public'.tr);
      await api.makePlacePublic();
      showSuccess('Successfully made place public.'.tr);
    } catch (e) {
      showError('Failed to make place public!.'.tr);
    } finally {
      showDismiss();
    }
  }

  void clear() {
    place.value = emptyPlaceModel;
    firstCampaign.value = false;
    has10Shops.value = false;
  }
}
