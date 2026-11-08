import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/auth_controller.dart';
import 'package:mawaroute_shop/theme/constants.dart';
import 'package:mawaroute_shop/theme/size_config.dart';

import '../top_level_components/search_place_bottom_sheet.dart';
import 'edit_single_field_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    auth.initMyAccount();
    return CustomScrollView(
      slivers: [
        Obx(
          () => SliverAppBar.medium(
            automaticallyImplyLeading: false,
            centerTitle: false,
            leading:
                const Icon(CupertinoIcons.person_crop_circle_badge_checkmark),
            title: AutoSizeText(
              auth.place.value.name,
              maxLines: 1,
              style: const TextStyle(color: kPrimaryColor),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 9.0),
                child: OutlinedButton(
                  onPressed: () {
                    buildSignOutDialog(auth);
                  },
                  child: const Icon(Icons.exit_to_app),
                ),
              )
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultPadding, vertical: kDefaultPadding),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: kPrimaryContainerColor,
                    backgroundImage: auth.place.value.profileUrl.isNotEmpty
                        ? NetworkImage(auth.place.value.profileUrl)
                        : null,
                  ),
                ),
                // ListTile(
                //   title: Text(
                //     auth.place.value.address,
                //   ),
                // ),
                // auth.place.value.downloadUrl.isNotEmpty
                //     ? Image.network(auth.place.value.downloadUrl)
                //     : const SizedBox(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: kDefaultPadding * 3),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const Divider(
                  color: kPrimaryContainerColor,
                ),
                ListTile(
                  title: ElevatedButton.icon(
                    onPressed: () {
                      Get.bottomSheet(
                        const SearchPlaceBottomSheetList(),
                        backgroundColor: kPrimaryContainerColor,
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: Text('Search for your shop'.tr),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    'Name'.tr,
                    style: const TextStyle(color: kPrimaryColor),
                  ),
                ),
                Obx(
                  () => ListTile(
                    title: Text(auth.shop.value.name),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    'Address'.tr,
                    style: const TextStyle(color: kPrimaryColor),
                  ),
                ),
                Obx(
                  () => ListTile(
                    title: Text(auth.shop.value.address),
                  ),
                ),
                const Divider(
                  color: kPrimaryContainerColor,
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    'ULR for marketing'.tr,
                    style: const TextStyle(color: kPrimaryColor),
                  ),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.pencil_ellipsis_rectangle),
                    onPressed: () async {
                      String? res = await Get.to(
                          () => const EditSingleFieldScreen(),
                          arguments: {
                            "fieldName": "Marketing URL",
                            "fieldValue": auth.shop.value.homepageLink,
                          });
                      if (res != null) {
                        await auth.updateHomepageLink(fieldValue: res);
                      }
                    },
                  ),
                ),
                Obx(
                  () => ListTile(
                    title: Text(auth.shop.value.homepageLink),
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    'About the Shop'.tr,
                    style: const TextStyle(color: kPrimaryColor),
                  ),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.pencil_ellipsis_rectangle),
                    onPressed: () async {
                      String? res = await Get.to(
                          () => const EditSingleFieldScreen(),
                          arguments: {
                            "fieldName": "Shop Description",
                            "fieldValue": auth.shop.value.userDescription,
                          });
                      if (res != null) {
                        EasyLoading.show();
                        await auth.updateUserDescription(description: res);
                        EasyLoading.dismiss();
                      }
                    },
                  ),
                ),
                Obx(
                  () => ListTile(
                    title: Text(
                      auth.shop.value.userDescription,
                      // maxLines: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const Divider(
                color: kPrimaryContainerColor,
              ),
              ListTile(
                dense: true,
                title: Text(
                  'Beta Features'.tr,
                  style: const TextStyle(color: kPrimaryColor),
                ),
              ),
              ListTile(
                title: Text('Token number for purchasing'.tr),
                subtitle:
                    Text('Reward extra tokens to users who make purchases'.tr),
              ),
              const ListTile(
                title: PurchaseRewardSlider(),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<dynamic> buildSignOutDialog(AuthController auth) {
    return SmartDialog.show(
      builder: (context) {
        return Container(
          width: getScreenWidth() - kDefaultPadding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Center(
                  child: Text(
                    'Confirm sign out?'.tr,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: ElevatedButton(
                        child: AutoSizeText(
                          'Sign out'.tr,
                          maxLines: 1,
                        ),
                        onPressed: () async {
                          await auth.signOut();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: OutlinedButton(
                        child: Text('Cancel'.tr),
                        onPressed: () {
                          SmartDialog.dismiss();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class PurchaseRewardSlider extends StatefulWidget {
  const PurchaseRewardSlider({super.key});

  @override
  State<StatefulWidget> createState() => _PurchaseRewardSliderState();
}

class _PurchaseRewardSliderState extends State<PurchaseRewardSlider> {
  double _currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    return Column(
      children: [
        CupertinoSlider(
          value: _currentSliderValue,
          min: 0,
          max: 30,
          divisions:
              29, // As there are 28 steps between 2 and 30 (both inclusive)
          onChanged: (double value) {
            setState(() {
              _currentSliderValue = value;
            });
          },
          onChangeEnd: (double value) async {
            await auth.updatePurchaseTokenReward(fieldValue: value.toInt());
          },
        ),
        ListTile(
          title: Center(
            child: Text(
              _currentSliderValue.round().toString(),
              style: const TextStyle(
                fontSize: 18,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
