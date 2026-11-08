import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';
import 'package:mawaroute_visitor/utilis/formatter.dart';
import 'package:mawaroute_visitor/utilis/launch_urls.dart';

import '../../controllers/ai_character_list_controller.dart';
import '../../models/m_avatar_model.dart';
import '../../config/app_config.dart';

class V3HomeScreen extends StatelessWidget {
  const V3HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    AICharacterListController c = AICharacterListController.instance;
    c.init();
    return Scaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      body: RefreshIndicator(
        backgroundColor: kPrimaryColor,
        color: Colors.white,
        displacement: 96,
        onRefresh: () async {
          HapticFeedback.heavyImpact();
          await c.init();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(34.397766, 132.457482),
                initialZoom: 15.6,
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConfig.mapboxAccessToken.isNotEmpty
                      ? 'https://api.mapbox.com/styles/v1/${AppConfig.mapboxStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token=${AppConfig.mapboxAccessToken}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.acuri.mawaroute_v2e',
                ),
              ],
            ),
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (c.isLoading.isFalse &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  c.addMore();
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    centerTitle: false,
                    backgroundColor: Colors.transparent,
                    title: Image.asset(
                      'assets/images/mawaroute_text.png',
                      height: 24,
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 9.0, bottom: 9.0),
                        child:
                            IconButton(
                              onPressed: () {
                                Get.toNamed('/notification');
                              },
                              icon: const Icon(
                                CupertinoIcons.bell_circle,
                                color: Colors.white,
                              ),
                            ).frosted(
                              borderRadius: BorderRadius.circular(30),
                              frostColor: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 54,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 9.0),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                              right: kDefaultPadding / 2,
                              bottom: kDefaultPadding / 2,
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                await c.setValue(index);
                                if (c.characters.isEmpty) {
                                  await c.fetchData();
                                }
                              },
                              child: Obx(
                                () =>
                                    Text(
                                      c.filterChips[index].tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ).frosted(
                                      frostColor: index == c.selectedChip.value
                                          ? kPrimaryColor
                                          : Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                              ),
                            ),
                          );
                        },
                        itemCount: c.filterChips.length,
                      ),
                    ),
                  ),
                  Obx(
                    () => SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        MAvatarModel avatar = c.characters[index];
                        return Container(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Card(
                            margin: const EdgeInsets.only(
                              left: 3.6,
                              right: 3.6,
                              top: 3.6,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed("/chat_rec_screen/${avatar.id}");
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 618,
                                    child: FittedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage:
                                                  ExtendedNetworkImageProvider(
                                                    avatar.imageUrl,
                                                  ),
                                              radius: 30,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 3.0,
                                              ),
                                              child: Text(
                                                '@${avatar.creatorName}',
                                                style: const TextStyle(
                                                  fontSize: 6.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1000,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: AutoSizeText(
                                                  avatar.name,
                                                  maxLines: 2,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  // Default style for children
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    const TextSpan(text: '📝'),
                                                    TextSpan(
                                                      text: convertNumber(
                                                        avatar
                                                            .knowledgePointCounter,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AutoSizeText(
                                                avatar.description,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListTile(
                                          dense: true,
                                          title: Text('Expertise'.tr),
                                          subtitle: AutoSizeText(
                                            avatar.expertise,
                                            maxLines: 2,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          trailing: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                CupertinoIcons
                                                    .chat_bubble_2_fill,
                                                color: kPrimaryColor,
                                              ),
                                              Text(
                                                convertNumber(avatar.chatCount),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }, childCount: c.characters.length),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: kDefaultPadding * 1.618 * 3),
                  ),
                ],
              ),
            ),
            Obx(
              () => !c.isAppUpToDate.value
                  ? Container(
                      height: getScreenHeight(),
                      width: getScreenWidth(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Lottie.asset(
                              'assets/lottie_files/update.json',
                              fit: BoxFit.cover,
                              height: getScreenWidth() - kDefaultPadding * 9,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'We are constantly improving the user experience. Update the app and enjoy the latest and greatest!'
                                  .tr,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  launchAppStoreUpdate(
                                    c.appInfo.value.appStoreUrl,
                                  );
                                },
                                child: Text('Update'.tr),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
