import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/home_controller.dart';
import 'package:mawaroute_shop/screens/home_screen/dashboard_screen.dart';
import 'package:mawaroute_shop/screens/home_screen/set_spot_photo_screen.dart';
import 'package:mawaroute_shop/theme/constants.dart';
import 'package:mawaroute_shop/theme/size_config.dart';

import 'library_screen.dart';
import 'my_account_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final c = HomeController.instance;
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: c.selectedBottomNavBarIndex.value,
          onDestinationSelected: (index) {
            c.selectedBottomNavBarIndex.value = index;
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(
                Icons.dashboard,
                color: kPrimaryColor,
              ),
              label: 'Home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.photo_outlined),
              selectedIcon: const Icon(
                Icons.photo,
                color: kPrimaryColor,
              ),
              label: 'Spot'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.photo_library_outlined),
              selectedIcon: const Icon(
                Icons.photo_library,
                color: kPrimaryColor,
              ),
              label: 'Library'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_pin_circle_outlined),
              selectedIcon: const Icon(
                Icons.person_pin_circle_rounded,
                color: kPrimaryColor,
              ),
              label: 'Account'.tr,
            ),
          ],
        ),
      ),
      body: Obx(() => [
            const DashboardScreen(),
            const SetSpotPhotoScreen(),
            const LibraryScreen(),
            const MyAccountScreen(),
          ][c.selectedBottomNavBarIndex.value]),
    );
  }
}
