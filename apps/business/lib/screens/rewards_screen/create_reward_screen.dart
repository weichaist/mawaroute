import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/rewards_controller.dart';
import 'package:mawaroute_business/enums.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';

import '../top_components/date_time_input.dart';
import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';
import '../top_components/upload_file_dotted_container.dart';
import 'components/build_shop_image_dialog.dart';

class CreateRewardScreen extends StatefulWidget {
  const CreateRewardScreen({super.key});

  @override
  State<CreateRewardScreen> createState() => _CreateRewardScreenState();
}

class _CreateRewardScreenState extends State<CreateRewardScreen> {
  @override
  Widget build(BuildContext context) {
    RewardController c = RewardController.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      c.init();
    });
    return Title(
      title: 'Create Rewards | MaWaRoute (マワルト)',
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
                        constraints: const BoxConstraints(maxWidth: kMaxWidth),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: Center(
                                child: ListTile(
                                  title: Text(
                                    'Create New Reward'.tr,
                                    style: const TextStyle(fontSize: 27),
                                  ),
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
                        constraints: const BoxConstraints(maxWidth: kMaxWidth),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ListTile(
                                    title: Text('Image (ratio 16:9)'.tr),
                                  ),
                                  Obx(
                                    () => UploadFileDottedContainer(
                                      file: c.imageFile.value,
                                      height: 300,
                                      width: 300 * 16 / 9,
                                      callback: (file) => c.changeImage(file),
                                    ),
                                  ),
                                  ListTile(
                                    title: TextField(
                                      controller: c.title.value,
                                      maxLength: 90,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText: 'Reward Title *'.tr,
                                        hintText:
                                            'Enter a descriptive reward title'
                                                .tr,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: TextField(
                                      controller: c.description.value,
                                      maxLength: 600,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText: 'Reward Description *'.tr,
                                        hintText:
                                            'Enter a description explaining the details of the reward'
                                                .tr,
                                      ),
                                    ),
                                  ),
                                  DateTimeInput(
                                    labelText: 'Start Time *'.tr,
                                    initialValue: c.startTime.value,
                                    onDateSelected: (value) {
                                      c.startTime.value = value;
                                    },
                                  ),
                                  DateTimeInput(
                                    labelText: 'End Time *'.tr,
                                    initialValue: c.endTime.value,
                                    onDateSelected: (value) {
                                      c.endTime.value = value;
                                    },
                                  ),
                                  const Divider(
                                    color: Colors.transparent,
                                  ),
                                  //Reward status
                                  ListTile(
                                    title: TextField(
                                      controller: c.status.value,
                                      enabled: false,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText: 'Status *'.tr,
                                        hintStyle:
                                            const TextStyle(color: kTextColor),
                                        prefixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        color: kPrimaryColor,
                                        radius: const Radius.circular(12),
                                        padding: const EdgeInsets.all(6),
                                      ),
                                      child: Column(
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: RewardType.values.length,
                                            itemBuilder: (context, index) {
                                              String targetStatus =
                                                  RewardType.values[index].name;
                                              return Obx(
                                                () => ListTile(
                                                  leading: IconButton(
                                                    icon: Icon(
                                                      targetStatus ==
                                                              c.selectedStatus
                                                                  .value
                                                          ? CupertinoIcons
                                                              .check_mark_circled
                                                          : CupertinoIcons
                                                              .circle,
                                                    ),
                                                    onPressed: () {
                                                      c.status.value.text =
                                                          targetStatus
                                                              .capitalize!.tr;
                                                      c.selectedStatus.value =
                                                          targetStatus;
                                                    },
                                                  ),
                                                  title: Text(targetStatus
                                                      .capitalizeFirst!.tr),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.transparent,
                                  ),
                                  //Reward Distribution Type
                                  ListTile(
                                    title: TextField(
                                      controller:
                                          c.rewardDistributionType.value,
                                      enabled: false,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText:
                                            'Reward Distribution Type *'.tr,
                                        hintStyle:
                                            const TextStyle(color: kTextColor),
                                        prefixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        color: kPrimaryColor,
                                        radius: const Radius.circular(12),
                                        padding: const EdgeInsets.all(6),
                                      ),
                                      child: Column(
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: RewardDistributionType
                                                .values.length,
                                            itemBuilder: (context, index) {
                                              String rewardDistributionType =
                                                  RewardDistributionType
                                                      .values[index].name;
                                              return Obx(
                                                () => ListTile(
                                                  leading: IconButton(
                                                    icon: Icon(
                                                      rewardDistributionType ==
                                                              c.selectedRewardDistributionType
                                                                  .value
                                                          ? CupertinoIcons
                                                              .check_mark_circled
                                                          : CupertinoIcons
                                                              .circle,
                                                    ),
                                                    onPressed: () {
                                                      c.rewardDistributionType
                                                              .value.text =
                                                          rewardDistributionType
                                                              .capitalize!.tr;
                                                      c.selectedRewardDistributionType
                                                              .value =
                                                          rewardDistributionType;
                                                    },
                                                  ),
                                                  title: Text(
                                                      rewardDistributionType
                                                          .capitalizeFirst!.tr),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => c.selectedRewardDistributionType
                                                .value ==
                                            RewardDistributionType.coupon.name
                                        ? ListTile(
                                            title: OutlinedButton(
                                              onPressed: () {
                                                buildShopListDialog(
                                                  context: context,
                                                  rewardController: c,
                                                );
                                              },
                                              //todo display shop name and add shop geohash
                                              child: c.selectedShop.value.uid ==
                                                          null ||
                                                      c.selectedShop.value
                                                              .uid ==
                                                          ""
                                                  ? Text("Select Shop".tr)
                                                  : Text(c
                                                      .selectedShop.value.name),
                                            ),
                                          )
                                        : const SizedBox(
                                            height: 0,
                                          ),
                                  ),
                                  const Divider(
                                    color: Colors.transparent,
                                  ),
                                  //Required Token Number
                                  ListTile(
                                    title: TextField(
                                      controller: c.tokenNumber.value,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText: 'Required Token Number *'.tr,
                                        hintText:
                                            'Enter the required token number'
                                                .tr,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: TextField(
                                      controller: c.upperLimit.value,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText: 'Upper Limit *'.tr,
                                        hintText:
                                            'Enter the required upper limit'.tr,
                                      ),
                                    ),
                                  ),
                                  //todo max number per user field
                                  ListTile(
                                    title: TextField(
                                      controller: c.maxNumberPerUser.value,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      maxLength: 5,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText: 'Max Number Per User *'.tr,
                                        hintText:
                                            'Enter the required max number per user'
                                                .tr,
                                      ),
                                    ),
                                  ),
                                  const ListTile(),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await c.onCreate();
                                          },
                                          child: Text(
                                            'Create Reward'.tr,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const ListTile(),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
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
