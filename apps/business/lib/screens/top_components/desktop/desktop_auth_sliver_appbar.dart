import 'package:flutter/material.dart';
import 'package:mawaroute_business/screens/top_components/desktop/components/web_menu_tab.dart';
import 'package:mawaroute_business/theme/constants.dart';

class DesktopAuthSliverAppBar extends StatelessWidget {
  const DesktopAuthSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kBgColor,
      automaticallyImplyLeading: false,
      elevation: 3,
      floating: true,
      title: Container(
        height: 69,
        constraints: const BoxConstraints(maxWidth: kMaxWidth),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // GestureDetector(
            //   onTap: () {
            //     // Get.toNamed('/');
            //   },
            //   child: Image.asset(
            //     'assets/images/mwr_icon_trans.webp',
            //     height: 21,
            //   ),
            // ),
            // const SizedBox(
            //   width: kDefaultPadding,
            // ),
            // AuthAppBarNavigation(),
            GestureDetector(
              onTap: () {
                // Get.toNamed('/');
              },
              child: Image.asset(
                'assets/images/mawaroute_text.webp',
                height: 24,
              ),
            ),
          ],
        ),
      ),
      collapsedHeight: 69,
      toolbarHeight: 69,
    );
  }
}

class AuthAppBarNavigation extends StatelessWidget {
  const AuthAppBarNavigation({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        WebMenuItem(
          label: 'Login',
          isActive: true,
          onTap: () {
            // Get.toNamed(
            //   '/',
            // );
          },
        ),
        const SizedBox(
          width: kDefaultPadding,
        ),
        // IconButton(
        //   onPressed: () {
        //     Get.toNamed(
        //       '/auth',
        //     );
        //   },
        //   icon: const Icon(
        //     CupertinoIcons.person_crop_square,
        //     color: kPrimaryColor,
        //   ),
        // ),
      ],
    );
  }
}
