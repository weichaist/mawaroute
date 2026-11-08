import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/screens/top_components/desktop/desktop_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';

import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Ads | MaWaRoute (マワルト)',
      color: kPrimaryColor,
      child: Scaffold(
        body: Row(
          children: [
            const DesktopNavigationRail(),
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
                            const SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: Center(
                                child: ListTile(
                                  title: Text(
                                    'Ads',
                                    style: TextStyle(
                                      fontSize: 27,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Send more people to your place',
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: ElevatedButton(
                                onPressed: () {
                                  Get.toNamed('/ads/create');
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith(
                                          (states) => kPrimaryColor),
                                ),
                                child: const Text(
                                  'Create Your Ad',
                                  style: TextStyle(color: Colors.white),
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
                            const ListTile(
                              leading: Icon(CupertinoIcons
                                  .person_crop_circle_fill_badge_checkmark),
                              title: Text(
                                'My Ads',
                              ),
                              trailing: Text('See more'),
                            ),
                            ListTile(
                              title: Row(
                                children: [
                                  FilterChip(
                                    label: const Text('Draft'),
                                    selected: true,
                                    onSelected: (val) {},
                                  ),
                                  const SizedBox(
                                    width: kDefaultPadding,
                                  ),
                                  FilterChip(
                                    label: const Text('Active'),
                                    selected: false,
                                    onSelected: (val) {},
                                  ),
                                  const SizedBox(
                                    width: kDefaultPadding,
                                  ),
                                  FilterChip(
                                    label: const Text('Completed'),
                                    selected: false,
                                    onSelected: (_) {},
                                  ),
                                ],
                              ),
                            ),
                            GridView.extent(
                              maxCrossAxisExtent: 300,
                              padding: const EdgeInsets.all(kDefaultPadding),
                              mainAxisSpacing: kDefaultPadding,
                              crossAxisSpacing: kDefaultPadding,
                              childAspectRatio: 3 / 4,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                ...List.generate(
                                  6,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      Get.toNamed('/ads/demo');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
