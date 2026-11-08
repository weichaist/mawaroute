import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../../controllers/web_chat_controller.dart';
import '../../../theme/constants.dart';
import '../../../theme/size_config.dart';

Future<dynamic> buildLanguageSelector(BuildContext context) async {
  String data = await DefaultAssetBundle.of(
    context,
  ).loadString("assets/files/language_code.json");
  List jsonResult = jsonDecode(data);
  WebChatController c = WebChatController.instance;
  return SmartDialog.show(
    keepSingle: true,
    builder: (context) {
      return Container(
        height: getScreenHeight() / 1.618,
        width: getScreenWidth() / 1.2,
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
                      SmartDialog.dismiss();
                      c.languageSetting.value = res['language_name'];
                      await c.clearForLanguageChange();
                      await Get.updateLocale(
                        Locale(res['language_code'], res['code']),
                      );
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
}
