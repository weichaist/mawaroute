import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mawaroute_visitor/screens/home_nav_wrapper/v3_home_screen.dart';
import 'package:mawaroute_visitor/screens/home_nav_wrapper/voice_translate_screen.dart';
import 'package:mawaroute_visitor/screens/my_wallet_screen/my_wallet_screen.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';

import '../../push_notification_service.dart';

List<Widget> _buildScreens() {
  return [
    const V3HomeScreen(),
    const VoiceAssistantScreen(),
    const MyWalletScreen(),
  ];
}

List<IconData> _icons() {
  return [
    CupertinoIcons.chat_bubble_2,
    Icons.translate_outlined,
    Icons.account_balance_wallet_outlined,
  ];
}

List<String> _labels() {
  return ['Chat'.tr, 'Translate'.tr, 'Wallet'.tr];
}

class Material3NavBar extends StatefulWidget {
  const Material3NavBar({super.key});

  @override
  State<Material3NavBar> createState() => _Material3NavBarState();
}

class _Material3NavBarState extends State<Material3NavBar> {
  int currentPageIndex = 0;
  @override
  void initState() {
    super.initState();
    final pushNotificationService = PushNotificationService();
    pushNotificationService.setup();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        height: 63,
        backgroundColor: CupertinoColors.darkBackgroundGray,
        itemCount: _icons().length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 9.0, bottom: 1.5),
                child: Icon(
                  _icons()[index],
                  size: 24,
                  color: isActive
                      ? Colors.white
                      : CupertinoColors.secondaryLabel,
                ),
              ),
              Text(
                _labels()[index],
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.white : CupertinoColors.systemGrey3,
                ),
              ),
            ],
          );
        },
        leftCornerRadius: 18,
        rightCornerRadius: 18,
        gapLocation: GapLocation.none,
        activeIndex: currentPageIndex,
        onTap: (index) => setState(() => currentPageIndex = index),
        //other params
      ),
      body: IndexedStack(index: currentPageIndex, children: _buildScreens()),
    );
  }
}
