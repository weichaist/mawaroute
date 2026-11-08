import 'package:flutter/material.dart';
import 'package:mawaroute_business/screens/top_components/desktop/desktop_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';

import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class ElementsScreen extends StatefulWidget {
  const ElementsScreen({super.key});

  @override
  State<ElementsScreen> createState() => _ElementsScreenState();
}

class _ElementsScreenState extends State<ElementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'MaWaRoute (マワルト) | Elements',
      color: kPrimaryColor,
      child: const Scaffold(
        body: Row(
          children: [
            DesktopNavigationRail(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  DesktopAuthSliverAppBarV2(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
