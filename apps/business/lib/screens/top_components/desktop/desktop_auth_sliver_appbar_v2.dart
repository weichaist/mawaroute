import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/utility.dart';

class DesktopAuthSliverAppBarV2 extends StatelessWidget {
  const DesktopAuthSliverAppBarV2({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = AuthController.instance;
    return SliverAppBar(
      automaticallyImplyLeading: false,
      actions: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [Text(authController.displayName.value)],
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(right: kDefaultPadding),
          child: GestureDetector(
            onTap: () {
              SmartDialog.show(
                  builder: (context) => Container(
                        width: 480,
                        height: 480 / 1.618,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(kDefaultPadding),
                                  child: Text(
                                    'Sign out of your mawaroute account?'.tr,
                                    style: const TextStyle(
                                        color: kPrimaryColor, fontSize: 21),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 9.0),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: ListTile(
                                    title: OutlinedButton(
                                      child: Text('Sign out'.tr),
                                      onPressed: () {
                                        authController.signOut();
                                      },
                                    ),
                                  )),
                                  Expanded(
                                      child: ListTile(
                                    title: OutlinedButton(
                                      child: Text('Cancel'.tr),
                                      onPressed: () {
                                        showDismiss();
                                      },
                                    ),
                                  )),
                                ],
                              ),
                            )
                          ],
                        ),
                      ));
            },
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Image.asset(
                'assets/icons/guru_coin.png',
              ),
            ),
          ),
        )
      ],
    );
  }
}
