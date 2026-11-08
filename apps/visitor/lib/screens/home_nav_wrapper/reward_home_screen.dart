import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/screens/home_nav_wrapper/components/cash_back_reward.dart';
import 'package:mawaroute_visitor/screens/top_level_components/common_widgets/section_title_list_tile.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';

import '../../controllers/reward_home_screen_controller.dart';
import '../../models/reward_model.dart';
import '../../utilis/launch_urls.dart';
import '../../config/app_config.dart';

class RewardHomeScreen extends StatelessWidget {
  const RewardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    RewardHomeScreenController c = RewardHomeScreenController.instance;
    c.init();
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
            SliverAppBar(title: AutoSizeText('Rewards'.tr, maxLines: 1)),
            if (AppConfig.questionnaireUrl.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const Divider(color: Colors.transparent),
                    Card(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/cool_bg.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            launchNewsUrl(AppConfig.questionnaireUrl);
                          },
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ExtendedImage.asset(
                                'assets/images/guru_guru_coin.png',
                                height: 36,
                              ),
                            ],
                          ),
                          title: const AutoSizeText(
                            'ここからアンケートに答えて、10GGMTトークンゲットしよう！',
                            maxLines: 2,
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              CupertinoIcons.link_circle,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              launchNewsUrl(AppConfig.questionnaireUrl);
                            },
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.transparent),
                  ],
                ),
              ),
            Obx(
              () => c.topRewards.isNotEmpty
                  ? const CashBackReward()
                  : const SliverToBoxAdapter(child: SizedBox(height: 0)),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const Divider(color: Colors.transparent),
                  SectionTitleListTile(title: 'Get limited rewards'.tr),
                ],
              ),
            ),
            Obx(
              () => SliverToBoxAdapter(
                child: SizedBox(
                  height: getScreenWidth() / 1.5 * 1.35,
                  child: ListView.builder(
                    itemCount: c.emailOnSpotRewards.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final reward = c.emailOnSpotRewards[index];
                      return OutlinedRewardListCard(reward: reward);
                    },
                  ),
                ),
              ),
            ),
            Obx(
              () => SliverToBoxAdapter(
                child: c.couponRewards.isNotEmpty
                    ? Column(
                        children: [
                          const Divider(color: Colors.transparent),
                          SectionTitleListTile(title: 'Get coupon rewards'.tr),
                        ],
                      )
                    : const SizedBox(height: 0),
              ),
            ),
            Obx(
              () => SliverToBoxAdapter(
                child: SizedBox(
                  height: getScreenWidth() / 1.5 * 1.35,
                  child: ListView.builder(
                    itemCount: c.couponRewards.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final reward = c.couponRewards[index];
                      return OutlinedRewardListCard(reward: reward);
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: kDefaultPadding * 3 * 1.618),
            ),
          ],
        ),
      ),
    );
  }
}

class OutlinedRewardListCard extends StatelessWidget {
  const OutlinedRewardListCard({super.key, required this.reward});

  final RewardModel reward;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: kDefaultPadding / 2,
        bottom: kDefaultPadding / 2,
      ),
      child: Card(
        child: Container(
          width: getScreenWidth() / 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed('/rewards/${reward.uid}');
                },
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        width: getScreenWidth(),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: ExtendedNetworkImageProvider(
                              reward.downloadUrl,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child:
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ExtendedImage.asset(
                                'assets/images/guru_guru_coin.png',
                                height: 36,
                              ),
                              Text(
                                '#Token required'.tr,
                                style: const TextStyle(
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                reward.tokenNumber.toString(),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ).frosted(
                            padding: const EdgeInsets.all(3.0),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: AutoSizeText(
                  reward.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: AutoSizeText(
                  reward.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ListTile(
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '${'Limited to'.tr} ${reward.upperLimit.toString()}',
                      maxLines: 1,
                    ),
                    DateTime.now().isBefore(reward.endTime)
                        ? AutoSizeText(
                            '${reward.startTime.toString().split(' ')[0]} (${reward.endTime.difference(reward.startTime).inDays + 1} ${'days'.tr})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                          )
                        : AutoSizeText(
                            'The reward is now closed'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                          ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/rewards/${reward.uid}');
                  },
                  child: Text('Get'.tr),
                ),
              ),
              // const Divider(
              //   color: Colors.transparent,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
