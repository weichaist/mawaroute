import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../theme/constants.dart';
import '../../theme/size_config.dart';

class EmailAuthScreen extends StatelessWidget {
  const EmailAuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    AuthController c = AuthController.instance;
    SizeConfig().init(context);
    return PopScope(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                automaticallyImplyLeading: false,
                leading: const Icon(
                    CupertinoIcons.person_crop_circle_badge_checkmark),
                title: Text(
                  'MaWaRoute Account'.tr,
                  style: const TextStyle(color: kPrimaryColor),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  width: getScreenWidth(),
                  child: Image.asset('assets/images/auth_illustration.png'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Login with email and password'.tr),
                        dense: true,
                      ),
                      ListTile(
                        title: TextField(
                          controller: c.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                        ),
                      ),
                      ListTile(
                        title: TextField(
                          controller: c.passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.password),
                          ),
                        ),
                      ),
                      ListTile(
                        title: TextField(
                          controller: c.placeUidController,
                          decoration: InputDecoration(
                            labelText: "Place ID".tr,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(''),
                        subtitle: ElevatedButton.icon(
                          onPressed: () async {
                            await c.signIn();
                          },
                          icon: const Icon(Icons.navigate_next),
                          label: Text('Continue'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
