import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/visitor_list_controller.dart';
import 'package:mawaroute_shop/theme/constants.dart';

class VisitorListScreen extends StatelessWidget {
  const VisitorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = VisitorListController.instance;
    c.init();
    return Scaffold(
      floatingActionButton: c.isLastPage.value
          ? const SizedBox(
              height: 0,
            )
          : ElevatedButton(
              child: Text('More'.tr),
              onPressed: () {
                c.fetchShopVisitor();
              },
            ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Visitor Insight'.tr,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.info,
                ),
              ),
            ],
          ),
          Obx(
            () => SliverPadding(
              padding: const EdgeInsets.all(9),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                  childAspectRatio: 0.618,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final visitor = c.visitors[index];
                    return Card(
                      elevation: 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 6,
                                ),
                                child: visitor.visitorProfile.isEmpty
                                    ? const CircleAvatar(
                                        backgroundColor: kPrimaryContainerColor,
                                        radius: 36,
                                        child:
                                            Icon(CupertinoIcons.person_circle),
                                      )
                                    : visitor.visitorProfile.contains(".svg?")
                                        ? CircleAvatar(
                                            backgroundColor:
                                                kPrimaryContainerColor,
                                            radius: 36,
                                            child: ClipOval(
                                              child: SvgPicture.network(
                                                visitor.visitorProfile,
                                                key: UniqueKey(),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundColor:
                                                kPrimaryContainerColor,
                                            radius: 36,
                                            child: ExtendedImage.network(
                                              visitor.visitorProfile,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                              )
                            ],
                          ),
                          ListTile(
                            dense: true,
                            subtitle: AutoSizeText(
                              visitor.visitTime.toIso8601String(),
                              maxLines: 1,
                            ),
                            title: Center(
                              child: AutoSizeText(
                                visitor.visitorName,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          ListTile(
                            title: AutoSizeText(
                              visitor.visitorTags.join(', '),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Expanded(
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(
                          //         bottom: 9, left: 12, right: 12),
                          //     child: AutoSizeText(
                          //       visitor.visitorTags.join(', '),
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ),
                          // ),
                          ListTile(
                            minLeadingWidth: 3,
                            title: OutlinedButton(
                              onPressed: () async {
                                Get.toNamed("/chat-about-visitor", arguments: {
                                  "tags": visitor.visitorTags,
                                  "visitorName": visitor.visitorName,
                                  'visitorProfile': visitor.visitorProfile,
                                });
                              },
                              child: AutoSizeText(
                                'About the customer'.tr,
                                maxLines: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  childCount: c.visitors.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
