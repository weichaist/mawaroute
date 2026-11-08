import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/home_controller.dart';
import 'package:mawaroute_business/theme/constants.dart';

class DesktopNavigationRail extends StatelessWidget {
  const DesktopNavigationRail({super.key});

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
                  Image.asset(
                    'assets/images/mawaroute_text.webp',
                    width: 150,
                  ),
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
                                            CupertinoIcons.arrow_merge),
                                        title: const Text('New Campaign'),
                                      ),
                                      ListTile(
                                        onTap: () {},
                                        leading:
                                            const Icon(CupertinoIcons.gift),
                                        title: const Text('New Reward'),
                                      ),
                                      ListTile(
                                        onTap: () {},
                                        leading: const Icon(
                                            CupertinoIcons.speaker_3),
                                        title: const Text('New Ad'),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      label: const Text('Create'),
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                      ),
                    ),
                  ),
                );
              },
            )
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
                  onTap: () {},
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontSize: 15),
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
        destinations: const [
          NavigationRailDestination(
            icon: Icon(CupertinoIcons.compass),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(CupertinoIcons.radiowaves_right),
            label: Text('IoT Elements'),
          ),
          NavigationRailDestination(
            icon: Icon(CupertinoIcons.arrow_merge),
            label: Text('Campaigns'),
          ),
          NavigationRailDestination(
            icon: Icon(CupertinoIcons.speaker_3),
            label: Text('Ads'),
          ),
          NavigationRailDestination(
            icon: Icon(CupertinoIcons.person_2_square_stack),
            label: Text('Shops'),
          ),
          NavigationRailDestination(
            icon: Icon(CupertinoIcons.gift),
            label: Text('Rewards'),
          ),
          NavigationRailDestination(
            icon: Icon(CupertinoIcons.placemark),
            label: Text('My Place'),
          ),
        ],
        selectedIndex: homeController.selectedIndex.value,
      ),
    );
  }
}
