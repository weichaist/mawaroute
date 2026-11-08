import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/models/chat.dart';
import 'package:mawaroute_visitor/screens/top_level_components/common_widgets/single_click_elevated_button.dart';
import 'package:mawaroute_visitor/screens/top_level_components/common_widgets/single_click_gesture_detector.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/utilis/formatter.dart';

import '../../controllers/chat_history_controller.dart';

class ChatRecHistoryScreen extends StatelessWidget {
  const ChatRecHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ChatHistoryController c = ChatHistoryController.instance;
    c.init();
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              Obx(
                () => SliverAppBar(
                  title: Text('History'.tr),
                  actions: [
                    TextButton(
                      onPressed: () {
                        c.multipleSelectionMode.value =
                            !c.multipleSelectionMode.value;
                        c.selectedChats.clear();
                      },
                      child: Text(
                        c.multipleSelectionMode.isFalse
                            ? 'Select'.tr
                            : "Finish".tr,
                      ),
                    ),
                    if (c.multipleSelectionMode.isTrue)
                      Obx(
                        () => Padding(
                          padding: const EdgeInsets.only(
                            left: 3.0,
                            right: 12.0,
                          ),
                          child: Text(
                            "${c.selectedChats.length}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Obx(
                () => SliverPadding(
                  padding: const EdgeInsets.only(
                    bottom: kDefaultPadding * 3 * 1.618,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == c.savedChats.value.results.length) {
                        return Obx(
                          () => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: kDefaultPadding,
                            ),
                            child: c.savedChats.value.isLast
                                ? Center(child: Text("It's quite now...".tr))
                                : SingleClickElevatedButton(
                                    child: Text('More'.tr),
                                    onPressed: () async {
                                      await c.fetchSavedChats();
                                    },
                                  ),
                          ),
                        );
                      } else {
                        ChatModel chat = c.savedChats.value.results[index];
                        return GestureDetector(
                          key: Key(chat.id!),
                          onTap: () {
                            if (c.multipleSelectionMode.isFalse) {
                              Get.toNamed(
                                "/chat_rec_screen/${chat.avatarUid}",
                                arguments: {'chatUid': chat.id},
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 3.0,
                              horizontal: 6.0,
                            ),
                            child:
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        ExtendedNetworkImageProvider(
                                          chat.avatarProfileUrl,
                                        ),
                                  ),
                                  title: AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        chat.query,
                                        textStyle: const TextStyle(
                                          fontSize: 15.6,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                    pause: const Duration(milliseconds: 60),
                                    totalRepeatCount: 1,
                                  ),
                                  subtitle: Text(
                                    formatDateTime(chat.createdAt),
                                  ),
                                  trailing: Obx(
                                    () => c.multipleSelectionMode.isFalse
                                        ? const Icon(
                                            CupertinoIcons
                                                .arrow_up_right_circle_fill,
                                            color: kPrimaryColor,
                                          )
                                        : SingleClickGestureDetector(
                                            onPressed: () async {
                                              if (c
                                                  .multipleSelectionMode
                                                  .isTrue) {
                                                if (c.selectedChats.contains(
                                                  chat.id,
                                                )) {
                                                  c.selectedChats.remove(
                                                    chat.id,
                                                  );
                                                } else {
                                                  c.selectedChats.add(chat.id!);
                                                }
                                              }
                                            },
                                            child:
                                                c.multipleSelectionMode.isTrue
                                                ? c.selectedChats.contains(
                                                        chat.id,
                                                      )
                                                      ? const Icon(
                                                          Icons.check_outlined,
                                                          color: kPrimaryColor,
                                                        )
                                                      : const Icon(
                                                          Icons.circle_outlined,
                                                          color: kPrimaryColor,
                                                        )
                                                : const SizedBox(),
                                          ),
                                  ),
                                ).frosted(
                                  frostColor: kPrimaryContainerColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                          ),
                        );
                      }
                    }, childCount: c.savedChats.value.results.length + 1),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Positioned(
              bottom: 15,
              right: 15,
              child: c.multipleSelectionMode.isTrue
                  ? FloatingActionButton(
                      backgroundColor: kAlertColor,
                      onPressed: () async {
                        await c.deleteChats();
                      },
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
