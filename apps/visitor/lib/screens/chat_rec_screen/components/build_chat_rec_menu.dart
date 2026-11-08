import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../../controllers/rec_chat_controller.dart';
import '../../../screens/chat_rec_screen/components/chat_rec_dialogs.dart';
import '../../../theme/constants.dart';
import '../../../theme/size_config.dart';

Future<dynamic> buildRecChatMenu(BuildContext context) {
  final c = RecChatController.instance;
  return SmartDialog.showAttach(
    animationType: SmartAnimationType.fade,
    targetContext: context,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.only(right: 9.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        width: getScreenWidth() / 1.2,
        child: Column(
          children: [
            ListTile(
              onTap: () {
                SmartDialog.dismiss();
                Get.offNamed("/chat_rec_history");
              },
              leading: const Icon(Icons.history),
              title: Text('History'.tr),
            ),
            ListTile(
              onTap: () {
                SmartDialog.dismiss();
                c.init();
              },
              leading: const Icon(Icons.add),
              title: Text('New Chat'.tr),
              trailing: Text('${c.todayChatCount}/${c.isPremiumAcc ? 30 : 9}'),
            ),
            ListTile(
              onTap: () async {
                SmartDialog.dismiss();
                await buildRecAccountLimitationDialog(
                  chatLimit: 3,
                  messageLimit: 30,
                );
              },
              leading: const Icon(Icons.speed),
              title: Text('Usage Limits'.tr),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  SmartDialog.dismiss();
                  String data = await DefaultAssetBundle.of(
                    context,
                  ).loadString("assets/model/language_code.json");
                  List jsonResult = jsonDecode(data);
                  await SmartDialog.show(
                    builder: (context) {
                      return Container(
                        height: getScreenWidth() - kDefaultPadding * 2,
                        width: getScreenWidth() - kDefaultPadding * 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                'Please select your language'.tr,
                                style: const TextStyle(color: kPrimaryColor),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(0),
                                itemBuilder: (context, index) {
                                  Map<dynamic, dynamic> res = jsonResult[index];
                                  return ListTile(
                                    onTap: () async {
                                      Get.updateLocale(
                                        Locale(
                                          res['language_code'],
                                          res['code'],
                                        ),
                                      );
                                      c.languageSetting.value =
                                          res['language_name'];
                                      c.languageFlag.value = res['flag'];
                                      SmartDialog.dismiss();
                                      await c.init();
                                    },
                                    leading: Text(
                                      res['flag']!,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    title: Text(res['language_name']!),
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
                child: ListTile(
                  leading: Obx(
                    () => Text(
                      c.languageFlag.value,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  title: AutoSizeText('Language Setting'.tr, maxLines: 1),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
