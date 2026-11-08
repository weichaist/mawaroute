import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/wallet_controller.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';
import 'package:mawaroute_visitor/utilis/launch_urls.dart';

import '../../top_level_components/common_widgets/single_click_outlined_button.dart';
import '../../top_level_components/common_widgets/single_click_text_button.dart';

class TokenTransferBottomSheetParam {
  final bool isEditable;
  final int amount;
  final String rewardUid;
  final String email;
  TokenTransferBottomSheetParam({
    required this.isEditable,
    this.amount = 0,
    required this.rewardUid,
    this.email = "",
  });
}

Future<dynamic> buildTokenTransferBottomSheet(
  TokenTransferBottomSheetParam param,
) {
  WalletController walletController = WalletController.instance;
  walletController.initGGMTTransfer();
  if (param.isEditable == false) {
    walletController.transferAmount.value = param.amount;
    walletController.transferAmountController.value.text = param.amount
        .toString();
  }
  return SmartDialog.show(
    tag: 'transferDialog',
    animationType: SmartAnimationType.centerFade_otherSlide,
    alignment: Alignment.topCenter,
    keepSingle: true,
    builder: (context) {
      return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          width: getScreenWidth(),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        IconButton(
                          icon: const Icon(CupertinoIcons.clear),
                          onPressed: () {
                            SmartDialog.dismiss(tag: 'transferDialog');
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    Obx(
                      () => Column(
                        children: [
                          ListTile(
                            title: Text(
                              '${'GGMT'.tr}${'Balance'.tr}: ${walletController.tokenBalance}',
                            ),
                          ),
                          ListTile(
                            leading: const Column(
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(
                                    'assets/images/guru_guru_coin.png',
                                  ),
                                  radius: 15,
                                ),
                              ],
                            ),
                            title: Text(
                              walletController.transferAmount.value.toString(),
                              style: const TextStyle(fontSize: 24),
                            ),
                            subtitle: Text(
                              'Number of tokens required to redeem this reward'
                                  .tr,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Card(
                      color: WidgetStateColor.resolveWith(
                        (states) => kPrimaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding * 1.618,
                          vertical: kDefaultPadding / 1.618,
                        ),
                        child: SingleClickTextButton(
                          child: Text(
                            'Transfer'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            try {
                              SmartDialog.showLoading(msg: 'Processing...'.tr);
                              await walletController.transferGGMTToken(
                                param.rewardUid,
                                param.email,
                              );
                              SmartDialog.dismiss();
                            } catch (e) {
                              SmartDialog.dismiss();
                            }
                          },
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    Column(
                      children: [
                        Obx(
                          () => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text(
                                  'Sufficient MATIC balance is required to transfer GGMT.\nPress the get button to get more if your MATIC balance is low'
                                      .tr,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              ListTile(
                                onTap: () async {
                                  SmartDialog.showToast(
                                    'Checking MATIC Balance...'.tr,
                                    alignment: Alignment.topCenter,
                                  );
                                  await walletController
                                      .fetchNativeBalanceForPolygon();
                                  SmartDialog.showToast(
                                    'Balance has been updated'.tr,
                                    alignment: Alignment.topCenter,
                                  );
                                },
                                leading: SvgPicture.asset(
                                  'assets/svg/polygon.svg',
                                  height: 21,
                                  width: 21,
                                ),
                                title: AutoSizeText(
                                  '${'Your Matic Balance: '.tr}${walletController.maticBalance.toStringAsFixed(6)}',
                                  maxLines: 1,
                                ),
                                subtitle: AutoSizeText(
                                  'Check MATIC Balance'.tr,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                trailing: SingleClickOutlinedButton(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text: walletController
                                            .walletAddress
                                            .value,
                                      ),
                                    ).then(
                                      (value) => SmartDialog.showToast(
                                        'Wallet address copied'.tr,
                                        alignment: Alignment.topCenter,
                                      ),
                                    );
                                    await Future.delayed(
                                      const Duration(milliseconds: 600),
                                    );
                                    await launchPolygon();
                                  },
                                  child: Text('Get'.tr),
                                ),
                              ),
                              ListTile(
                                onTap: () {
                                  launchAboutMatic();
                                },
                                title: Text(
                                  'If you want to learn more about MATIC 👉🏻'
                                      .tr,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: const Icon(
                                  CupertinoIcons.link_circle,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 9),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
