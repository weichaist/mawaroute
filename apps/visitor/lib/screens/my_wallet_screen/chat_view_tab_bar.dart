import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/wallet_controller.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

import '../../models/m_avatar_model.dart';

class ChatViewTabBar extends StatelessWidget {
  const ChatViewTabBar({super.key});
  @override
  Widget build(BuildContext context) {
    final walletController = WalletController.instance;
    return SliverToBoxAdapter(
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 9.0),
              child:
                  TextButton.icon(
                    onPressed: () {
                      walletController.selectedTab.value = 0;
                    },
                    label: Text(
                      'Recent'.tr,
                      style: TextStyle(
                        color: walletController.selectedTab.value == 0
                            ? Colors.white
                            : kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(
                      CupertinoIcons.chat_bubble_2,
                      color: walletController.selectedTab.value == 0
                          ? Colors.white
                          : kPrimaryColor,
                    ),
                  ).frosted(
                    frostColor: walletController.selectedTab.value == 0
                        ? kPrimaryColor
                        : kPrimaryContainerColor,
                    frostOpacity: 0.84,
                    borderRadius: BorderRadius.circular(24),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9.0),
              child:
                  TextButton.icon(
                    onPressed: () {
                      Get.toNamed('/chat_rec_history');
                    },
                    label: Text(
                      'History'.tr,
                      style: TextStyle(
                        color: walletController.selectedTab.value == 1
                            ? Colors.white
                            : kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: Icon(
                      CupertinoIcons.clock,
                      color: walletController.selectedTab.value == 1
                          ? Colors.white
                          : kPrimaryColor,
                    ),
                  ).frosted(
                    frostColor: walletController.selectedTab.value == 1
                        ? kPrimaryColor
                        : kPrimaryContainerColor,
                    frostOpacity: 0.84,
                    borderRadius: BorderRadius.circular(24),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatViewList extends StatelessWidget {
  const ChatViewList({super.key});
  @override
  Widget build(BuildContext context) {
    final walletController = WalletController.instance;
    walletController.fetchRecentChats();
    return SliverToBoxAdapter(
      child: Obx(
        () => ListView.builder(
          itemBuilder: (context, index) {
            MAvatarModel mAvatar =
                walletController.mAvatars.value.results[index];
            return ListTile(title: Text(mAvatar.name));
          },
          itemCount: walletController.mAvatars.value.results.length,
          shrinkWrap: true,
        ),
      ),
    );
  }
}
