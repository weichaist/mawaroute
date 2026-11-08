import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/theme/constants.dart';
import 'package:mawaroute_shop/theme/size_config.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/shop_image_model.dart';

class SetSpotPhotoScreen extends StatelessWidget {
  const SetSpotPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = HomeController.instance;
    final auth = AuthController.instance;
    c.initList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Image.asset(
              'assets/images/mawaroute_text.png',
              height: 24,
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.viewfinder_circle,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  minLeadingWidth: 3,
                  leading: const Icon(
                    CupertinoIcons.photo,
                    size: 15,
                    color: kPrimaryColor,
                  ),
                  title: AutoSizeText(
                    'Spot image for まわる to earn campaigns'.tr,
                    maxLines: 1,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: kDefaultPadding / 2,
                      right: kDefaultPadding / 2,
                      top: kDefaultPadding / 2),
                  width: getScreenWidth(),
                  height: getScreenWidth(),
                  child: Obx(
                    () => Card(
                      child: auth.shop.value.downloadUrl!.isNotEmpty
                          ? Image.network(auth.shop.value.downloadUrl!)
                          : const SizedBox(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(
                  left: kDefaultPadding / 2,
                  right: kDefaultPadding / 2,
                  top: kDefaultPadding / 2),
              child: Card(
                child: ListTile(
                  title: TextButton.icon(
                    onPressed: () {
                      SmartDialog.show(
                        clickMaskDismiss: false,
                        builder: (context) => Container(
                          height: getScreenWidth() * 1.618,
                          margin: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding / 2,
                          ),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: kPrimaryContainerColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: kDefaultPadding,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Select from library'.tr),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        SmartDialog.dismiss();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: GridView.builder(
                                  padding: const EdgeInsets.only(
                                    left: kDefaultPadding / 2,
                                    right: kDefaultPadding / 2,
                                    top: kDefaultPadding / 2,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3 / 4,
                                    crossAxisSpacing: 9,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    ShopImageModel shopImage =
                                        c.shopImagesList[index];
                                    return GestureDetector(
                                      onTap: () async {
                                        if (!context.mounted) return;
                                        EasyLoading.show();
                                        await auth.updateShopSpotImage(
                                          downloadUrl: shopImage.downloadUrl,
                                          imageLink: shopImage.imageLink,
                                        );
                                        EasyLoading.dismiss();
                                        SmartDialog.dismiss();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.white,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: ExtendedImage.network(
                                            shopImage.downloadUrl,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: c.shopImagesList.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      // Get.dialog(
                      //   AlertDialog(
                      //     title: const Text("Select Image"),
                      //     content: Container(
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: kDefaultPadding,
                      //       ),
                      //       height: 300,
                      //       width: double.maxFinite,
                      //       child: ListView.builder(
                      //         itemBuilder: (BuildContext context, int index) {
                      //           ShopImageModel shopImage =
                      //               c.shopImagesList[index];
                      //           return GestureDetector(
                      //               onTap: () async {
                      //                 if (!context.mounted) return;
                      //                 await auth.updateShopSpotImage(
                      //                   downloadUrl: shopImage.downloadUrl,
                      //                   imageLink: shopImage.imageLink,
                      //                 );
                      //                 Get.back();
                      //               },
                      //               child:
                      //                   Image.network(shopImage.downloadUrl));
                      //         },
                      //         itemCount: c.shopImagesList.length,
                      //       ),
                      //     ),
                      //     actions: [
                      //       TextButton(
                      //         onPressed: () {
                      //           Get.back();
                      //         },
                      //         child: const Text("Close"),
                      //       ),
                      //     ],
                      //   ),
                      // );
                    },
                    icon: const Icon(CupertinoIcons.photo_on_rectangle),
                    label: Text(
                      'Select from library'.tr,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
