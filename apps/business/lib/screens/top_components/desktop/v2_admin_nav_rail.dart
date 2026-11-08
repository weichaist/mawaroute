import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/home_controller.dart';
import 'package:mawaroute_business/theme/constants.dart';

class V2AdminNavRail extends StatelessWidget {
  const V2AdminNavRail({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = HomeController.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.setSelectedIndex(Get.currentRoute);
    });
    return Obx(
      () => NavigationRail(
        extended: true,
        minExtendedWidth: 210,
        leading: Column(
          children: [
            Container(
              height: 72,
              width: 210,
              padding: const EdgeInsets.only(left: kDefaultPadding),
              child: Row(
                children: [
                  Image.asset('assets/images/mawaroute_text.webp', width: 150),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                return Container(
                  height: 36,
                  width: 210,
                  margin: const EdgeInsets.only(bottom: kDefaultPadding),
                  child: ListTile(
                    title: OutlinedButton.icon(
                      onPressed: () {
                        SmartDialog.showAttach(
                          maskColor: Colors.transparent,
                          alignment: Alignment.centerRight,
                          animationType: SmartAnimationType.fade,
                          targetContext: context,
                          builder: (context) {
                            return Container(
                              width: 240,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Card(
                                child: Column(
                                  children: [
                                    ListTile(
                                      onTap: () {},
                                      leading: const Icon(
                                        CupertinoIcons.radiowaves_right,
                                      ),
                                      title: Text('Create new campaign'.tr),
                                    ),
                                    ListTile(
                                      onTap: () {},
                                      leading: const Icon(
                                        CupertinoIcons.building_2_fill,
                                      ),
                                      title: Text('Add new shop'.tr),
                                    ),
                                    // ListTile(
                                    //   onTap: () {},
                                    //   leading:
                                    //       const Icon(CupertinoIcons.speaker_3),
                                    //   title: Text(
                                    //       'Invite shops to join MaWaRoute'.tr),
                                    // )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      label: Text('Create'.tr),
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        trailing: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 48,
                width: 210,
                child: ListTile(
                  onTap: () async {},
                  title: Text(
                    'Settings'.tr,
                    style: const TextStyle(fontSize: 15),
                  ),
                  leading: const Icon(
                    CupertinoIcons.settings,
                    // size: 18,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        onDestinationSelected: (index) {
          homeController.selectedIndex.value = index;
          homeController.navigateWithRail(index);
        },
        destinations: [
          NavigationRailDestination(
            icon: const Icon(CupertinoIcons.compass),
            label: Text('Home'.tr),
          ),
          NavigationRailDestination(
            icon: const Icon(CupertinoIcons.building_2_fill),
            label: Text('Shops'.tr),
          ),
          NavigationRailDestination(
            icon: const Icon(CupertinoIcons.radiowaves_right),
            label: Text('Campaigns'.tr),
          ),
          NavigationRailDestination(
            icon: const Icon(CupertinoIcons.gift_alt_fill),
            label: Text('Rewards'.tr),
          ),
          NavigationRailDestination(
            icon: const Icon(CupertinoIcons.person_alt_circle),
            label: Text('Account'.tr),
          ),
          NavigationRailDestination(
            icon: const Icon(CupertinoIcons.graph_square),
            label: Text('Top Holder'.tr),
          ),
          NavigationRailDestination(
            icon: const Icon(CupertinoIcons.bell),
            label: Text('Notifications'.tr),
          ),
        ],
        selectedIndex: homeController.selectedIndex.value,
      ),
    );
  }
}
