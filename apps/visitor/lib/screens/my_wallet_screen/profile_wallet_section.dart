import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/auth_controller.dart';
import 'package:mawaroute_visitor/controllers/wallet_controller.dart';

import '../../theme/constants.dart';

class ProfileWalletSection extends StatelessWidget {
  const ProfileWalletSection({super.key});
  @override
  Widget build(BuildContext context) {
    WalletController walletController = WalletController.instance;
    AuthController authController = AuthController.instance;
    walletController.initTokenBalanceCheck();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(
              () => GestureDetector(
                onTap: () {
                  Get.toNamed("/profile/picture");
                },
                child: authController.profile.value.image.isEmpty
                    ? const CircleAvatar(
                        backgroundColor: kPrimaryContainerColor,
                        radius: 36,
                        child: Icon(CupertinoIcons.person_circle),
                      )
                    : authController.profile.value.image.contains(".svg?")
                    ? CircleAvatar(
                        backgroundColor: kPrimaryContainerColor,
                        radius: 36,
                        child: ClipOval(
                          child: SvgPicture.network(
                            authController.profile.value.image,
                            key: UniqueKey(),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: kPrimaryContainerColor,
                        radius: 36,
                        backgroundImage: NetworkImage(
                          authController.profile.value.image,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Address '.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: kPrimaryColor,
                    ),
                  ),
                  Obx(
                    () => Text(
                      walletController.walletAddress.value.length > 10
                          ? walletController.walletAddress.value.substring(
                              0,
                              10,
                            )
                          : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                  const Text(
                    '...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: kPrimaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (walletController.walletAddress.value.isNotEmpty) {
                        Clipboard.setData(
                          ClipboardData(
                            text: walletController.walletAddress.value,
                          ),
                        );
                        SmartDialog.showToast(
                          'Wallet address copied'.tr,
                          alignment: Alignment.topCenter,
                        );
                      } else {
                        SmartDialog.showToast(
                          'Oops, something went wrong...'.tr,
                        );
                      }
                    },
                    child: const Icon(Icons.copy_rounded, size: 15),
                  ),
                ],
              ),
            ),
            Obx(
              () => Row(
                //todo Later we might need to create multiple tokens for different place owners
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/guru_guru_coin.png',
                        ),
                        radius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(width: kDefaultPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${walletController.tokenBalance.value}',
                            style: const TextStyle(
                              fontSize: 24,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text('GGMT', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      AutoSizeText('Your GGMT Balance'.tr, maxLines: 1),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
