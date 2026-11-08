import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../theme/size_config.dart';

Future<dynamic> buildRecAccountLimitationDialog({
  required int chatLimit,
  required int messageLimit,
}) {
  return SmartDialog.show(
    builder: (_) {
      return Container(
        width: getScreenWidth() / 1.08,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Your Account Limitations'.tr)),
            ListTile(
              leading: const Icon(CupertinoIcons.chat_bubble_2_fill),
              title: Text(chatLimit.toString()),
              subtitle: Text(
                'Maximum number of chats you can initiate per day'.tr,
              ),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.arrow_up_circle_fill),
              title: Text(messageLimit.toString()),
              subtitle: Text(
                'Maximum number of messages allows in each chat'.tr,
              ),
            ),
            const Divider(),
            ListTile(
              dense: true,
              title: Text(
                'Please note that these limitations are in place to ensure a quality experience for all users.'
                    .tr,
              ),
            ),
            ListTile(
              title: SelectableText(
                "If you'd like to unlock more capabilities, please download mawaroute app"
                    .tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    },
  );
}
