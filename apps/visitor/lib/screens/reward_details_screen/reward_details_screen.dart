import 'package:action_slider/action_slider.dart';
import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaroute_visitor/controllers/email_dialog_controller.dart';
import 'package:mawaroute_visitor/controllers/reward_details_controller.dart';
import 'package:mawaroute_visitor/enums.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';
import 'package:mawaroute_visitor/utilis/formatter.dart';

import '../../models/reward_receiver_model.dart';
import '../my_wallet_screen/dialogs/build_token_transfer_bottom_sheet.dart';
import '../top_level_components/common_widgets/single_click_elevated_button.dart';
import 'components/build_email_dialog.dart';

class RewardDetailsScreen extends StatelessWidget {
  const RewardDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    RewardDetailsController c = RewardDetailsController.instance;
    c.init();
    EmailDialogController emailDialogController =
        EmailDialogController.instance;
    emailDialogController.init();
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: kPrimaryColor,
        color: Colors.white,
        displacement: 96,
        onRefresh: () async {
          HapticFeedback.heavyImpact();
          await c.init();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Obx(
                    () => SafeArea(
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height),
                          );
                        },
                        blendMode: BlendMode.dstIn,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: c.reward.value.downloadUrl.contains('https://')
                              ? Container(
                                  width: getScreenWidth(),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        c.reward.value.downloadUrl,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: getScreenWidth(),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                      height: 69,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: CupertinoColors.darkBackgroundGray
                                .withValues(alpha: 0.6),
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              color: kBgColor,
                              icon: const Icon(Icons.arrow_back_ios_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Obx(
                    () => ListTile(
                      title: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: kDefaultPadding / 2,
                          ),
                          child: Text('#Token required'.tr),
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/images/guru_guru_coin.png',
                            ),
                            radius: 18,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: kDefaultPadding,
                              left: kDefaultPadding,
                            ),
                            child: Text(
                              c.reward.value.tokenNumber.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      title:
                          c.rewardUsages.length <
                              c.reward.value.maxNumberPerUser
                          ? SingleClickElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith(
                                  (states) => kPrimaryColor,
                                ),
                                shape:
                                    WidgetStateProperty.all<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                              ),
                              child: Text(
                                'Get this reward'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                int upperLimit = c.reward.value.upperLimit;
                                if (upperLimit <= 0) {
                                  SmartDialog.showNotify(
                                    msg:
                                        'All rewards have been claimed; stay tuned for more in the future!'
                                            .tr,
                                    notifyType: NotifyType.alert,
                                  );
                                  return;
                                } else if (DateTime.now().isAfter(
                                      c.reward.value.endTime,
                                    ) ||
                                    DateTime.now().isBefore(
                                      c.reward.value.startTime,
                                    )) {
                                  SmartDialog.showNotify(
                                    msg:
                                        'You can only get rewards during the eligibility period'
                                            .tr,
                                    notifyType: NotifyType.alert,
                                  );
                                  return;
                                } else if (c
                                        .reward
                                        .value
                                        .rewardDistributionType ==
                                    RewardDistributionType.email.name) {
                                  bool result = await buildEmailDialog();
                                  if (result) {
                                    TokenTransferBottomSheetParam param =
                                        TokenTransferBottomSheetParam(
                                          isEditable: false,
                                          amount: c.reward.value.tokenNumber,
                                          rewardUid: c.rewardUid.value,
                                          email: emailDialogController
                                              .email
                                              .value
                                              .text,
                                        );
                                    await buildTokenTransferBottomSheet(param);
                                    await c.didUserReceivedReward();
                                  }
                                } else if (c
                                        .reward
                                        .value
                                        .rewardDistributionType ==
                                    RewardDistributionType.onspot.name) {
                                  TokenTransferBottomSheetParam param =
                                      TokenTransferBottomSheetParam(
                                        isEditable: false,
                                        amount: c.reward.value.tokenNumber,
                                        rewardUid: c.rewardUid.value,
                                        email: emailDialogController
                                            .email
                                            .value
                                            .text,
                                      );
                                  await buildTokenTransferBottomSheet(param);
                                  await c.didUserReceivedReward();
                                } else if (c
                                        .reward
                                        .value
                                        .rewardDistributionType ==
                                    RewardDistributionType.coupon.name) {
                                  TokenTransferBottomSheetParam param =
                                      TokenTransferBottomSheetParam(
                                        isEditable: false,
                                        amount: c.reward.value.tokenNumber,
                                        rewardUid: c.rewardUid.value,
                                        email: emailDialogController
                                            .email
                                            .value
                                            .text,
                                      );
                                  await buildTokenTransferBottomSheet(param);
                                  await c.didUserReceivedReward();
                                } else {}
                              },
                            )
                          : OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Text(
                                '🎊',
                                style: TextStyle(fontSize: 18),
                              ),
                              label: Text('Congratulations!'.tr),
                            ),
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      title: Text(
                        'Usage history'.tr,
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        '${'Max #'.tr} ${c.reward.value.maxNumberPerUser}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => SliverList.builder(
                itemCount: c.rewardUsages.length,
                itemBuilder: (context, index) {
                  RewardReceiverModel usage = c.rewardUsages[index];
                  return ListTile(
                    title: Text(c.reward.value.title),
                    subtitle: Text(formatDateTime(usage.timestamp)),
                    trailing: usage.applied == false
                        ? SingleClickElevatedButton(
                            child: Text('Apply'.tr),
                            onPressed: () async {
                              await buildApplyCouponDialog(
                                rewardTitle: c.reward.value.title,
                                rewardUid: usage.rewardUid,
                                rewardReceiverUid: usage.uid,
                              );
                              await c.getRewardUsages();
                            },
                          )
                        : OutlinedButton(
                            onPressed: () {},
                            child: Text('Applied'.tr),
                          ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'About this reward'.tr,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(() => ListTile(title: Text(c.reward.value.title))),
                  Obx(() => ListTile(title: Text(c.reward.value.description))),
                  ListTile(
                    title: Text(
                      'Reward Eligibility Period'.tr,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      subtitle: Text(formatDateTime(c.reward.value.startTime)),
                      title: Text('Start Time'.tr),
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      subtitle: Text(formatDateTime(c.reward.value.endTime)),
                      title: Text('End Time'.tr),
                    ),
                  ),
                  const SizedBox(height: kDefaultPadding * 1.618 * 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> buildApplyCouponDialog({
    required String rewardTitle,
    required String rewardUid,
    required String rewardReceiverUid,
  }) {
    RewardDetailsController c = RewardDetailsController.instance;
    return SmartDialog.show(
      builder: (context) {
        return Container(
          height: getScreenWidth() * 1.618,
          width: getScreenWidth(),
          margin: const EdgeInsets.all(kDefaultPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: getScreenWidth(),
                    width: getScreenWidth(),
                    child: LottieBuilder.asset(
                      'assets/lottie_files/coin_rain.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: getScreenWidth(),
                    width: getScreenWidth(),
                  ).frosted(),
                  SizedBox(
                    height: getScreenWidth(),
                    width: getScreenWidth(),
                    child: LottieBuilder.asset(
                      'assets/lottie_files/use_coupon.json',
                    ),
                  ),
                  Positioned(
                    right: 9,
                    top: 9,
                    child: CircleAvatar(
                      child: IconButton(
                        onPressed: () {
                          SmartDialog.dismiss();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(title: Text(rewardTitle)),
              ListTile(
                title: Text(
                  'To apply this coupon, please show this screen to shop staff.'
                      .tr,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
                child: ActionSlider.standard(
                  backgroundColor: kPrimaryColor,
                  rolling: true,
                  toggleColor: Colors.white,
                  icon: const Icon(
                    Icons.keyboard_arrow_right,
                    color: kPrimaryColor,
                    size: 30,
                  ),
                  child: Text(
                    'Slide to apply'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                  action: (controller) async {
                    controller.loading(); //starts loading animation
                    await c.applyCoupon(
                      rewardUid: rewardUid,
                      rewardReceiverUid: rewardReceiverUid,
                    );
                    await Future.delayed(const Duration(seconds: 1));
                    controller.success(); //starts success animation
                  },
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
