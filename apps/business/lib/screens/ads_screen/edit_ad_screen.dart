import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mawaroute_business/screens/top_components/desktop/desktop_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';

import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class EditAdScreen extends StatefulWidget {
  const EditAdScreen({super.key});

  @override
  State<EditAdScreen> createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Ad | MaWaRoute (マワルト)',
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
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: Center(
                                child: ListTile(
                                  leading: const Icon(
                                    CupertinoIcons.exclamationmark_circle_fill,
                                    color: kPrimaryColor,
                                  ),
                                  trailing: OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('View Checklist'),
                                  ),
                                  title: const Text(
                                    'You are almost there!',
                                    style: TextStyle(
                                      fontSize: 27,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'You have completed 1 of 6 tasks to launch your campaign',
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
                            Padding(
                              padding: const EdgeInsets.all(kDefaultPadding),
                              child: Row(
                                children: [
                                  FilterChip(
                                    label: const Text('Ad Settings'),
                                    onSelected: (_) {},
                                    selected: true,
                                  ),
                                  const SizedBox(
                                    width: kDefaultPadding,
                                  ),
                                  FilterChip(
                                    label: const Text('Activities'),
                                    onSelected: (_) {},
                                    selected: false,
                                  ),
                                  const SizedBox(
                                    width: kDefaultPadding,
                                  ),
                                  FilterChip(
                                    label: const Text('Analytics'),
                                    onSelected: (_) {},
                                    selected: false,
                                  ),
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
                          constraints: const BoxConstraints(
                            maxWidth: kMaxWidth,
                          ),
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
                                  child: Column(
                                    children: [
                                      ListTile(
                                        selected: true,
                                        selectedTileColor:
                                            kPrimaryLightColor.withValues(alpha: 0.3),
                                        title: const Text('Basic Info'),
                                      ),
                                      ListTile(
                                        selected: false,
                                        selectedTileColor:
                                            kPrimaryLightColor.withValues(alpha: 0.3),
                                        title: const Text('Target Audience'),
                                      ),
                                      ListTile(
                                        selected: false,
                                        selectedTileColor:
                                            kPrimaryLightColor.withValues(alpha: 0.3),
                                        title: const Text('Budget'),
                                      ),
                                      ListTile(
                                        selected: false,
                                        selectedTileColor:
                                            kPrimaryLightColor.withValues(alpha: 0.3),
                                        title: const Text('Coupons'),
                                      ),
                                      ListTile(
                                        selected: false,
                                        selectedTileColor:
                                            kPrimaryLightColor.withValues(alpha: 0.3),
                                        title: const Text('Checklist'),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 500,
                                    color: kPrimaryLightColor,
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
