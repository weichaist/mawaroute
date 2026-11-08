import 'package:any_link_preview/any_link_preview.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/screens/chat_rec_screen/components/build_zoom_image_dialog.dart';
import 'package:mawaroute_visitor/screens/chat_rec_screen/components/rec_filters.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';

import '../../api/rec_chat_api.dart';
import '../../controllers/rec_chat_controller.dart';
import '../../enums.dart';
import '../../models/rec_text_bubble_el.dart';
import '../../utilis/launch_urls.dart';
import '../capture_image_to_earn_screen/capture_product_image_screen.dart';
import '../top_level_components/common_widgets/primary_gradient_background.dart';
import 'components/build_chat_rec_menu.dart';
import 'components/rec_input_text_field.dart';

class ChatRecScreen extends StatelessWidget {
  const ChatRecScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = RecChatController.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.init();
    });
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Obx(
          () => Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Stack(
                  children: [
                    const GradientBackground(),
                    CustomScrollView(
                      controller: c.primaryScrollController,
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          backgroundColor: Colors.transparent,
                          leading: c.isStreaming.isFalse
                              ? IconButton(
                                  onPressed: () async {
                                    await c.cancelSubscription();
                                    Get.back();
                                  },
                                  icon: const Icon(
                                    CupertinoIcons.arrow_left,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  CupertinoIcons.arrowtriangle_down,
                                  color: Colors.white,
                                ),
                          title: Text(
                            c.mAvatar.value.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            c.isNewChat.isTrue && c.isStreaming.isFalse
                                ? Builder(
                                    builder: (context) {
                                      return IconButton(
                                        onPressed: () async {
                                          await buildRecChatMenu(context);
                                        },
                                        icon: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.white,
                                          size: 27,
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        const RecFilters(),
                        const ChatRecBody(),
                      ],
                    ),
                  ],
                ),
              ),
              if (c.isNewChat.isTrue) const RecScreenInputTextField(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatRecBody extends StatelessWidget {
  const ChatRecBody({super.key});
  @override
  Widget build(BuildContext context) {
    final c = RecChatController.instance;
    return Obx(
      () => SliverPadding(
        padding: const EdgeInsets.only(bottom: kDefaultPadding * 6 * 1.618),
        sliver: SliverList.builder(
          itemBuilder: (context, index) {
            TextBubbleEl chatEl = c.chatsForDisplay[index];
            if (chatEl.type == RecChatElementType.loading.name) {
              return LoadingChatBubble(chatEl: chatEl);
            } else if (chatEl.type == RecChatElementType.streamText.name) {
              return const StreamChatBubble();
            } else if (chatEl.type == RecChatElementType.text.name) {
              return TextChatBubble(chatEl: chatEl);
            } else if (chatEl.type == RecChatElementType.recItem.name) {
              return RecItemBubble(chatEl: chatEl);
            } else if (chatEl.type == RecChatElementType.imageText.name) {
              return ImageChatBubble(chatEl: chatEl);
            } else {
              return const SizedBox();
            }
          },
          itemCount: c.chatsForDisplay.length,
        ),
      ),
    );
  }
}

class LoadingChatBubble extends StatelessWidget {
  const LoadingChatBubble({super.key, required this.chatEl});
  final TextBubbleEl chatEl;

  @override
  Widget build(BuildContext context) {
    final c = RecChatController.instance;
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: c.mAvatar.value.imageUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: ExtendedNetworkImageProvider(
                    c.mAvatar.value.imageUrl,
                  ),
                )
              : null,
          title: Text(
            c.mAvatar.value.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 1.618,
            vertical: kDefaultPadding / 1.618,
          ),
          child:
              ListTile(
                leading: const CupertinoActivityIndicator(),
                title: Text(chatEl.message.tr),
              ).frosted(
                borderRadius: BorderRadius.circular(18),
                frostOpacity: 0.54,
                blur: 1.5,
              ),
        ),
      ],
    );
  }
}

class StreamChatBubble extends StatelessWidget {
  const StreamChatBubble({super.key});
  @override
  Widget build(BuildContext context) {
    final c = RecChatController.instance;
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundImage: ExtendedNetworkImageProvider(
              c.mAvatar.value.imageUrl,
            ),
          ),
          title: Text(
            c.mAvatar.value.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding * 1.618,
              vertical: kDefaultPadding / 1.618,
            ),
            child: ListTile(title: Text(c.streamText.value)).frosted(
              borderRadius: BorderRadius.circular(18),
              frostOpacity: 0.54,
              blur: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class TextChatBubble extends StatelessWidget {
  const TextChatBubble({super.key, required this.chatEl});
  final TextBubbleEl chatEl;
  @override
  Widget build(BuildContext context) {
    final c = RecChatController.instance;
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundImage: ExtendedNetworkImageProvider(
              chatEl.messageOfAvatar
                  ? c.mAvatar.value.imageUrl
                  : c.authController.profile.value.image,
            ),
          ),
          title: Text(
            chatEl.messageOfAvatar ? c.mAvatar.value.name : 'You',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 1.618,
            vertical: kDefaultPadding / 1.618,
          ),
          child: ListTile(title: SelectableText(chatEl.message)).frosted(
            borderRadius: BorderRadius.circular(18),
            frostOpacity: 0.54,
            blur: 1.5,
          ),
        ),
      ],
    );
  }
}

