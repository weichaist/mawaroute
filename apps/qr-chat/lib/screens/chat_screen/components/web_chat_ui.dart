import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../api/api.dart';
import '../../../controllers/web_chat_controller.dart';
import '../../../models/text_bubble_el.dart';
import '../../../theme/constants.dart';
import '../account_limit_dialog.dart';

class WebChatUI extends StatelessWidget {
  const WebChatUI({super.key});
  @override
  Widget build(BuildContext context) {
    final c = WebChatController.instance;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: ExtendedAssetImageProvider('assets/images/main_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: kDefaultPadding, bottom: 96),
            child: Obx(
              () => ListView.builder(
                controller: c.scrollController,
                itemBuilder: (context, index) {
                  TextBubbleEl chatEl = c.chatsForDisplay[index];
                  if (chatEl.type == RecChatElementType.loading.name) {
                    return LoadingChatBubble(chatEl: chatEl);
                  } else if (chatEl.type == RecChatElementType.text.name) {
                    return TextChatBubble(chatEl: chatEl);
                  } else if (chatEl.type ==
                      RecChatElementType.streamText.name) {
                    return const StreamTextChatBubble();
                  } else if (chatEl.type == RecChatElementType.recItem.name) {
                    return RecItemBubble(chatEl: chatEl);
                  } else {
                    return const SizedBox();
                  }
                },
                itemCount: c.chatsForDisplay.length,
              ),
            ),
          ),
          SizedBox(
            height: 84,
            width: double.infinity,
            child: Center(
              child: ListTile(
                title: TextField(
                  maxLength: 99,
                  controller: c.inputController,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'type here'.tr,
                    suffixIcon: GestureDetector(
                      onTap: () async {
                        if (c.chatsForDisplay.length >= 15) {
                          await buildRecAccountLimitationDialog(
                            chatLimit: 3,
                            messageLimit: 15,
                          );
                        } else {
                          await c.processWebChat();
                        }
                      },
                      child: const Icon(
                        CupertinoIcons.arrow_up_circle_fill,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    counterStyle: const TextStyle(color: Colors.white),
                  ),
                  onSubmitted: (_) async {
                    if (c.chatsForDisplay.length >= 15) {
                      await buildRecAccountLimitationDialog(
                        chatLimit: 3,
                        messageLimit: 15,
                      );
                    } else {
                      await c.processWebChat();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingChatBubble extends StatelessWidget {
  const LoadingChatBubble({super.key, required this.chatEl});
  final TextBubbleEl chatEl;

  @override
  Widget build(BuildContext context) {
    WebChatController c = WebChatController.instance;
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
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding / 1.8,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            child: ListTile(
              leading: const CupertinoActivityIndicator(),
              title: Text(chatEl.message.tr),
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
    WebChatController c = WebChatController.instance;
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: chatEl.messageOfAvatar
              ? CircleAvatar(
                  backgroundImage: ExtendedNetworkImageProvider(
                    c.mAvatar.value.imageUrl,
                  ),
                )
              : const CircleAvatar(child: Icon(CupertinoIcons.person_fill)),
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
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding / 1.8,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            child: ListTile(title: SelectableText(chatEl.message)),
          ),
        ),
      ],
    );
  }
}

class StreamTextChatBubble extends StatelessWidget {
  const StreamTextChatBubble({super.key});
  @override
  Widget build(BuildContext context) {
    WebChatController c = WebChatController.instance;
    return Column(
      children: [
        Obx(
          () => ListTile(
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding / 1.8,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            child: Obx(
              () => ListTile(
                title: c.streamText.value.isEmpty
                    ? Text("Typing...".tr)
                    : SelectableText(c.streamText.value),
              ),
            ),
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
    WebChatController c = WebChatController.instance;
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
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () async {
                      await c.streamRecReason(
                        recUid: chatEl.recUid!,
                        recText: chatEl.recDescription!,
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Text(
                        'Why you might like it'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9.0),
                Material(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () async {
                      await c.fetchSimilarWeaviateRecItem(
                        concepts: chatEl.message + chatEl.recDescription!,
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Text(
                        'Find similar items'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding / 1.8,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
            ),
            child: ListTile(
              title: SelectableText(chatEl.message),
              trailing: GestureDetector(
                onTap: () async {
                  final data = ClipboardData(text: chatEl.message);
                  await Clipboard.setData(data);
                  SmartDialog.showToast('Copied');
                },
                child: const Icon(Icons.copy),
              ),
            ),
          ),
        ),
        Obx(
          () => c.reasonForRecs[chatEl.recUid] != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding,
                    vertical: kDefaultPadding / 1.8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                    ),
                    child: ListTile(
                      title: c.reasonForRecs[chatEl.recUid]!.isEmpty
                          ? Text("Typing...".tr)
                          : SelectableText(c.reasonForRecs[chatEl.recUid]!),
                    ),
                  ),
                )
              : const SizedBox(),
        ),
        if (chatEl.recLink != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: kDefaultPadding / 1.8,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Obx(
                    () => c.linkPreviews[chatEl.recLink] != null
                        ? Column(
                            children: [
                              if (c
                                  .linkPreviews[chatEl.recLink]!
                                  .image
                                  .isNotEmpty)
                                Container(
                                  height: 180,
                                  margin: const EdgeInsets.all(9.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.grey[200],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: ExtendedImage.network(
                                      c.linkPreviews[chatEl.recLink]!.image,
                                      fit: BoxFit.contain,
                                      cache: true,
                                      loadStateChanged:
                                          (ExtendedImageState state) {
                                            switch (state
                                                .extendedImageLoadState) {
                                              case LoadState.loading:
                                                return const Center(
                                                  child:
                                                      CupertinoActivityIndicator(),
                                                );
                                              case LoadState.completed:
                                                return null;
                                              case LoadState.failed:
                                                return const Center(
                                                  child: Icon(Icons.error),
                                                );
                                            }
                                          },
                                    ),
                                  ),
                                ),
                              ListTile(
                                onTap: () {
                                  launchUrlString(chatEl.recLink!);
                                },
                                title: Text(
                                  c.linkPreviews[chatEl.recLink]!.title,
                                ),
                                subtitle: Text(
                                  c.linkPreviews[chatEl.recLink]!.description,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                  ListTile(
                    onTap: () {
                      launchUrlString(chatEl.recLink!);
                    },
                    title: Text(
                      chatEl.recLink!,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (c.findLastRecUid() == chatEl.recUid!)
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () async {
                      if (c.chatsForDisplay.length >= 15) {
                        await buildRecAccountLimitationDialog(
                          chatLimit: 3,
                          messageLimit: 15,
                        );
                      } else {
                        await c.fetchWeaviateRecItem(concepts: c.userIntent);
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 9.0,
                      ),
                      child: Text(
                        'Show More'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
