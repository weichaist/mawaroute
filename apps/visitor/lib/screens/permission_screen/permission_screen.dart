import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/permission_controller.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:permission_handler/permission_handler.dart';

import '../top_level_components/common_widgets/single_click_outlined_button.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBgColor,
      body: PermissionScreenBody(),
    );
  }
}

class PermissionScreenBody extends StatelessWidget {
  const PermissionScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    PermissionController c = PermissionController.instance;
    c.init(Get.parameters['type']!);
    return Obx(
      () => PageView(
        controller: c.pageController,
        children: [
          PermissionTab(
            permissionType: 'camera',
            permissionInJP: 'Camera',
            permissionText: c.cameraPermissionText.value,
            isPermissionGranted: c.cameraPermissionGranted.value,
          ),
          PermissionTab(
            permissionType: 'photos',
            permissionInJP: 'Photos',
            permissionText: c.photoPermissionText.value,
            isPermissionGranted: c.photoPermissionGranted.value,
          ),
          PermissionTab(
            permissionType: 'location',
            permissionInJP: 'Location',
            permissionText: c.locationPermissionText.value,
            isPermissionGranted: c.locationPermissionGranted.value,
          ),
          PermissionTab(
            permissionType: 'notification',
            permissionInJP: 'Notification',
            permissionText: c.notificationPermissionText.value,
            isPermissionGranted: c.notificationPermissionGranted.value,
          ),
        ],
      ),
    );
  }
}

class PermissionTab extends StatelessWidget {
  const PermissionTab({
    super.key,
    required this.permissionType,
    required this.permissionText,
    required this.isPermissionGranted,
    required this.permissionInJP,
  });

  final String permissionType;
  final String permissionText;
  final bool isPermissionGranted;
  final String permissionInJP;

  @override
  Widget build(BuildContext context) {
    PermissionController c = PermissionController.instance;
    c.initPermissionRequest(permissionType);
    // c.initPermissionChecking(permissionType);
    return RefreshIndicator(
      onRefresh: () async {
        c.initPermissionChecking(permissionType);
        Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                CupertinoIcons.left_chevron,
                color: kPrimaryColor,
              ),
            ),
            title: Text('$permissionInJP Access'),
            actions: [
              TextButton(
                onPressed: () {},
                child: Text(
                  '${c.allPermissions.indexOf(permissionType) + 1}/${c.allPermissions.length}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                buildPermissionExplainListTile(permissionType),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: SvgPicture.asset(
                      'assets/images/permission/$permissionType.svg',
                      colorFilter: const ColorFilter.mode(
                        kPrimaryColor,
                        BlendMode.color,
                      ),
                    ),
                  ),
                ),
                //ListTile
                Container(
                  height: 180,
                  padding: const EdgeInsets.symmetric(
                    vertical: kDefaultPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: isPermissionGranted
                            ? OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  CupertinoIcons.check_mark_circled_solid,
                                  color: CupertinoColors.activeGreen,
                                ),
                                label: Text('Permission Granted'.tr),
                              )
                            : const Icon(CupertinoIcons.gear),
                      ),
                      const SizedBox(height: 18),
                      isPermissionGranted == false
                          ? SingleClickOutlinedButton(
                              child: Text(
                                'Please allow access in the system settings'.tr,
                              ),
                              onPressed: () async {
                                Get.back();
                                await openAppSettings();
                              },
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildPermissionExplainListTile(String type) {
  if (type == 'camera') {
    return ListTile(
      leading: const Text('📸', style: TextStyle(fontSize: 36)),
      title: Text('Camera is required to participate in campaigns'.tr),
    );
  } else if (type == 'photos') {
    return ListTile(
      leading: const Text('🎞️', style: TextStyle(fontSize: 36)),
      title: Text(
        'Photos access is required to change your profile picture'.tr,
      ),
    );
  } else if (type == 'location') {
    return ListTile(
      leading: const Text('📍', style: TextStyle(fontSize: 36)),
      title: Text(
        'Location is required to verify your participation of campaigns'.tr,
      ),
    );
  } else {
    return ListTile(
      leading: const Text('🔔', style: TextStyle(fontSize: 36)),
      title: Text('Get notified for exciting news and updates'.tr),
    );
  }
}
