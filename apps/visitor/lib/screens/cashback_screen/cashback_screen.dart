import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';
import 'package:mawaroute_visitor/utilis/formatter.dart';

import '../../controllers/cashback_controller.dart';
import '../../controllers/email_dialog_controller.dart';
import '../../models/cashback_receiver_model.dart';
import '../home_nav_wrapper/components/build_cash_back_token_transfer_bottom_sheet.dart';
import '../reward_details_screen/components/build_email_dialog.dart';
import '../top_level_components/common_widgets/single_click_gesture_detector.dart';

class CashBackScreen extends StatelessWidget {
  const CashBackScreen({super.key});
  @override
  Widget build(BuildContext context) {
    EmailDialogController emailDialogController =
        EmailDialogController.instance;
    emailDialogController.init();
    CashBackController cashBackController = CashBackController.instance;
    cashBackController.init();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.heavyImpact();
          await cashBackController.init();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Obx(
          () => cashBackController.isLoading.isFalse
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: Obx(
                        () => AutoSizeText(
                          cashBackController.topReward.value.condition ==
                                  'visited'
                              ? "Visit Cashback".tr
                              : "Purchase Cashback".tr,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        // height: getScreenWidth() * 1.618,
                        width: getScreenWidth(),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(
                              () =>
                                  cashBackController
                                      .topReward
                                      .value
                                      .bgUrl
                                      .isNotEmpty
                                  ? ExtendedImage.network(
                                      cashBackController.topReward.value.bgUrl,
                                      fit: BoxFit.fitWidth,
                                    )
                                  : const SizedBox(),
                            ),
                            const Divider(color: Colors.transparent),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ...List.generate(
                                  3,
                                  (index) => SingleClickGestureDetector(
                                    onPressed: () async {
                                      await cashBackController
                                          .getCashBackPermissibleCount();
                                      await cashBackController.getCashBackCount(
                                        rewardUid: cashBackController
                                            .topReward
                                            .value
                                            .uid!,
                                      );
                                      if (cashBackController
                                              .cashBackPermissibleCount
                                              .value <=
                                          cashBackController
                                              .cashBackCount
                                              .value) {
                                        SmartDialog.showNotify(
                                          msg:
                                              cashBackController
                                                      .topReward
                                                      .value
                                                      .condition ==
                                                  'visited'
                                              ? 'Shop visits are required to get cashback'
                                                    .tr
                                              : 'After purchasing, scan mawaroute qr code to get cashback'
                                                    .tr,
                                          notifyType: NotifyType.alert,
                                        );
                                        return;
                                      }
                                      final result =
                                          cashBackController
                                                  .topReward
                                                  .value
                                                  .condition ==
                                              'visited'
                                          ? generateWeightedRandomNumber()
                                          : generatePurchasedWeightedRandomNumber();
                                      int transferAmount = (2 * index + 1) * 10;
                                      int cashBackAmount =
                                          (2 * index + 1) * 10 * result;
                                      bool validEmail =
                                          await buildEmailDialog();
                                      if (validEmail) {
                                        CashBackTokenTransferBottomSheetParam
                                        param =
                                            CashBackTokenTransferBottomSheetParam(
                                              isEditable: false,
                                              tokenNumber: transferAmount,
                                              cashbackAmount: cashBackAmount,
                                              rewardUid: cashBackController
                                                  .topReward
                                                  .value
                                                  .uid!,
                                              email: emailDialogController
                                                  .email
                                                  .value
                                                  .text,
                                            );
                                        final resCode =
                                            await buildCashbackTokenTransferBottomSheet(
                                              param,
                                            );
                                        if (resCode == 200) {
                                          if (cashBackAmount > 0) {
                                            await buildShowCashbackAmount(
                                              cashBackAmount,
                                            );
                                          }
                                        } else {
                                          SmartDialog.showNotify(
                                            msg: 'Failed to get cashback'.tr,
                                            notifyType: NotifyType.failure,
                                          );
                                          return;
                                        }
                                      }
                                    },
                                    child: Card(
                                      color: kPrimaryColor,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: kDefaultPadding,
                                          vertical: kDefaultPadding / 2,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '${(2 * index + 1) * 10}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 36,
                                                color: Colors.white,
                                              ),
                                            ),
                                            ExtendedImage.asset(
                                              'assets/images/guru_guru_coin.png',
                                              height: 36,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Obx(
                            () => ListTile(
                              title: Text(
                                'Available cashback today'.tr,
                                style: const TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                '${cashBackController.cashBackPermissibleCount}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'About this reward'.tr,
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(
                            () => ListTile(
                              title: Text(
                                cashBackController.topReward.value.description,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Cashback History'.tr,
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        bottom: kDefaultPadding * 3 * 1.618,
                      ),
                      sliver: SliverList.builder(
                        itemBuilder: (context, index) {
                          CashbackReceiverModel cashBack =
                              cashBackController.cashBacks[index];
                          return ListTile(
                            title: Text('¥ ${cashBack.cashBackAmount}'),
                            subtitle: Text(formatDateTime(cashBack.timestamp)),
                            trailing: OutlinedButton(
                              onPressed: () {},
                              child: !cashBack.sent
                                  ? Text('Unsent'.tr)
                                  : Text('Sent'.tr),
                            ),
                          );
                        },
                        itemCount: cashBackController.cashBacks.length,
                      ),
                    ),
                  ],
                )
              : const Center(child: CupertinoActivityIndicator()),
        ),
      ),
    );
  }

  Future<void> buildShowCashbackAmount(int cashBackAmount) async {
    await SmartDialog.show(
      tag: 'showCashbackAmount',
      builder: (_) {
        final marginWidth = getScreenWidth() - 18;
        return Container(
          width: marginWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: marginWidth,
                    width: marginWidth,
                    child: LottieBuilder.asset(
                      'assets/lottie_files/coin_rain.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: marginWidth,
                    width: marginWidth,
                  ).frosted(borderRadius: BorderRadius.circular(12)),
                  SizedBox(
                    height: marginWidth,
                    child: LottieBuilder.asset(
                      'assets/lottie_files/use_coupon.json',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
              ListTile(
                title: Center(
                  child: Text(
                    '￥ $cashBackAmount',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        SmartDialog.dismiss(tag: 'showCashbackAmount');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

int generateWeightedRandomNumber() {
  Random random = Random();
  double rangeSelector = random.nextDouble();
  int randomNumber;

  if (rangeSelector < 0.69) {
    // Select a number from 1 to 5.
    randomNumber = 1 + random.nextInt(5);
  } else if (rangeSelector < 0.93) {
    // Select a number from 5 to 10.
    randomNumber = 5 + random.nextInt(5);
  } else if (rangeSelector < 0.996) {
    // Select a number from 11 to 20.
    randomNumber = 11 + random.nextInt(10);
  } else if (rangeSelector < 0.9999) {
    // Select a number from 21 to 30.
    randomNumber = 21 + random.nextInt(10);
  } else {
    // Select a number from 31 to 100.
    randomNumber = 31 + random.nextInt(70);
  }

  return randomNumber;
}

int generatePurchasedWeightedRandomNumber() {
  Random random = Random();
  double rangeSelector = random.nextDouble();
  int randomNumber;

  if (rangeSelector < 0.72) {
    // Select a number from 5 to 10.
    randomNumber = 5 + random.nextInt(5);
  } else if (rangeSelector < 0.96) {
    // Select a number from 11 to 15.
    randomNumber = 11 + random.nextInt(5);
  } else if (rangeSelector < 0.996) {
    // Select a number from 21 to 30.
    randomNumber = 16 + random.nextInt(10);
  } else if (rangeSelector < 0.9999) {
    // Select a number from 31 to 40.
    randomNumber = 31 + random.nextInt(10);
  } else {
    // Select a number from 41 to 100.
    randomNumber = 41 + random.nextInt(60);
  }

  return randomNumber;
}
