import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/auth_controller.dart';
import 'package:mawaroute_visitor/controllers/wallet_controller.dart';
import 'package:mawaroute_visitor/screens/my_wallet_screen/chat_view_tab_bar.dart';
import 'package:mawaroute_visitor/screens/my_wallet_screen/components/build_wallet_body_tab_body.dart';
import 'package:mawaroute_visitor/screens/my_wallet_screen/components/send_invitation_list_tile.dart';
import 'package:mawaroute_visitor/screens/my_wallet_screen/dialogs/build_wallet_menu_dialog.dart';
import 'package:mawaroute_visitor/screens/my_wallet_screen/profile_wallet_section.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

class MyWalletScreen extends StatelessWidget {
  const MyWalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    WalletController walletController = WalletController.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await walletController.init();
    });
    return const Scaffold(body: Body());
  }
}

class Body extends StatelessWidget {
  const Body({super.key});
  @override
  Widget build(BuildContext context) {
    WalletController walletController = WalletController.instance;
    AuthController authController = AuthController.instance;
    authController.updateUserprofile();
    return Obx(
      () => RefreshIndicator(
        color: Colors.white,
        backgroundColor: kPrimaryColor,
        displacement: 90,
        onRefresh: () async {
          HapticFeedback.heavyImpact();
          SmartDialog.showLoading(msg: 'Processing...'.tr);
          try {
            await walletController.init();
            await walletController.initTokenBalanceCheck();
          } catch (e) {
            if (kDebugMode) print(e);
            SmartDialog.showNotify(
              msg: 'Experiencing technical issues. Please try again later.',
              notifyType: NotifyType.error,
            );
          } finally {
            SmartDialog.dismiss();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: const Icon(
                CupertinoIcons.person_crop_circle,
                color: kPrimaryColor,
              ),
              title: GestureDetector(
                onTap: () async {
                  Get.toNamed("/profile/display-name");
                },
                child: AutoSizeText(
                  authController.profile.value.displayName,
                  maxLines: 1,
                  style: const TextStyle(color: kPrimaryColor),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 9.0, bottom: 9.0),
                  child: Card(
                    margin: const EdgeInsets.all(0),
                    child: IconButton(
                      onPressed: () {
                        Get.toNamed("/send-invitation");
                      },
                      icon: const Icon(
                        CupertinoIcons.gift,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 9.0, bottom: 9.0),
                      child: Card(
                        margin: const EdgeInsets.all(0),
                        child: IconButton(
                          onPressed: () async {
                            await buildMyWalletMenuDialog(
                              context,
                              authController,
                            );
                          },
                          icon: const Icon(
                            CupertinoIcons.ellipsis,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            //Profile and wallet address
            const ProfileWalletSection(),
            const InviteFriendsListTile(),
            const ChatViewTabBar(),
            const ChatViewList(),
            buildMyWalletTabBody(),
          ],
        ),
      ),
    );
  }
}
