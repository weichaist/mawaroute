import 'package:flutter/material.dart';
import 'package:mawaroute_visitor/controllers/wallet_controller.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';

Widget buildMyWalletTabBody() {
  final walletController = WalletController.instance;
  if (walletController.selectedTab.value == 0) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 9,
        right: 9,
        top: 9,
        bottom: kDefaultPadding * 3,
      ),
      sliver: emptyTabBody(),
    );
  } else {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
      sliver: emptyTabBody(),
    );
  }
}

SliverToBoxAdapter emptyTabBody() {
  return SliverToBoxAdapter(
    child: SizedBox(
      width: getScreenWidth(),
      height: 240,
      child: const Center(child: Text('🔎 🫣', style: TextStyle(fontSize: 30))),
    ),
  );
}
