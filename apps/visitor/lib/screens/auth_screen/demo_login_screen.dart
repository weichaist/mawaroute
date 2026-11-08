import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';

import '../../controllers/auth_controller.dart';

class DemoLoginScreen extends StatelessWidget {
  const DemoLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    AuthController c = AuthController.instance;
    SizeConfig().init(context);
    return PopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                automaticallyImplyLeading: false,
                leading: const Icon(
                  CupertinoIcons.person_crop_circle_badge_checkmark,
                ),
                title: Text(
                  'Mawaroute Account'.tr,
                  style: const TextStyle(color: kPrimaryColor),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  width: getScreenWidth(),
                  child: Image.asset('assets/images/mobile_cover.png'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 120),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Login with phone number'.tr),
                        dense: true,
                      ),
                      ListTile(
                        leading: GestureDetector(
                          onTap: () async {
                            String data = await DefaultAssetBundle.of(
                              context,
                            ).loadString("assets/model/dial_code.json");
                            List jsonResult = jsonDecode(data);
                            SmartDialog.show(
                              builder: (context) {
                                return Container(
                                  height:
                                      getScreenWidth() - kDefaultPadding * 2,
                                  width: getScreenWidth() - kDefaultPadding * 2,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          'Please select your country code'.tr,
                                          style: const TextStyle(
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(0),
                                          itemBuilder: (context, index) {
                                            Map<dynamic, dynamic> res =
                                                jsonResult[index];
                                            return ListTile(
                                              onTap: () {
                                                c.countryEmoji.value =
                                                    res['flag'];
                                                c.countryCode.value =
                                                    res['dial_code'];
                                                SmartDialog.dismiss();
                                              },
                                              leading: Text(
                                                res['flag']!,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                ),
                                              ),
                                              title: Text(res['name']!),
                                              trailing: Text(res['dial_code']!),
                                            );
                                          },
                                          itemCount: jsonResult.length,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Obx(
                            () => Text(
                              c.countryEmoji.value,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Obx(
                          () => TextField(
                            controller: c.phoneNumber.value,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixText: c.countryCode.value,
                              prefixStyle: const TextStyle(
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text(''),
                        subtitle: ElevatedButton.icon(
                          onPressed: () async {
                            if (c.phoneNumber.value.text.isEmpty) {
                              return;
                            } else {
                              await c.sendPhoneVerificationCode();
                            }
                          },
                          icon: const Icon(Icons.navigate_next),
                          label: Text('Continue'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
