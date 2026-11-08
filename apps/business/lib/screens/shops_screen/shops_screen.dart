import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/shops_controller.dart';
import 'package:mawaroute_business/enums.dart';
import 'package:mawaroute_business/models/place_shop_user_model.dart';
import 'package:mawaroute_business/models/shop_model.dart';
import 'package:mawaroute_business/screens/top_components/desktop/desktop_auth_sliver_appbar_v2.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/theme/size_config.dart';
import 'package:mawaroute_business/utility.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    ShopsScreenController shopsScreenController =
        ShopsScreenController.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (shopsScreenController.isLoading.isFalse) {
        shopsScreenController.isLoading.value = true;
        await shopsScreenController.init();
        shopsScreenController.isLoading.value = false;
      }
    });
    SizeConfig().init(context);
    //todo add shop qr code in detail dialog
    return Title(
      title: 'Shops | Mawaroute (マワルト)'.tr,
      color: kPrimaryColor,
      child: Scaffold(
        body: Row(
          children: [
            const V2AdminNavRail(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const DesktopAuthSliverAppBarV2(),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: kMaxWidth,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: Center(
                                child: ListTile(
                                  title: Text(
                                    'Shops'.tr,
                                    style: const TextStyle(
                                      fontSize: 27,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Invite shops to join MaWaRoute'.tr,
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: ElevatedButton(
                                onPressed: () async {
                                  await buildSendEmailDialog(
                                      context, shopsScreenController);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith(
                                          (states) => kPrimaryColor),
                                ),
                                child: Text(
                                  'Send New Invitation'.tr,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: kMaxWidth,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const ListTile(),
                            ListTile(
                              leading: const Icon(CupertinoIcons
                                  .person_crop_circle_fill_badge_checkmark),
                              title: Text(
                                'View Shops'.tr,
                              ),
                            ),
                            Obx(
                              () => ListTile(
                                title: Row(
                                  children: [
                                    FilterChip(
                                      label: Text('Onboarded'.tr),
                                      selected: shopsScreenController
                                              .selectedTab.value ==
                                          "onboarded",
                                      onSelected: (val) async {
                                        shopsScreenController
                                            .selectedTab.value = "onboarded";
                                        await shopsScreenController.fetchData();
                                      },
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    FilterChip(
                                      label: Text('Invitation Sent'.tr),
                                      selected: shopsScreenController
                                              .selectedTab.value ==
                                          "invitation_sent",
                                      onSelected: (val) async {
                                        shopsScreenController.selectedTab
                                            .value = "invitation_sent";
                                        await shopsScreenController.fetchData();
                                      },
                                    ),
                                    const SizedBox(
                                      width: kDefaultPadding,
                                    ),
                                    FilterChip(
                                      label: Text('Paid'.tr),
                                      selected: shopsScreenController
                                              .selectedTab.value ==
                                          "paid",
                                      onSelected: (_) async {
                                        shopsScreenController
                                            .selectedTab.value = "paid";
                                        await shopsScreenController.fetchData();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Obx(
                              () => shopsScreenController.selectedTab.value ==
                                      "onboarded"
                                  ? buildShopTab(context, shopsScreenController)
                                  : shopsScreenController.selectedTab.value ==
                                          "invitation_sent"
                                      ? buildShopUserTab(shopsScreenController)
                                      : buildPaidShopTab(
                                          context, shopsScreenController),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Obx buildShopTab(
    BuildContext context, ShopsScreenController shopsScreenController) {
  return Obx(
    () => GridView.extent(
      maxCrossAxisExtent: 300,
      padding: const EdgeInsets.all(kDefaultPadding),
      mainAxisSpacing: kDefaultPadding,
      crossAxisSpacing: kDefaultPadding,
      childAspectRatio: 4 / 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...List.generate(
          shopsScreenController.shops.value.results.length,
          (index) {
            ShopModel shop = shopsScreenController.shops.value.results[index];
            return GestureDetector(
              onTap: () {
                shopsScreenController.fetchShopCountData(shopUid: shop.uid!);
                buildShopStatistics(
                  context: context,
                  shopsScreenController: shopsScreenController,
                  shop: shop,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimaryColor),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(kDefaultPadding),
                          child: Center(
                            child: ExtendedImage.network(
                              shop.downloadUrl!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.place_outlined,
                        color: kPrimaryColor,
                      ),
                      title: SelectableText(shop.name),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Obx buildPaidShopTab(
    BuildContext context, ShopsScreenController shopsScreenController) {
  return Obx(
    () => GridView.extent(
      maxCrossAxisExtent: 300,
      padding: const EdgeInsets.all(kDefaultPadding),
      mainAxisSpacing: kDefaultPadding,
      crossAxisSpacing: kDefaultPadding,
      childAspectRatio: 4 / 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...List.generate(
          shopsScreenController.paidShops.value.results.length,
          (index) {
            ShopModel shop =
                shopsScreenController.paidShops.value.results[index];
            return GestureDetector(
              onTap: () {
                shopsScreenController.fetchShopCountData(shopUid: shop.uid!);
                buildShopStatistics(
                  context: context,
                  shopsScreenController: shopsScreenController,
                  shop: shop,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimaryColor),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(kDefaultPadding),
                          child: Center(
                            child: ExtendedImage.network(
                              shop.downloadUrl!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.place_outlined,
                        color: kPrimaryColor,
                      ),
                      title: Text(shop.name),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Future buildShopStatistics({
  required BuildContext context,
  required ShopsScreenController shopsScreenController,
  required ShopModel shop,
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Shop Statistics'.tr),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Container(
        margin: const EdgeInsets.only(
          left: kDefaultPadding / 2,
          right: kDefaultPadding / 2,
          top: kDefaultPadding / 2,
        ),
        width: 510,
        height: getScreenHeight() / 1.2,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ListTile(
                      title: Text('# Credits Left'.tr),
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.creditcard),
                      title: AutoSizeText(
                        shopsScreenController.credits.toString(),
                        maxLines: 1,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    // ListTile(
                    //   leading: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: const [
                    //       Icon(
                    //         CupertinoIcons.info,
                    //         size: 18,
                    //       ),
                    //     ],
                    //   ),
                    //   minLeadingWidth: 3,
                    //   title: const Text(
                    //     'Around 100 visits',
                    //     style: TextStyle(fontSize: 12, color: kHintTextColor),
                    //   ),
                    // )
                  ],
                ),
              ),
              Card(
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
                          shopsScreenController.shopVisitsCountByDay.toString(),
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    // ListTile(
                    //   leading: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: const [
                    //       Icon(
                    //         CupertinoIcons.chart_bar_circle,
                    //         size: 18,
                    //       ),
                    //     ],
                    //   ),
                    //   minLeadingWidth: 3,
                    //   title: GestureDetector(
                    //     onTap: () {},
                    //     child: const Text(
                    //       'View visits',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: kHintTextColor,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ListTile(
                      title: Text('# Visits of Month'.tr),
                    ),
                    Obx(
                      () => ListTile(
                        leading: const Icon(CupertinoIcons.placemark),
                        title: Text(
                          shopsScreenController.shopVisitsCountByMonth
                              .toString(),
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    // ListTile(
                    //   leading: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: const [
                    //       Icon(
                    //         CupertinoIcons.chart_bar_circle,
                    //         size: 18,
                    //       ),
                    //     ],
                    //   ),
                    //   minLeadingWidth: 3,
                    //   title: GestureDetector(
                    //     onTap: () {},
                    //     child: const Text(
                    //       'View visits',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: kHintTextColor,
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ListTile(
                      title: Text('# Total Visits'.tr),
                    ),
                    Obx(
                      () => ListTile(
                        leading: const Icon(CupertinoIcons.placemark),
                        title: Text(
                          shopsScreenController.totalShopVisitsCount.toString(),
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    // ListTile(
                    //   leading: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: const [
                    //       Icon(
                    //         CupertinoIcons.chart_bar_circle,
                    //         size: 18,
                    //       ),
                    //     ],
                    //   ),
                    //   minLeadingWidth: 3,
                    //   title: GestureDetector(
                    //     onTap: () {},
                    //     child: const Text(
                    //       'View visits',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: kHintTextColor,
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
              Obx(
                () => Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ListTile(
                        title: Text('# Shop Purchases Count By Day'.tr),
                      ),
                      ListTile(
                        leading: const Icon(CupertinoIcons.placemark),
                        title: Text(
                          shopsScreenController.shopPurchasesCountByDay
                              .toString(),
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                      // ListTile(
                      //   leading: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: const [
                      //       Icon(
                      //         CupertinoIcons.chart_bar_circle,
                      //         size: 18,
                      //       ),
                      //     ],
                      //   ),
                      //   minLeadingWidth: 3,
                      //   title: GestureDetector(
                      //     onTap: () {},
                      //     child: const Text(
                      //       'View purchases',
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //         color: kHintTextColor,
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
              Obx(
                () => Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ListTile(
                        title: Text('# Shop Purchases Count By Month'.tr),
                      ),
                      ListTile(
                        leading: const Icon(CupertinoIcons.placemark),
                        title: Text(
                          shopsScreenController.shopPurchasesCountByMonth
                              .toString(),
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                      // ListTile(
                      //   leading: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: const [
                      //       Icon(
                      //         CupertinoIcons.chart_bar_circle,
                      //         size: 18,
                      //       ),
                      //     ],
                      //   ),
                      //   minLeadingWidth: 3,
                      //   title: GestureDetector(
                      //     onTap: () {},
                      //     child: const Text(
                      //       'View purchases',
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //         color: kHintTextColor,
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ListTile(
                      title: Text('# Total purchases'.tr),
                    ),
                    Obx(
                      () => ListTile(
                        leading: const Icon(CupertinoIcons.placemark),
                        title: Text(
                          shopsScreenController.shopPurchasesCountTotal
                              .toString(),
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    // ListTile(
                    //   leading: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: const [
                    //       Icon(
                    //         CupertinoIcons.chart_bar_circle,
                    //         size: 18,
                    //       ),
                    //     ],
                    //   ),
                    //   minLeadingWidth: 3,
                    //   title: GestureDetector(
                    //     onTap: () {},
                    //     child: const Text(
                    //       'View visits',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: kHintTextColor,
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ListTile(
                      title: Text('# QR Code'.tr),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 9.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (shopsScreenController
                                        .doesShopQrCodeExist.value ==
                                    true) {
                                  return;
                                }
                                await shopsScreenController.addShopQrCode(
                                    shopUid: shop.uid!);
                              },
                              child: Text('Generate'.tr),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (shopsScreenController
                                        .doesShopQrCodeExist.value !=
                                    true) {
                                  return;
                                }
                                await shopsScreenController.downloadQrCode(
                                    shopName: shop.name);
                              },
                              child: Text('Download'.tr),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Obx(
                      () => ListTile(
                        title: shopsScreenController
                                    .doesShopQrCodeExist.value ==
                                true
                            ? QrImageView(
                                data: shopsScreenController.qrCodeData.value,
                                version: QrVersions.auto,
                                size: shopsScreenController.qrSize,
                                gapless: false,
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Obx buildShopUserTab(ShopsScreenController shopsScreenController) {
  return Obx(
    () => SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...List.generate(
            shopsScreenController.users.value.results.length + 1,
            (index) {
              if (index == shopsScreenController.users.value.results.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: kDefaultPadding,
                      horizontal: kDefaultPadding * 3),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (shopsScreenController.users.value.isLast) {
                        showToast('All data fetched'.tr);
                      }
                      await shopsScreenController.listShopUsers();
                    },
                    child: const Text('More'),
                  ),
                );
              }
              PlaceShopUserModel user =
                  shopsScreenController.users.value.results[index];
              IconData buildShopStatusEmoji(String status) {
                if (status == ShopStatusType.sent.name) {
                  return Icons.attach_email;
                }
                if (status == ShopStatusType.onBoarded.name) {
                  return Icons.app_registration;
                }
                if (status == ShopStatusType.published.name) {
                  return Icons.broadcast_on_personal;
                } else {
                  return Icons.report_gmailerrorred;
                }
              }

              return Card(
                child: ListTile(
                  leading: Icon(
                    buildShopStatusEmoji(user.status),
                  ),
                  trailing: Text(
                    user.status.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: Text(user.email),
                  subtitle: Text(user.timestamp.toString()),
                ),
              );
              // return Row(
              //   children: [
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Text(user.email),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Text(user.status),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Text(user.timestamp.toString()),
              //     ),
              //   ],
              // );
            },
          ),
        ],
      ),
    ),
  );
}

Future buildSendEmailDialog(
  BuildContext context,
  ShopsScreenController shopsScreenController,
) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Enter Your Email'.tr),
      content: TextFormField(
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) => shopsScreenController.shopEmail.value = value,
        decoration: InputDecoration(
          hintText: 'Email Address'.tr,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'.tr),
        ),
        ElevatedButton(
          onPressed: () async {
            if (shopsScreenController.shopEmail.value.isEmail) {
              await shopsScreenController.sendShopEmail(
                  email: shopsScreenController.shopEmail.value);
              Get.back();
            }
          },
          child: Text('Submit'.tr),
        ),
      ],
    ),
  );
}
