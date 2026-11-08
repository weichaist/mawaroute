import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/enums.dart';
import 'package:mawaroute_business/models/reward_model.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/utility.dart';

import '../../controllers/rewards_controller.dart';
import '../../theme/size_config.dart';
import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController _ = AuthController.instance;
    RewardController c = RewardController.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      c.initList();
    });
    SizeConfig().init(context);
    return Title(
      title: 'Rewards | MaWaRoute (マワルト)',
      color: kPrimaryColor,
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          Get.offAllNamed('/home');
        },
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
                          constraints:
                              const BoxConstraints(maxWidth: kMaxWidth),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 180,
                                width: double.infinity,
                                child: Center(
                                  child: ListTile(
                                    title: Text(
                                      'Rewards'.tr,
                                      style: const TextStyle(fontSize: 27),
                                    ),
                                    subtitle: Text(
                                      'Give your users some surprising rewards!'
                                          .tr,
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: ElevatedButton(
                                  onPressed: () {
                                    Get.toNamed('/rewards/create');
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith(
                                            (states) => kPrimaryColor),
                                  ),
                                  child: Text(
                                    'Create Your Reward'.tr,
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
                                title: Text('My Rewards'.tr),
                              ),
                              ListTile(
                                title: Row(
                                  children: [
                                    Obx(
                                      () => FilterChip(
                                        label: Text('Active'.tr),
                                        selected: c.selectedStatus.value ==
                                            RewardType.active.name,
                                        onSelected: (val) async {
                                          if (val) {
                                            c.selectedStatus.value =
                                                RewardType.active.name;
                                            await c.fetchRewards(
                                                c.selectedStatus.value);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Obx(
                                      () => FilterChip(
                                        label: Text('Archive'.tr),
                                        selected: c.selectedStatus.value ==
                                            RewardType.archive.name,
                                        onSelected: (val) async {
                                          if (val) {
                                            c.selectedStatus.value =
                                                RewardType.archive.name;
                                            await c.fetchRewards(
                                                c.selectedStatus.value);
                                          }
                                        },
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
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18, right: 18),
                        child: ListTile(
                          leading: const SizedBox(
                            width: 90,
                            child: Center(child: Text('📷')),
                          ),
                          minVerticalPadding: 27.0,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text('Title'.tr),
                              ),
                              Expanded(
                                child: Text('Start Date Time'.tr),
                              ),
                              Expanded(
                                child: Text('Required Token Number'.tr),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => SliverPadding(
                        padding: const EdgeInsets.only(
                            bottom: 120, left: 18, right: 18),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              RewardModel reward = c.rewards[index];
                              return GestureDetector(
                                child: Card(
                                  child: ListTile(
                                    onTap: () {
                                      Get.toNamed("/rewards/${reward.uid}");
                                    },
                                    minVerticalPadding: 27.0,
                                    leading: SizedBox(
                                      width: 90,
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: ExtendedImage.network(
                                          reward.downloadUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(child: Text(reward.title)),
                                        Expanded(
                                          child: Text(
                                              dateString(reward.startTime)),
                                        ),
                                        Expanded(
                                          child: Text(
                                              reward.tokenNumber.toString()),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () async {
                                        c.initRewardReceivers(reward.uid!);
                                        c.fetchRewardReceivers();
                                        buildRewardReceivers(
                                          context: context,
                                          rewardController: c,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: c.rewards.length,
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
      ),
    );
  }
}

Future buildRewardReceivers({
  required BuildContext context,
  required RewardController rewardController,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Reward Receivers'.tr),
          const Spacer(),
          TextButton(
            onPressed: () {
              rewardController.exportCSVRewardReceivers();
            },
            child: const Text('Export as CSV'),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 900, minWidth: 600),
        margin: const EdgeInsets.only(
          left: kDefaultPadding / 2,
          right: kDefaultPadding / 2,
          top: kDefaultPadding / 2,
        ),
        // width: 600,
        height: getScreenHeight() / 1.2,
        child: SingleChildScrollView(
          child: Obx(
            () => Column(
              children: [
                DataTable(
                  columns: [
                    DataColumn(label: Text('利用状況'.tr)),
                    DataColumn(label: Text('Email'.tr)),
                    DataColumn(label: Text('# Token'.tr)),
                    DataColumn(label: Text('Timestamp'.tr)),
                  ],
                  rows: rewardController.rewardReceivers.value.results
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(item.applied
                                ? const Text('使用済み')
                                : const Text('')),
                            DataCell(item.email.isNotEmpty
                                ? Text(item.email)
                                : Text(item.uid!.substring(0, 4))),
                            DataCell(Text("${item.tokenTransferred}")),
                            DataCell(Text(dateString(item.timestamp))),
                          ],
                        ),
                      )
                      .toList(),
                ),
                if (!rewardController.rewardReceivers.value.isLast)
                  TextButton(
                      onPressed: () async {
                        await rewardController.fetchRewardReceivers();
                      },
                      child: Text("Load More".tr)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
