import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/auth_controller.dart';
import 'package:mawaroute_shop/models/google_map_model.dart';
import 'package:mawaroute_shop/theme/constants.dart';

class SearchPlaceBottomSheetList extends StatefulWidget {
  const SearchPlaceBottomSheetList({super.key});

  @override
  State<SearchPlaceBottomSheetList> createState() =>
      _SearchPlaceBottomSheetListState();
}

class _SearchPlaceBottomSheetListState
    extends State<SearchPlaceBottomSheetList> {
  TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search'.tr,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  auth.places.clear();
                },
              ),
            ),
            onSubmitted: (value) async {
              await auth.callPlaceApi(value);
            },
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: Obx(
            () => ListView.builder(
                itemCount: auth.places.length,
                padding: const EdgeInsets.only(
                  top: kDefaultPadding,
                  bottom: 240,
                ),
                itemBuilder: (context, index) {
                  List<GoogleMap> items = auth.places;
                  return GestureDetector(
                    onTap: () async {
                      auth.selectedIndex.value = index;
                    },
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(items[index].name),
                          subtitle: Text(items[index].formattedAddress),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Obx(
                                () => Icon(
                                  auth.selectedIndex.value == index
                                      ? Icons.check_circle_outline
                                      : Icons.circle_outlined,
                                  color: kPrimaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                }),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                EasyLoading.show(status: 'Configuring...'.tr);
                int index = auth.selectedIndex.value;
                if (index < 0) {
                  EasyLoading.dismiss();
                  SmartDialog.showNotify(
                      msg: 'Select your shop to continue'.tr,
                      notifyType: NotifyType.alert);
                  return;
                }
                GoogleMap place = auth.places[index];
                await auth.updateShopInfoGps(place: place);
                EasyLoading.dismiss();
                Get.back();
              },
              child: Text("Save".tr),
            ),
          ),
        ),
      ],
    );
  }
}
