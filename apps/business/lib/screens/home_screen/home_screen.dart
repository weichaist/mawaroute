import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/screens/top_components/desktop/desktop_auth_sliver_appbar_v2.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';

import '../../controllers/place_checklist_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final exampleScrollController = ScrollController();
    return Title(
      title: 'MaWaRoute (マワルト)',
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
                            const SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: Center(
                                child: ListTile(
                                  title: Text(
                                    'MaWaRoute管理画面へようこそ！',
                                    style: TextStyle(fontSize: 27),
                                  ),
                                  subtitle: Text(
                                    'キャンペーン管理、店舗管理、報酬管理、アカウント管理など',
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              indent: kDefaultPadding,
                              endIndent: kDefaultPadding,
                            ),
                            //Sample campaigns
                            SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const ListTile(
                                    title: Text('はじめに'),
                                    subtitle: Text(
                                      'キャンペーンサンプルを確認しながら、初めてのキャンペーンを作成してみましょう',
                                    ),
                                  ),
                                  Expanded(
                                    child: Scrollbar(
                                      controller: exampleScrollController,
                                      thumbVisibility: true,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: kDefaultPadding / 1.618,
                                        ),
                                        child: ListView.builder(
                                          controller: exampleScrollController,
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.only(
                                            left: kDefaultPadding,
                                          ),
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                right: kDefaultPadding,
                                              ),
                                              child: AspectRatio(
                                                aspectRatio: 4 / 3,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: kPrimaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: const Icon(
                                                      CupertinoIcons.photo,
                                                      color: Colors.white,
                                                      size: 48,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Next steps in list view
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const ListTile(
                                  leading: Icon(
                                    CupertinoIcons.list_bullet_indent,
                                    color: kPrimaryColor,
                                  ),
                                  title: Text('次のステップ'),
                                  subtitle: Text('MaWaRouteを最大限に活用するためのコツ'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: kDefaultPadding / 1.618,
                                  ),
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: kDefaultPadding,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: kDefaultPadding / 1.618,
                                        ),
                                        child: Card(
                                          child: ListTile(
                                            leading: Text('${index + 1}.'),
                                            title: Text(nextSteps[index]),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: 3,
                                  ),
                                ),
                              ],
                            ),
                            // const ListTile(
                            //   leading: Icon(
                            //     CupertinoIcons.news,
                            //     color: kPrimaryColor,
                            //   ),
                            //   title: Text(
                            //     'ニュース',
                            //   ),
                            // ),
                            const Divider(
                              indent: kDefaultPadding,
                              endIndent: kDefaultPadding,
                            ),
                            ListTile(subtitle: Text('Checklist'.tr)),
                            const PlaceCheckList(),
                            const SizedBox(height: 300),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //News section
                  // SliverList(
                  //   delegate: SliverChildBuilderDelegate(
                  //     (context, index) {
                  //       return const Padding(
                  //         padding: EdgeInsets.only(
                  //           bottom: kDefaultPadding / 1.618,
                  //           left: kDefaultPadding,
                  //           right: kDefaultPadding,
                  //         ),
                  //         child: Card(
                  //           child: ListTile(),
                  //         ),
                  //       );
                  //     },
                  //     childCount: 5,
                  //   ),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceCheckList extends StatelessWidget {
  const PlaceCheckList({super.key});

  @override
  Widget build(BuildContext context) {
    PlaceCheckListController checkListController =
        PlaceCheckListController.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkListController.init();
    });
    return ListTile(
      subtitle: Obx(
        () => Column(
          children: [
            CheckboxListTile(
              activeColor: CupertinoColors.activeGreen,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.6),
              ),
              title: Text('Place Name'.tr),
              controlAffinity: ListTileControlAffinity.leading,
              value: checkListController.place.value.name.isNotEmpty,
              onChanged: (value) {
                Get.toNamed('/my-place');
              },
            ),
            CheckboxListTile(
              activeColor: CupertinoColors.activeGreen,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.6),
              ),
              title: Text('Place Address'.tr),
              controlAffinity: ListTileControlAffinity.leading,
              value: checkListController.place.value.address.isNotEmpty,
              onChanged: (value) {
                Get.toNamed('/my-place');
              },
            ),
            CheckboxListTile(
              activeColor: CupertinoColors.activeGreen,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.6),
              ),
              title: Text('Profile Image'.tr),
              controlAffinity: ListTileControlAffinity.leading,
              value: checkListController.place.value.profileUrl != "",
              onChanged: (value) {
                Get.toNamed('/my-place');
              },
            ),
            CheckboxListTile(
              activeColor: CupertinoColors.activeGreen,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.6),
              ),
              title: Text('List Image'.tr),
              controlAffinity: ListTileControlAffinity.leading,
              value: checkListController.place.value.downloadUrl != "",
              onChanged: (value) {
                Get.toNamed('/my-place');
              },
            ),
            CheckboxListTile(
              activeColor: CupertinoColors.activeGreen,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.6),
              ),
              title: Text(
                'Create at least one campaign or add more than 10 shops'.tr,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              value:
                  checkListController.firstCampaign.isTrue ||
                  checkListController.has10Shops.isTrue,
              onChanged: (value) {},
            ),
            Padding(
              padding: const EdgeInsets.only(top: kDefaultPadding),
              child: ListTile(
                leading: ElevatedButton(
                  onPressed: () async {
                    await checkListController.makePlacePublic();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => kPrimaryColor,
                    ),
                  ),
                  child: Text(
                    'Make Public'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> nextSteps = [
  '店舗を招待し、アカウントを発行しましょう',
  '店舗からの広告入金を待ちしましょう',
  'まわる to earnキャンペーンに、店舗を追加しましょう',
];
