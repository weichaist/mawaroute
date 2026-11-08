import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/edit_campaing_v2_controller.dart';
import 'package:mawaroute_business/enums.dart';
import 'package:mawaroute_business/screens/campaigns_screen/edit_campaign_components/basic_info.dart';
import 'package:mawaroute_business/screens/campaigns_screen/edit_campaign_components/image_info.dart';
import 'package:mawaroute_business/screens/campaigns_screen/edit_campaign_components/target_user_group_info.dart';
import 'package:mawaroute_business/screens/campaigns_screen/edit_campaign_components/task_list_info.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/theme/size_config.dart';

import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class EditCampaignV2Screen extends StatelessWidget {
  const EditCampaignV2Screen({super.key});
  @override
  Widget build(BuildContext context) {
    EditCampaignV2Controller c = EditCampaignV2Controller.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.init();
    });
    SizeConfig().init(context);
    return Title(
      title: 'Campaign | MaWaRoute (マワルト)',
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
                                child: Obx(
                                  () => ListTile(
                                    leading: c.campaignToEdit.value.status !=
                                            CampaignStatus.active.name
                                        ? const Icon(
                                            CupertinoIcons
                                                .exclamationmark_circle_fill,
                                            color: kPrimaryColor,
                                          )
                                        : const Icon(
                                            Icons.radio_button_on,
                                            color: CupertinoColors.activeGreen,
                                          ),
                                    title: Text(
                                      'Edit Campaign'.tr,
                                      style: const TextStyle(fontSize: 27),
                                    ),
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
                        constraints: const BoxConstraints(
                          maxWidth: kMaxWidth,
                        ),
                        child: Column(
                          children: [
                            Obx(
                              () => AspectRatio(
                                aspectRatio: 6 / 1,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: kDefaultPadding,
                                  ),
                                  decoration: BoxDecoration(
                                      color: kPrimaryLightColor,
                                      borderRadius: BorderRadius.circular(9),
                                      image: c.campaignToEdit.value
                                                  .bannerDownloadUrl !=
                                              ''
                                          ? DecorationImage(
                                              image: NetworkImage(c
                                                  .campaignToEdit
                                                  .value
                                                  .bannerDownloadUrl),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(kDefaultPadding),
                              child: Row(
                                children: [
                                  FilterChip(
                                    label: Text('Setting'.tr),
                                    onSelected: (_) {},
                                    selected: true,
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  FilterChip(
                                    label: Text('Rankings'.tr),
                                    onSelected: (_) {
                                      SmartDialog.show(builder: (context) {
                                        return Container(
                                          height: getScreenHeight() / 1.2,
                                          width: 600,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white),
                                        );
                                      });
                                    },
                                    selected: false,
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  FilterChip(
                                    label: Text('Activities'.tr),
                                    onSelected: (_) {
                                      SmartDialog.show(builder: (context) {
                                        return Container(
                                          height: getScreenHeight() / 1.2,
                                          width: 600,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.white),
                                        );
                                      });
                                    },
                                    selected: false,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: kDefaultPadding * 3),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: kMaxWidth),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: kDefaultPadding),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: kHintTextColor),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        ListTile(
                                          selected: c.selectedTab.value == 0,
                                          selectedTileColor: kPrimaryLightColor
                                              .withValues(alpha: 0.3),
                                          title: Text('Basic Info'.tr),
                                          onTap: () {
                                            c.selectedTab.value = 0;
                                          },
                                        ),
                                        ListTile(
                                          selected: c.selectedTab.value == 1,
                                          selectedTileColor: kPrimaryLightColor
                                              .withValues(alpha: 0.3),
                                          title: Text('Image'.tr),
                                          onTap: () {
                                            c.selectedTab.value = 1;
                                          },
                                        ),
                                        ListTile(
                                          selected: c.selectedTab.value == 2,
                                          selectedTileColor: kPrimaryLightColor
                                              .withValues(alpha: 0.3),
                                          title: Text('Target User Group'.tr),
                                          onTap: () {
                                            c.selectedTab.value = 2;
                                          },
                                        ),
                                        ListTile(
                                          selected: c.selectedTab.value == 3,
                                          selectedTileColor: kPrimaryLightColor
                                              .withValues(alpha: 0.3),
                                          title: Text('Tasks'.tr),
                                          onTap: () {
                                            c.selectedTab.value = 3;
                                          },
                                        ),
                                        ListTile(
                                          selected: c.selectedTab.value == 4,
                                          selectedTileColor: kPrimaryLightColor
                                              .withValues(alpha: 0.3),
                                          title: Text('Checklist'.tr),
                                          onTap: () {
                                            c.selectedTab.value = 4;
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    color: kPrimaryLightColor.withValues(alpha: 0.09),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(kDefaultPadding),
                                      child: Obx(
                                        () => SelectedTab(
                                          selectedTabValue: c.selectedTab.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class SelectedTab extends StatelessWidget {
  final int selectedTabValue;
  const SelectedTab({
    super.key,
    required this.selectedTabValue,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTabValue == 0) {
      return const BasicInfo();
    } else if (selectedTabValue == 1) {
      return const ImageInfoSection();
    } else if (selectedTabValue == 2) {
      return const TargetUerGroupInfo();
    } else if (selectedTabValue == 3) {
      return const TasksListInfo();
    } else {
      return const CampaignChecklist();
    }
  }
}

class CampaignChecklist extends StatelessWidget {
  const CampaignChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    EditCampaignV2Controller c = EditCampaignV2Controller.instance;
    c.fetchCampaign();
    return Column(
      children: [
        CheckboxListTile(
          activeColor: CupertinoColors.activeGreen,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.6),
          ),
          title: Text('Basic Info'.tr),
          controlAffinity: ListTileControlAffinity.leading,
          value: c.basicInfoFlag.value,
          onChanged: (value) {},
        ),
        CheckboxListTile(
          activeColor: CupertinoColors.activeGreen,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.6),
          ),
          title: Text('Image'.tr),
          controlAffinity: ListTileControlAffinity.leading,
          value: c.imageInfoFlag.value,
          onChanged: (value) {},
        ),
        CheckboxListTile(
          activeColor: CupertinoColors.activeGreen,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.6),
          ),
          title: Text('Target User Group'.tr),
          controlAffinity: ListTileControlAffinity.leading,
          value: c.targetUerGroupInfo.value,
          onChanged: (value) {},
        ),
        CheckboxListTile(
          activeColor: CupertinoColors.activeGreen,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.6),
          ),
          title: Text('Tasks'.tr),
          controlAffinity: ListTileControlAffinity.leading,
          value: c.tasksListInfo.value,
          onChanged: (value) {},
        ),
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await c.launchCampaign();
                },
                icon: const Icon(CupertinoIcons.paperplane),
                label: Text('Launch'.tr),
              ),
              const SizedBox(width: kDefaultPadding),
              ElevatedButton.icon(
                onPressed: () async {
                  // await c.saveCampaignForLater();
                },
                icon: const Icon(CupertinoIcons.floppy_disk),
                label: Text('Save for later'.tr),
              ),
              const SizedBox(width: kDefaultPadding),
              ElevatedButton.icon(
                onPressed: () async {
                  await c.undoLaunchCampaign();
                },
                icon: const Icon(CupertinoIcons.return_icon),
                label: Text('Undo launch'.tr),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
