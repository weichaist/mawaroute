import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_qr_chat/screens/chat_screen/components/build_language_select_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../controllers/web_chat_controller.dart';
import '../../theme/constants.dart';
import '../../theme/size_config.dart';
import 'components/web_chat_ui.dart';
import '../../config/app_config.dart';

class WebChatScreen extends StatelessWidget {
  const WebChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    WebChatController c = WebChatController.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.init();
    });
    return Title(
      title: "マワルトレコメンドAI",
      color: Theme.of(context).colorScheme.primary,
      child: Scaffold(
        backgroundColor: const Color(0xFF091939),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9.0),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ExtendedImage.asset(
                          'assets/images/Icon-App-1024x1024@1x.png',
                        ),
                      ),
                      title: Text(
                        'Download mawaroute app for faster response and more features!'
                            .tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (AppConfig.iosAppStoreUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: TextButton.icon(
                              onPressed: () async {
                                await launchUrlString(AppConfig.iosAppStoreUrl);
                              },
                              label: const Text(
                                'iOS',
                                style: TextStyle(color: Colors.white),
                              ),
                              icon: const Icon(
                                Icons.phone_iphone,
                                color: Colors.white,
                              ),
                            ).frosted(borderRadius: BorderRadius.circular(24)),
                          ),
                        if (AppConfig.androidPlayStoreUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: TextButton.icon(
                              onPressed: () async {
                                launchUrlString(AppConfig.androidPlayStoreUrl);
                              },
                              label: const Text(
                                'Android',
                                style: TextStyle(color: Colors.white),
                              ),
                              icon: const Icon(
                                Icons.android,
                                color: Colors.white,
                              ),
                            ).frosted(borderRadius: BorderRadius.circular(24)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: kDefaultPadding / 2,
                      horizontal: kDefaultPadding / 2,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: kMaxWidth / 1.618,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                        child: Obx(
                          () => Row(
                            children: [
                              CircleAvatar(
                                radius: 51,
                                backgroundImage:
                                    c.mAvatar.value.imageUrl.isNotEmpty
                                    ? ExtendedNetworkImageProvider(
                                        c.mAvatar.value.imageUrl,
                                      )
                                    : null,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        c.mAvatar.value.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        c.mAvatar.value.description,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.translate,
                                        color: Colors.white,
                                      ),
                                      title: Row(
                                        children: [
                                          TextButton(
                                            child: Text(
                                              c.languageSetting.value,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () async {
                                              await buildLanguageSelector(
                                                context,
                                              );
                                            },
                                          ).frosted(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            frostColor: Theme.of(
                                              context,
                                            ).colorScheme.primary,
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
                      ).frosted(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            // SliverList.builder(itemBuilder: itemBuilder),
            SliverToBoxAdapter(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 9.0,
                    left: 9.0,
                    right: 9.0,
                    bottom: 9.0,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: kMaxWidth / 1.618,
                          ),
                          child: const WebChatUI(),
                        ),
                      ),
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
