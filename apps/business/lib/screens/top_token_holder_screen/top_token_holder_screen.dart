import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/theme/size_config.dart';

import '../../controllers/top_token_holder_controller.dart';
import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class TopTokenHolderScreen extends StatelessWidget {
  const TopTokenHolderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    TopTokenHolderScreenController controller =
        TopTokenHolderScreenController.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (controller.isLoading.isFalse) {
        controller.isLoading.value = true;
        await controller.init();
        controller.isLoading.value = false;
      }
    });
    SizeConfig().init(context);
    return Title(
      title: 'Token Holders | Mawaroute (マワルト)'.tr,
      color: kPrimaryColor,
      child: Scaffold(
        body: Row(
          children: [
            const V2AdminNavRail(),
            Obx(
              () => Expanded(
                child: controller.isLoading.isTrue
                    ? const Center(
                        child: CupertinoActivityIndicator(),
                      )
                    : CustomScrollView(
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
                                            'Token Holders'.tr,
                                            style: const TextStyle(
                                              fontSize: 27,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Top 30 token holders'.tr,
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
                                constraints:
                                    const BoxConstraints(maxWidth: kMaxWidth),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const ListTile(),
                                    Obx(
                                      () => GridView.extent(
                                        maxCrossAxisExtent: 300,
                                        padding: const EdgeInsets.all(
                                            kDefaultPadding),
                                        mainAxisSpacing: kDefaultPadding,
                                        crossAxisSpacing: kDefaultPadding,
                                        childAspectRatio: 3 / 4,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        children: [
                                          ...List.generate(
                                            controller.tokenHolders.length,
                                            (index) {
                                              TokenHolder tokenHolder =
                                                  controller
                                                      .tokenHolders[index];
                                              return TokenHolderListCard(
                                                tokenHolder: tokenHolder,
                                              );
                                            },
                                          ),
                                        ],
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
            ),
          ],
        ),
      ),
    );
  }
}

class TokenHolderListCard extends StatelessWidget {
  const TokenHolderListCard({super.key, required this.tokenHolder});
  final TokenHolder tokenHolder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryLightColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                image: tokenHolder.url != ""
                    ? DecorationImage(
                        image: NetworkImage(
                          tokenHolder.url,
                          scale: 1,
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/guru_coin.png'),
                ),
                title: Text(
                  tokenHolder.username,
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  "${tokenHolder.tokenNumber} GGMT",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
