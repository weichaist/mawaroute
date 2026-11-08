import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/home_controller.dart';
import 'package:mawaroute_business/screens/top_components/desktop/desktop_auth_sliver_appbar_v2.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';

import '../../controllers/campaign_v2_controller.dart';
import '../../enums.dart';
import '../../models/campaign_model.dart';

class CampaignV2Screen extends StatelessWidget {
  const CampaignV2Screen({super.key});
  @override
  Widget build(BuildContext context) {
    final homeController = HomeController.instance;
    CampaignV2Controller campaignV2Controller = CampaignV2Controller.instance;
    campaignV2Controller.init();
    return Title(
      title: 'Campaigns | MaWaRoute (マワルト)'.tr,
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
                                    'Campaigns'.tr,
                                    style: const TextStyle(
                                      fontSize: 27,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Organize and manage your mawaru to earn campaign in your facility'
                                        .tr,
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: ElevatedButton(
                                onPressed: () {
                                  homeController.selectedIndex.value = 2;
                                  Get.toNamed('/campaign/create');
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith(
                                          (states) => kPrimaryColor),
                                ),
                                child: Text(
                                  'Create new campaign'.tr,
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
                              leading:
                                  const Icon(CupertinoIcons.radiowaves_right),
                              title: Text(
                                'My Campaigns'.tr,
                              ),
                            ),
                            Obx(
                              () => ListTile(
                                title: Row(
                                  children: [
                                    FilterChip(
                                      label: Text('Draft'.tr),
                                      selected: campaignV2Controller
                                              .selectedStatus.value ==
                                          CampaignStatus.draft.name,
                                      onSelected: (val) {
                                        if (val) {
                                          campaignV2Controller
                                                  .selectedStatus.value =
                                              CampaignStatus.draft.name;
                                          campaignV2Controller.fetchMyCampaigns(
                                              CampaignStatus.draft.name);
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      width: kDefaultPadding,
                                    ),
                                    FilterChip(
                                      label: Text('Active'.tr),
                                      selected: campaignV2Controller
                                              .selectedStatus.value ==
                                          CampaignStatus.active.name,
                                      onSelected: (val) {
                                        if (val) {
                                          campaignV2Controller
                                                  .selectedStatus.value =
                                              CampaignStatus.active.name;
                                          campaignV2Controller.fetchMyCampaigns(
                                              CampaignStatus.active.name);
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      width: kDefaultPadding,
                                    ),
                                    FilterChip(
                                      label: Text('Completed'.tr),
                                      selected: campaignV2Controller
                                              .selectedStatus.value ==
                                          CampaignStatus.inActive.name,
                                      onSelected: (val) {
                                        if (val) {
                                          campaignV2Controller
                                                  .selectedStatus.value =
                                              CampaignStatus.inActive.name;
                                          campaignV2Controller.fetchMyCampaigns(
                                              CampaignStatus.inActive.name);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Obx(
                              () => GridView.extent(
                                maxCrossAxisExtent: 300,
                                padding: const EdgeInsets.all(kDefaultPadding),
                                mainAxisSpacing: kDefaultPadding,
                                crossAxisSpacing: kDefaultPadding,
                                childAspectRatio: 3 / 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  ...List.generate(
                                    campaignV2Controller.myCampaigns.length,
                                    (index) {
                                      CampaignModel campaign =
                                          campaignV2Controller
                                              .myCampaigns[index];
                                      return CampaignListCard(
                                          campaign: campaign);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SliverToBoxAdapter(
                  //   child: Center(
                  //     child: ConstrainedBox(
                  //       constraints: const BoxConstraints(
                  //         maxWidth: kMaxWidth,
                  //       ),
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //         children: [
                  //           const ListTile(),
                  //           const ListTile(
                  //             leading: Icon(CupertinoIcons.guitars),
                  //             title: Text(
                  //               'Active Campaigns',
                  //             ),
                  //             trailing: Text('See more'),
                  //           ),
                  //           Obx(
                  //             () => GridView.extent(
                  //               maxCrossAxisExtent: 300,
                  //               padding: const EdgeInsets.all(kDefaultPadding),
                  //               mainAxisSpacing: kDefaultPadding,
                  //               crossAxisSpacing: kDefaultPadding,
                  //               childAspectRatio: 3 / 4,
                  //               shrinkWrap: true,
                  //               physics: const NeverScrollableScrollPhysics(),
                  //               children: [
                  //                 ...List.generate(
                  //                   campaignV2Controller.activeCampaigns.length,
                  //                   (index) {
                  //                     CampaignModel campaign =
                  //                         campaignV2Controller
                  //                             .activeCampaigns[index];
                  //                     return CampaignListCard(
                  //                         campaign: campaign);
                  //                   },
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SliverToBoxAdapter(
                  //   child: Center(
                  //     child: ConstrainedBox(
                  //       constraints: const BoxConstraints(
                  //         maxWidth: kMaxWidth,
                  //       ),
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //         children: [
                  //           const ListTile(),
                  //           const ListTile(
                  //             leading: Icon(CupertinoIcons.clock),
                  //             title: Text(
                  //               'Recent Completed Campaigns',
                  //             ),
                  //             trailing: Text('See more'),
                  //           ),
                  //           Obx(
                  //             () => GridView.extent(
                  //               maxCrossAxisExtent: 300,
                  //               padding: const EdgeInsets.all(kDefaultPadding),
                  //               mainAxisSpacing: kDefaultPadding,
                  //               crossAxisSpacing: kDefaultPadding,
                  //               childAspectRatio: 3 / 4,
                  //               shrinkWrap: true,
                  //               physics: const NeverScrollableScrollPhysics(),
                  //               children: [
                  //                 ...List.generate(
                  //                   campaignV2Controller
                  //                       .recentlyCompletedCampaigns.length,
                  //                   (index) {
                  //                     CampaignModel campaign =
                  //                         campaignV2Controller
                  //                                 .recentlyCompletedCampaigns[
                  //                             index];
                  //                     return CampaignListCard(
                  //                         campaign: campaign);
                  //                   },
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CampaignListCard extends StatelessWidget {
  const CampaignListCard({
    super.key,
    required this.campaign,
  });

  final CampaignModel campaign;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/campaign/${campaign.uid}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: kPrimaryLightColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    topLeft: Radius.circular(12),
                  ),
                  image: campaign.downloadUrl != ""
                      ? DecorationImage(
                          image: NetworkImage(campaign.downloadUrl),
                          fit: BoxFit.cover)
                      : null,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ListTile(
                  title: Text(campaign.title),
                  trailing: const Icon(Icons.more_vert),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
