import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/admin_controller.dart';
import 'package:mawaroute_shop/theme/size_config.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../models/google_map_model.dart';
import '../../theme/constants.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = AdminController.instance;
    return PopScope(
      canPop: false,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Admin Mode'),
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                CupertinoIcons.arrow_merge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ListTile(
                  title: ElevatedButton.icon(
                    icon: const Text(
                      '📸',
                      style: TextStyle(fontSize: 18),
                    ),
                    label: const Text('Open Camera'),
                    onPressed: () async {
                      final List<AssetEntity>? result =
                          await AssetPicker.pickAssets(
                        context,
                        pickerConfig: const AssetPickerConfig(
                            maxAssets: 10,
                            themeColor: kPrimaryColor,
                            requestType: RequestType.image),
                      );
                      if (result != null) {
                        List<AssetEntity> resultForCheck = [];
                        for (AssetEntity imageFile in result) {
                          if (imageFile.latitude == 0 &&
                              imageFile.longitude == 0) {
                            EasyLoading.showToast(
                              'Image without geo info cannot be uploaded'.tr,
                              toastPosition: EasyLoadingToastPosition.bottom,
                            );
                          } else {
                            resultForCheck.add(imageFile);
                          }
                        }
                        adminController.selectedImages.value = resultForCheck;
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text(
                    'Email',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: TextField(
                    controller: adminController.emailController.value,
                  ),
                ),
                ListTile(
                  title: const Text(
                    'Place UID',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: TextField(
                    controller: adminController.placeController.value,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: kDefaultPadding / 2,
                      right: kDefaultPadding / 2,
                      top: kDefaultPadding / 2),
                  width: getScreenWidth(),
                  height: getScreenWidth(),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ListTile(
                  title: ElevatedButton.icon(
                    icon: const Text(
                      '👀',
                      style: TextStyle(fontSize: 18),
                    ),
                    label: const Text('Search Place with Google API'),
                    onPressed: () {
                      Get.bottomSheet(
                        const BottomSheetList(),
                        backgroundColor: kPrimaryContainerColor,
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(9.0),
                  child: Card(
                    child: ListTile(
                      title: Text('Response'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSheetList extends StatefulWidget {
  const BottomSheetList({super.key});

  @override
  State<BottomSheetList> createState() => _BottomSheetListState();
}

class _BottomSheetListState extends State<BottomSheetList> {
  TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminController = AdminController.instance;
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
                  adminController.places.clear();
                },
              ),
            ),
            onSubmitted: (value) async {
              await adminController.callPlaceApi(value);
            },
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: Obx(
            () => ListView.builder(
                itemCount: adminController.places.length,
                padding: const EdgeInsets.only(
                  top: kDefaultPadding,
                  bottom: 240,
                ),
                itemBuilder: (context, index) {
                  List<GoogleMap> items = adminController.places;
                  return GestureDetector(
                    onTap: () async {
                      adminController.selectedIndex.value = index;
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
                                  adminController.selectedIndex.value == index
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
                int index = adminController.selectedIndex.value;
                if (index < 0) {
                  EasyLoading.dismiss();
                  SmartDialog.showNotify(
                      msg: 'Select your shop to continue'.tr,
                      notifyType: NotifyType.alert);
                  return;
                }
                adminController.selectedPlace = adminController.places[index];
                await adminController.createShop();
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
