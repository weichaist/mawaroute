import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/create_campaing_v2_controller.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';

import '../top_components/date_time_input.dart';
import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class CreateCampaignV2Screen extends StatefulWidget {
  const CreateCampaignV2Screen({super.key});

  @override
  State<CreateCampaignV2Screen> createState() => _CreateCampaignV2ScreenState();
}

class _CreateCampaignV2ScreenState extends State<CreateCampaignV2Screen> {
  @override
  Widget build(BuildContext context) {
    CreateCampaignV2Controller c = CreateCampaignV2Controller.instance;
    return Title(
      title: 'Create Campaign|MaWaRoute (マワルト)',
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
                                    'Create New Campaign'.tr,
                                    style: const TextStyle(
                                      fontSize: 27,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // ListTile(
                            //   title: const Padding(
                            //     padding: EdgeInsets.only(
                            //       bottom: 12,
                            //     ),
                            //     child:
                            //         Text("Don't want to start from scratch?"),
                            //   ),
                            //   subtitle: Row(
                            //     children: [
                            //       ElevatedButton.icon(
                            //         onPressed: () {},
                            //         label: const Text('Re-run Past Campaigns'),
                            //         icon: const Icon(
                            //           CupertinoIcons.arrow_2_circlepath,
                            //           size: 15,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            const ListTile(),
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
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ListTile(
                                    title: Text(
                                      'Basic Setup'.tr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ListTile(
                                    title: TextField(
                                      controller: c.title.value,
                                      maxLength: 60,
                                      decoration: InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          labelText: 'Title *'.tr,
                                          hintText:
                                              'Enter a descriptive title'.tr),
                                    ),
                                  ),
                                  ListTile(
                                    title: TextField(
                                      controller: c.description.value,
                                      maxLength: 180,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText: 'Description *'.tr,
                                        hintText:
                                            'Enter a description explaining the details of the campaign'
                                                .tr,
                                      ),
                                    ),
                                  ),
                                  // const ListTile(
                                  //   title: TextField(
                                  //     enabled: false,
                                  //     decoration: InputDecoration(
                                  //       floatingLabelBehavior:
                                  //           FloatingLabelBehavior.always,
                                  //       labelText: 'Who Can Join *',
                                  //       hintText: 'Select an Option',
                                  //       hintStyle: TextStyle(color: kTextColor),
                                  //       prefixIcon: Icon(
                                  //         Icons.arrow_drop_down,
                                  //         color: kPrimaryColor,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  DateTimeInput(
                                    labelText: 'Start Time *'.tr,
                                    initialValue: c.startTime.value,
                                    onDateSelected: (value) {
                                      c.startTime.value = value;
                                    },
                                  ),
                                  const ListTile(),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await c.onCreate();
                                          },
                                          child: Text(
                                            'Create Campaign'.tr,
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
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
