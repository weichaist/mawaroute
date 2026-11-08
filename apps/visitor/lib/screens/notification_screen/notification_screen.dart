import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/notification_controller.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/utilis/formatter.dart';
import 'package:mawaroute_visitor/utilis/launch_urls.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationController notificationController = NotificationController();
    notificationController.init();
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: kPrimaryColor,
        color: Colors.white,
        displacement: 96,
        onRefresh: () async {
          HapticFeedback.heavyImpact();
          await notificationController.init();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(title: Text('📰 News & Updates'.tr)),
            Obx(
              () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final news = notificationController
                        .mawarouteNews
                        .value
                        .results[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await launchNewsUrl(news.link);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            minLeadingWidth: 12,
                            leading: Text(
                              news.leadingIcon,
                              style: const TextStyle(fontSize: 18),
                            ),
                            trailing: Text(formatTimeAgo(news.timestamp)),
                            title: Text(news.title),
                            subtitle: Text(news.body),
                          ),
                        ),
                        const Divider(
                          height: 0,
                          indent: kDefaultPadding,
                          endIndent: kDefaultPadding,
                        ),
                      ],
                    );
                  },
                  childCount:
                      notificationController.mawarouteNews.value.results.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: kDefaultPadding),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      notificationController.mawarouteNews.value.isLast == false
                          ? ElevatedButton(
                              onPressed: () async {
                                await notificationController
                                    .listMawarouteNews();
                              },
                              child: const Text('More'),
                            )
                          : const SizedBox(height: 0),
                    ],
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
