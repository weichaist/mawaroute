import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:mawaroute_business/theme/constants.dart';

class ShopDesktopNavigationRail extends StatelessWidget {
  const ShopDesktopNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: true,
      minExtendedWidth: 210,
      leading: Column(
        children: [
          Container(
            height: 72,
            width: 210,
            padding: const EdgeInsets.only(left: kDefaultPadding),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/mawaroute_text.webp',
                  width: 150,
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              return Container(
                height: 36,
                width: 210,
                margin: const EdgeInsets.only(bottom: kDefaultPadding),
                child: ListTile(
                  title: OutlinedButton.icon(
                    onPressed: () {
                      SmartDialog.showAttach(
                          maskColor: Colors.transparent,
                          alignment: Alignment.centerRight,
                          animationType: SmartAnimationType.fade,
                          targetContext: context,
                          builder: (context) {
                            return Container(
                              width: 240,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Card(
                                child: Column(
                                  children: [
                                    ListTile(
                                      onTap: () {},
                                      leading: const Icon(
                                          CupertinoIcons.arrow_merge),
                                      title: const Text('New Campaign'),
                                    ),
                                    ListTile(
                                      onTap: () {},
                                      leading: const Icon(CupertinoIcons.gift),
                                      title: const Text('New Reward'),
                                    ),
                                    ListTile(
                                      onTap: () {},
                                      leading:
                                          const Icon(CupertinoIcons.speaker_3),
                                      title: const Text('New Ad'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    label: const Text('作成'),
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 48,
              width: 210,
              child: ListTile(
                onTap: () {},
                title: const Text(
                  '設定',
                  style: TextStyle(fontSize: 15),
                ),
                leading: const Icon(
                  CupertinoIcons.settings,
                  // size: 18,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
      onDestinationSelected: (index) {},
      destinations: const [
        NavigationRailDestination(
          icon: Icon(CupertinoIcons.compass),
          label: Text('ホーム'),
        ),
        NavigationRailDestination(
          icon: Icon(CupertinoIcons.radiowaves_right),
          label: Text('広告一覧'),
        ),
        NavigationRailDestination(
          icon: Icon(CupertinoIcons.person_alt_circle),
          label: Text('アカウント'),
        ),
      ],
      selectedIndex: 1,
    );
  }
}
