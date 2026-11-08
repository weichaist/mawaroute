import 'package:get/get.dart';
import 'package:mawaroute_shop/api/firestore_services.dart';
import 'package:mawaroute_shop/models/shop_model.dart';

import 'auth_controller.dart';

class DashBoardController extends GetxController {
  static DashBoardController instance = Get.find<DashBoardController>();
  final api = FireStoreService();
  final RxInt audienceSize = 250.obs;
  final RxInt visitsToday = 0.obs;
  final RxInt purchasesToday = 0.obs;
  final RxInt visitsThisMonth = 0.obs;
  final RxInt purchasesThisMonth = 0.obs;
  final RxInt credits = 10000.obs;
  final authController = AuthController.instance;
  Rx<ShopModel> shop = emptyShopModel.obs;

  Future<void> init() async {
    await authController.fetchShop();
    shop.value = authController.shop.value;
    credits.value = shop.value.creditBalance.toInt();
    visitsToday.value =
        await api.fetchShopVisitCountByDay(shopUid: shop.value.uid!);
    purchasesToday.value =
        await api.fetchShopPurchasesCountByDay(shopUid: shop.value.uid!);
    visitsThisMonth.value =
        await api.fetchShopVisitsCountByMonth(shopUid: shop.value.uid!);
    purchasesThisMonth.value =
        await api.fetchShopPurchasesCountByMonth(shopUid: shop.value.uid!);
  }

  Future<void> changeIsLive(bool confirmed) async {
    if (!shop.value.isLive) {
      await api
          .updateShop(shopUid: shop.value.uid!, shopInfo: {"isLive": true});
      await authController.fetchShop();
      shop.value = authController.shop.value;
    } else {
      if (confirmed) {
        await api
            .updateShop(shopUid: shop.value.uid!, shopInfo: {"isLive": false});
        await authController.fetchShop();
        shop.value = authController.shop.value;
      }
    }
  }
}
