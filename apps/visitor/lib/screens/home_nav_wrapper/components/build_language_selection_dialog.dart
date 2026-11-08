import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../theme/constants.dart';
import '../../../theme/size_config.dart';

Future<dynamic> buildLanguageSelectionDialog(
  BuildContext context,
  Function(Map) callback,
) async {
  String data = await DefaultAssetBundle.of(
    context,
  ).loadString("assets/model/language_code.json");
  List jsonResult = jsonDecode(data);
  return await SmartDialog.show(
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
                    onTap: () {
                      callback(res);
                      SmartDialog.dismiss();
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
