import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/auth_controller.dart';
import 'package:mawaroute_visitor/controllers/wallet_controller.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';
import 'package:mawaroute_visitor/utilis/launch_urls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../top_level_components/common_widgets/single_click_outlined_button.dart';

Future<void> buildMyWalletMenuDialog(
  BuildContext context,
  AuthController authController,
) async {
  final walletController = WalletController.instance;
  SmartDialog.showAttach(
    animationType: SmartAnimationType.fade,
    targetContext: context,
    builder: (context) => Container(
      width: getScreenWidth() / 1.26,
      margin: const EdgeInsets.only(right: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Settings'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            dense: true,
          ),
          const Divider(),
          ListTile(
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(text: walletController.walletAddress.value),
              ).then(
                (value) => SmartDialog.showToast(
                  'Wallet address copied'.tr,
                  alignment: Alignment.topCenter,
                ),
              );
              await Future.delayed(const Duration(milliseconds: 600));
              await launchPolygon();
              SmartDialog.dismiss();
            },
            leading: SvgPicture.asset(
              'assets/svg/polygon.svg',
              height: 24,
              width: 24,
            ),
            title: Text('Get more MATIC for GGMT transfer'.tr),
            subtitle: Text(
              'Please select Mumbai network and MATIC token on Polygon Faucet'
                  .tr,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Divider(),
          ListTile(
            onTap: () async {
              // String privateKey = await walletController.getPrivateKey();
              final prefs = await SharedPreferences.getInstance();
              FirebaseAuth auth = FirebaseAuth.instance;
              final privateKey = prefs.getString(
                'mawaroute_private_key_${auth.currentUser!.uid}',
              );
              if (privateKey == null) {
                SmartDialog.dismiss();
                SmartDialog.showNotify(
                  msg: 'Error of loading your private key'.tr,
                  notifyType: NotifyType.failure,
                );
                return;
              }
              await Clipboard.setData(ClipboardData(text: privateKey)).then(
                (value) => SmartDialog.showToast(
                  'Private key copied'.tr,
                  alignment: Alignment.topCenter,
                ),
              );
              await SharePlus.instance.share(
                ShareParams(text: 'private key: $privateKey'),
              );
              SmartDialog.dismiss();
            },
            leading: const Icon(Icons.key, color: kPrimaryColor),
            title: Text('Copy my private key'.tr),
            subtitle: Text(
              'Remember to store your key in a secure location'.tr,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              SmartDialog.dismiss();
              Get.toNamed('/permission/camera');
            },
            leading: const Icon(
              Icons.phone_iphone_rounded,
              color: kPrimaryColor,
            ),
            title: Text('Permissions'.tr),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              SmartDialog.dismiss();
              SmartDialog.show(
                animationType: SmartAnimationType.fade,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: getScreenWidth() / 1.618,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          'Attention! Once your account is deleted, you cannot recover your data. Please long press the Delete button to continue.'
                              .tr,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: OutlinedButton(
                          onLongPress: () async {
                            await walletController.requestAccountDelete();
                            await authController.signOut();
                            SmartDialog.dismiss();
                            SmartDialog.showToast(
                              'We are processing your account deletion request'
                                  .tr,
                            );
                          },
                          onPressed: () {},
                          child: Text(
                            'Delete'.tr,
                            style: const TextStyle(color: kAlertColor),
                          ),
                        ),
                        subtitle: const Text(''),
                      ),
                      ListTile(
                        title: OutlinedButton(
                          onPressed: () {
                            SmartDialog.dismiss();
                          },
                          child: Text('Cancel'.tr),
                        ),
                        subtitle: const Text(''),
                      ),
                    ],
                  ),
                ),
              );
            },
            leading: const Icon(CupertinoIcons.delete, color: kAlertColor),
            title: Text('Delete your mawaroute account'.tr),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              SmartDialog.dismiss();
              SmartDialog.show(
                animationType: SmartAnimationType.fade,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: getScreenWidth() / 1.618,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('Sign out of the \nmawaroute app now?'.tr),
                      ),
                      const Divider(),
                      ListTile(
                        title: SingleClickOutlinedButton(
                          onPressed: () async {
                            await authController.signOut();
                            SmartDialog.dismiss();
                          },
                          child: Text('Logout'.tr),
                        ),
                        subtitle: const Text(''),
                      ),
                      ListTile(
                        title: OutlinedButton(
                          onPressed: () {
                            SmartDialog.dismiss();
                          },
                          child: Text('Cancel'.tr),
                        ),
                        subtitle: const Text(''),
                      ),
                    ],
                  ),
                ),
              );
            },
            leading: const Icon(Icons.exit_to_app, color: kPrimaryColor),
            title: Text('Logout'.tr),
          ),
        ],
      ),
    ),
  );
}
