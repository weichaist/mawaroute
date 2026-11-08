import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/profile_controller.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

class ProfileDisplayNameEditScreen extends StatelessWidget {
  const ProfileDisplayNameEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: kBgColor, body: Body());
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = ProfileController.instance;
    profileController.init();
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            automaticallyImplyLeading: false,
            leading: const Icon(
              CupertinoIcons.person_crop_circle_badge_checkmark,
            ),
            title: Text(
              'Edit Profile'.tr,
              style: const TextStyle(color: kPrimaryColor),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(CupertinoIcons.xmark_circle),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  ListTile(title: Text('Username'.tr)),
                  ListTile(
                    title: TextField(
                      controller: profileController.displayName,
                      maxLength: 27,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"([^\u0000-\u007F]|\w)+"),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text(''),
                    subtitle: ElevatedButton.icon(
                      onPressed: () async {
                        await profileController.saveDisplayName();
                      },
                      icon: const Icon(Icons.save),
                      label: Text('Save'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
