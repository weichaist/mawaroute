import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/chat_about_visitor_controller.dart';
import 'package:mawaroute_shop/theme/constants.dart';

class ChatAboutVisitorScreen extends StatelessWidget {
  const ChatAboutVisitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ChatAboutVisitorController.instance;
    c.init();
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Obx(
                    () => AutoSizeText(
                      c.visitorName.value,
                      maxLines: 1,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: kDefaultPadding),
                      child: CircleAvatar(
                        child: c.visitorProfile.value.isEmpty
                            ? const CircleAvatar(
                                backgroundColor: kPrimaryContainerColor,
                                radius: 36,
                                child: Icon(CupertinoIcons.person_circle),
                              )
                            : c.visitorProfile.value.contains(".svg?")
                                ? CircleAvatar(
                                    backgroundColor: kPrimaryContainerColor,
                                    radius: 36,
                                    child: ClipOval(
                                      child: SvgPicture.network(
                                        c.visitorProfile.value,
                                        key: UniqueKey(),
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: kPrimaryContainerColor,
                                    radius: 36,
                                    child: ExtendedImage.network(
                                        c.visitorProfile.value),
                                  ),
                      ),
                    )
                  ],
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 9.0,
                      vertical: 9.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                            image: AssetImage('assets/images/cool_bg.png'),
                            fit: BoxFit.cover)),
                    child: ListTile(
                      title: AutoSizeText(
                        "AIアシスタントに、このお客さんの好みに合った提案などについて相談してみませんか？".tr,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => SliverPadding(
                    padding: const EdgeInsets.only(
                        bottom: kDefaultPadding * 1.618 * 6),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index == c.messages.length) {
                            return c.isLoading.isTrue
                                ? ListTile(
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: kPrimaryColor,
                                      child: ExtendedImage.asset(
                                        'assets/icons/mawaroute_icon.png',
                                        width: 36,
                                      ),
                                    ),
                                    title: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          color: kPrimaryColor,
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: DefaultTextStyle(
                                          style: const TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white),
                                          child: AnimatedTextKit(
                                            totalRepeatCount: 120,
                                            animatedTexts: [
                                              TypewriterAnimatedText('      '),
                                            ],
                                            onTap: () {
                                              debugPrint("Tap Event");
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const ListTile();
                          } else {
                            String qa = c.messages[index].content;
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: kPrimaryColor,
                                child: ExtendedImage.asset(
                                  'assets/icons/mawaroute_icon.png',
                                  width: 36,
                                ),
                              ),
                              title: Align(
                                alignment: index.isEven
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: index.isEven
                                        ? kPrimaryColor
                                        : Colors.grey,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    qa,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        childCount: c.messages.length + 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.618),
              color: WidgetStateColor.resolveWith((states) => Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        ActionChip(
                          onPressed: () async {
                            if (c.messages.length < 2) {
                              c.isLoading.value = true;
                              await c.getAnswerWithPreset();
                              c.isLoading.value = false;
                            }
                          },
                          label: const Text('好みにつして教えてください'),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      title: TextField(
                        maxLines: 3,
                        minLines: 1,
                        readOnly: true,
                        controller: c.question.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.arrow_up_circle_fill,
                              color: kPrimaryColor,
                              size: 27,
                            ),
                            onPressed: () async {
                              await c.getAnswer();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
