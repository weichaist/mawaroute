import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/news_controller.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/theme/size_config.dart';

import '../../models/mawaroute_news_model.dart';
import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    NewsController c = NewsController.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (c.isLoading.isFalse) {
        c.isLoading.value = true;
        await c.init();
        c.isLoading.value = false;
      }
    });
    SizeConfig().init(context);
    return Title(
      title: 'News | MaWaRoute (マワルト)',
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
                                      'Notifications'.tr,
                                      style: const TextStyle(fontSize: 27),
                                    ),
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: ElevatedButton(
                                  onPressed: () {
                                    Get.toNamed('/news/create');
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith(
                                            (states) => kPrimaryColor),
                                  ),
                                  child: Text(
                                    'Create News'.tr,
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
                                leading: const Icon(CupertinoIcons.news),
                                title: Text('Latest News'.tr),
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
                          minVerticalPadding: 27.0,
                          title: Row(
                            children: [
                              Expanded(child: Text('News title'.tr)),
                              Expanded(child: Text('News body'.tr)),
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
                              MawarouteNewsModel news =
                                  c.news.value.results[index];
                              return Card(
                                child: ListTile(
                                  minVerticalPadding: 27.0,
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(news.title)),
                                      Expanded(
                                        child: Text(news.body),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () async {
                                      Get.toNamed(
                                        '/news/${news.uid}',
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: c.news.value.results.length,
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