class ImageChatBubble extends StatelessWidget {
  const ImageChatBubble({super.key, required this.chatEl});
  final TextBubbleEl chatEl;
  @override
  Widget build(BuildContext context) {
    final c = RecChatController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundImage: ExtendedNetworkImageProvider(
              chatEl.messageOfAvatar
                  ? c.mAvatar.value.imageUrl
                  : c.authController.profile.value.image,
            ),
          ),
          title: Text(
            chatEl.messageOfAvatar ? c.mAvatar.value.name : 'You',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 1.618,
            vertical: kDefaultPadding / 1.618,
          ),
          child: GestureDetector(
            onTap: () async {
              await buildZoomImageDialog(chatEl.imageUrl!);
            },
            child:
                SizedBox(
                  height: getScreenWidth() / 1.618 / 1.618,
                  width: getScreenWidth() / 1.618,
                  child: ExtendedImage.network(
                    chatEl.imageUrl!,
                    fit: BoxFit.contain,
                  ),
                ).frosted(
                  borderRadius: BorderRadius.circular(18),
                  frostOpacity: 0.54,
                  blur: 1.5,
                ),
          ),
        ),
        if (chatEl.message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding * 1.618,
              vertical: kDefaultPadding / 1.618,
            ),
            child: ListTile(title: SelectableText(chatEl.message)).frosted(
              borderRadius: BorderRadius.circular(18),
              frostOpacity: 0.54,
              blur: 1.5,
            ),
          ),
      ],
    );
  }
}

class RecItemBubble extends StatelessWidget {
  const RecItemBubble({super.key, required this.chatEl});
  final TextBubbleEl chatEl;
  @override
  Widget build(BuildContext context) {
    final c = RecChatController.instance;
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: CircleAvatar(
            backgroundImage: ExtendedNetworkImageProvider(
              c.mAvatar.value.imageUrl,
            ),
          ),
          title: Text(
            c.mAvatar.value.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          dense: true,
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (c.isNewChat.isTrue) {
                        c.streamRecReason(
                          recUid: chatEl.recUid!,
                          recText:
                              "${chatEl.message}. ${chatEl.recDescription}",
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child:
                        Text(
                          'Why you might like it'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ).frosted(
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 9.0,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 9.0),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (c.isNewChat.isTrue) {
                        c.findSimilarItems(
                          chatEl.message + (chatEl.recDescription ?? ""),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child:
                        Text(
                          'Find similar items'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ).frosted(
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 9.0,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 9.0),
                if (chatEl.geo != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        String placeId = extractPlaceId(chatEl.recLink!);
                        if (placeId.isEmpty) return;
                        await Get.to(
                          () => const CaptureImageToEarnScreen(),
                          arguments: {
                            "googlePlaceId": placeId,
                            "lat": chatEl.geo!.latitude,
                            "lng": chatEl.geo!.longitude,
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child:
                          const Icon(
                            CupertinoIcons.camera_viewfinder,
                            color: kPrimaryColor,
                          ).frosted(
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 9.0,
                            ),
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 1.618,
            vertical: kDefaultPadding / 1.618,
          ),
          child:
              ListTile(
                onLongPress: () async {
                  final data = ClipboardData(text: chatEl.message);
                  await Clipboard.setData(data);
                  SmartDialog.showToast('Copied');
                },
                title: Text(chatEl.message),
              ).frosted(
                borderRadius: BorderRadius.circular(18),
                frostOpacity: 0.54,
                blur: 1.5,
              ),
        ),
        Obx(
          () => c.reasonForRecs[chatEl.recUid] != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding * 1.618,
                    vertical: kDefaultPadding / 1.618,
                  ),
                  child:
                      ListTile(
                        title: SelectableText(c.reasonForRecs[chatEl.recUid]!),
                      ).frosted(
                        borderRadius: BorderRadius.circular(18),
                        frostOpacity: 0.54,
                        blur: 1.5,
                      ),
                )
              : const SizedBox(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 1.618,
            vertical: kDefaultPadding / 1.618,
          ),
          child: AnyLinkPreview.builder(
            // link: widget.url,
            link: chatEl.recLink!,
            errorWidget:
                const ListTile(
                  title: Center(
                    child: Icon(
                      CupertinoIcons.wifi_exclamationmark,
                      color: Colors.red,
                    ),
                  ),
                ).frosted(
                  borderRadius: BorderRadius.circular(18),
                  frostOpacity: 0.54,
                  blur: 1.5,
                ),
            placeholderWidget: AspectRatio(
              aspectRatio: 5 / 4.2,
              child:
                  const Center(
                    child: CupertinoActivityIndicator(color: kPrimaryColor),
                  ).frosted(
                    borderRadius: BorderRadius.circular(18),
                    frostOpacity: 0.54,
                    blur: 1.5,
                  ),
            ),
            cache: const Duration(days: 3),
            itemBuilder: (context, meta, image, svg) {
              return GestureDetector(
                onTap: () {
                  launchPlaceUrl(chatEl.recLink!);
                },
                child:
                    AspectRatio(
                      aspectRatio: 5 / 4.2,
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.91 / 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: kPrimaryContainerColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                image: image != null
                                    ? DecorationImage(
                                        image: image,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                      )
                                    : const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/cool_bg.png',
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          ListTile(
                            title: meta.title != null
                                ? AutoSizeText(
                                    meta.title!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    chatEl.recLink!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            subtitle: meta.desc != null
                                ? AutoSizeText(
                                    meta.desc!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : null,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ).frosted(
                      frostColor: kPrimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
              );
            },
          ),
        ),
        if (c.findLastRecUid() == chatEl.recUid!)
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (c.isNewChat.isTrue) {
                        c.findSimilarItems(c.recQuery);
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child:
                        Text(
                          'Show More'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ).frosted(
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 9.0,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
