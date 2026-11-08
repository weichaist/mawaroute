import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/profile_controller.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

class ProfilePictureEditScreen extends StatelessWidget {
  const ProfilePictureEditScreen({super.key});

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
    return CustomScrollView(
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
                DottedBorder(
                  options: const CircularDottedBorderOptions(
                    color: CupertinoColors.lightBackgroundGray,
                    strokeWidth: 1.2,
                  ),
                  child: Obx(
                    () => InkWell(
                      onTap: () async {
                        await profileController.selectImage();
                      },
                      hoverColor: Colors.transparent,
                      child: profileController.profileImage.value.isEmpty
                          ? Container(
                              height: 300,
                              width: 450,
                              decoration: const BoxDecoration(
                                // borderRadius: BorderRadius.circular(12),
                                shape: BoxShape.circle,
                                color: kPrimaryColor,
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.photo,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : profileController.isImageChanged() &&
                                profileController.isSvgImage()
                          ? Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                Container(
                                  height: 300,
                                  width: 300,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.network(
                                    profileController.profileImage.value,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    profileController.clearImage();
                                  },
                                  splashRadius: 9,
                                  icon: const Icon(
                                    CupertinoIcons.clear_circled_solid,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              height: 300,
                              width: 450,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image:
                                      profileController.isImageChanged() &&
                                          !profileController.isSvgImage()
                                      ? NetworkImage(
                                          profileController.profileImage.value,
                                        )
                                      : FileImage(
                                              File(
                                                profileController
                                                    .profileImage
                                                    .value,
                                              ),
                                            )
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          profileController.clearImage();
                                        },
                                        splashRadius: 9,
                                        icon: const Icon(
                                          CupertinoIcons.clear_circled_solid,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(''),
                  subtitle: ElevatedButton.icon(
                    onPressed: () async {
                      await profileController.saveImage();
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
    );
  }
}
