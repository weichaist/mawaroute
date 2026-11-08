import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/screens/top_level_components/common_widgets/section_title_list_tile.dart';
import 'package:mawaroute_visitor/screens/top_level_components/common_widgets/single_click_elevated_button.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';

import '../../../controllers/reward_home_screen_controller.dart';

class CashBackReward extends StatelessWidget {
  const CashBackReward({super.key});

  @override
  Widget build(BuildContext context) {
    RewardHomeScreenController c = RewardHomeScreenController.instance;
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SectionTitleListTile(title: '💰Cashback'.tr),
          SizedBox(
            height: getScreenWidth() / 1.5 * 1.35,
            child: ListView.builder(
              itemCount: c.topRewards.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final topReward = c.topRewards[index];
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
                          Stack(
                            children: [
                              ExtendedImage.network(
                                topReward.bgUrl,
                                fit: BoxFit.fitWidth,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child:
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                        const Text(
                                          '10~50',
                                          style: TextStyle(
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
                          ListTile(
                            title: AutoSizeText(
                              topReward.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: AutoSizeText(
                              topReward.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          ListTile(
                            title: SingleClickElevatedButton(
                              child: Text('Get'.tr),
                              onPressed: () async {
                                Get.toNamed("/cashback/${topReward.uid}");
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
