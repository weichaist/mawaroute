import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/screens/qr_scan_screen/qr_scan_screen.dart';
import 'package:mawaroute_shop/theme/constants.dart';
import 'package:mawaroute_shop/theme/size_config.dart';

import '../../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //todo fetch shop coupon
    //todo new shop logo uploader
    //todo when save the shop info, sync to weaviate
    final dashBoardController = DashBoardController.instance;
    dashBoardController.init();
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: kPrimaryColor,
        color: Colors.white,
        displacement: 96,
        onRefresh: () async {
          HapticFeedback.heavyImpact();
          await dashBoardController.init();
          await Future.delayed(
            const Duration(seconds: 1),
          );
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: ExtendedImage.asset(
                'assets/images/mawaroute_text.png',
                height: 27,
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () {
                    Get.to(() => const QRScanScreen());
                  },
                  icon: const Icon(
                    CupertinoIcons.qrcode_viewfinder,
                    color: kPrimaryColor,
                    size: 36,
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () {
                    // buildAdminModeDialog();
                  },
                  child: const Icon(
                    CupertinoIcons.bell_circle,
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(
                    left: kDefaultPadding / 2,
                    right: kDefaultPadding / 2,
                    top: kDefaultPadding / 2),
                child: Card(
                  child: Obx(
                    () => Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            'Boosting foot traffic now'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          value: dashBoardController.shop.value.isLive,
                          onChanged: (val) async {
                            if (val == false) {
                              await buildTurnOffDialog();
                              await dashBoardController.changeIsLive(false);
                            } else {
                              if (dashBoardController
                                      .shop.value.address.isNotEmpty &&
                                  dashBoardController
                                      .shop.value.imageLink!.isNotEmpty) {
                                await dashBoardController.changeIsLive(false);
                              } else {
                                SmartDialog.showNotify(
                                  msg: 'You account is not setup correctly'.tr,
                                  notifyType: NotifyType.alert,
                                );
                              }
                            }
                          },
                        ),
                        ListTile(
                          title: OutlinedButton(
                            child: Text('Setup business hour'.tr),
                            onPressed: () {
                              Get.toNamed('/shop-time-table', arguments: {
                                "shop": dashBoardController.shop.value
                              });
                            },
                          ),
                          subtitle: AutoSizeText(
                            'Setting up business hours will automatically switch on at the designated times.'
                                .tr,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(
                    left: kDefaultPadding / 2,
                    right: kDefaultPadding / 2,
                    top: kDefaultPadding / 2),
                child: Card(
                  child: ListTile(
                    title: TextButton.icon(
                      onPressed: () {
                        Get.toNamed("/coupon-usage");
                      },
                      icon: const Icon(CupertinoIcons.qrcode),
                      label: Text(
                        'Coupon History'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(
                  left: kDefaultPadding / 2,
                  right: kDefaultPadding / 2,
                  top: kDefaultPadding / 2,
                ),
                width: getScreenWidth(),
                height: getScreenWidth() * 0.618,
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ListTile(
                        title: Text('Audience Size'.tr),
                        trailing: const Icon(CupertinoIcons.question_circle),
                      ),
                      Obx(
                        () => ListTile(
                          leading: const Icon(CupertinoIcons.person_3_fill),
                          title: Text(
                            dashBoardController.audienceSize.toString(),
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.info,
                              size: 18,
                            ),
                          ],
                        ),
                        minLeadingWidth: 9,
                        title: Text(
                          'Number of MaWaRoute users are nearby'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: kHintTextColor),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: kDefaultPadding / 2,
                    right: kDefaultPadding / 2,
                    top: kDefaultPadding / 2),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: getScreenWidth() * 0.618,
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ListTile(
                                title: Text('# Visits Today'.tr),
                              ),
                              Obx(
                                () => ListTile(
                                  leading: const Icon(CupertinoIcons.placemark),
                                  title: Text(
                                    dashBoardController.visitsToday.toString(),
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                              // ListTile(
                              //   title: OutlinedButton.icon(
                              //     onPressed: () {
                              //       Get.toNamed(
                              //           '/visitors/${Timeframe.today.name}');
                              //     },
                              //     icon: const Icon(
                              //       Icons.person_pin_outlined,
                              //       size: 12,
                              //     ),
                              //     label: AutoSizeText(
                              //       'Visitor Insight'.tr,
                              //       minFontSize: 9,
                              //       maxLines: 1,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: kDefaultPadding / 2,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: getScreenWidth() * 0.618,
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ListTile(
                                title: Text('# Token Balance'.tr),
                              ),
                              Obx(
                                () => ListTile(
                                  leading:
                                      const Icon(CupertinoIcons.creditcard),
                                  title: AutoSizeText(
                                    dashBoardController.credits.toString(),
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.info,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                minLeadingWidth: 3,
                                title: Text(
                                  '${'Around'.tr} 100 visits',
                                  style: const TextStyle(
                                      fontSize: 12, color: kHintTextColor),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: kDefaultPadding / 2,
                    right: kDefaultPadding / 2,
                    top: kDefaultPadding / 2),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: getScreenWidth() * 0.618,
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ListTile(
                                title: Text('# Purchases Today'.tr),
                              ),
                              Obx(
                                () => ListTile(
                                  leading: const Icon(CupertinoIcons.cart),
                                  title: Text(
                                    dashBoardController.purchasesToday
                                        .toString(),
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: kDefaultPadding / 2,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: getScreenWidth() * 0.618,
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ListTile(
                                title: AutoSizeText(
                                  '# Questionnaires Today'.tr,
                                  maxLines: 1,
                                ),
                              ),
                              Obx(
                                () => ListTile(
                                  leading: const Icon(
                                      CupertinoIcons.rectangle_paperclip),
                                  title: AutoSizeText(
                                    dashBoardController.credits.toString(),
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                              const ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.info,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                minLeadingWidth: 3,
                                title: Text(
                                  'Coming soon...',
                                  style: TextStyle(
                                      fontSize: 12, color: kHintTextColor),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: kDefaultPadding / 2,
                    right: kDefaultPadding / 2,
                    top: kDefaultPadding / 2),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: getScreenWidth() * 0.618,
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ListTile(
                                title: Text('# Visits This Month'.tr),
                              ),
                              Obx(
                                () => ListTile(
                                  leading: const Icon(CupertinoIcons.placemark),
                                  title: Text(
                                    dashBoardController.visitsThisMonth
                                        .toString(),
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                              // ListTile(
                              //   title: OutlinedButton.icon(
                              //     onPressed: () {
                              //       Get.toNamed(
                              //           '/visitors/${Timeframe.thisMonth.name}');
                              //     },
                              //     icon: const Icon(
                              //       Icons.person_pin_outlined,
                              //       size: 12,
                              //     ),
                              //     label: AutoSizeText(
                              //       'Visitor Insight'.tr,
                              //       minFontSize: 9,
                              //       maxLines: 1,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: kDefaultPadding / 2,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: getScreenWidth() * 0.618,
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ListTile(
                                title: Text('# Purchases This Month'.tr),
                              ),
                              Obx(
                                () => ListTile(
                                  leading: const Icon(CupertinoIcons.cart),
                                  title: Text(
                                    dashBoardController.purchasesThisMonth
                                        .toString(),
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(
                    left: kDefaultPadding / 2,
                    right: kDefaultPadding / 2,
                    top: kDefaultPadding / 2),
                child: Card(
                  child: ListTile(
                    title: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.creditcard_fill),
                      label: Text(
                        'Purchase Credits'.tr,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: kDefaultPadding * 3 * 1.618,
              ),
            )
          ],
        ),
      ),
    );
  }


  Future<dynamic> buildTurnOffDialog() {
    return SmartDialog.show(
      builder: (context) => Container(
        width: getScreenWidth(),
        height: getScreenWidth() / 1.618 / 1.168,
        margin: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            ListTile(
              title: Center(
                child: Text(
                  'You cannot turn off this feature now'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
