import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../../controllers/email_dialog_controller.dart';
import '../../../theme/constants.dart';
import '../../../theme/size_config.dart';
import '../../top_level_components/common_widgets/single_click_text_button.dart';

Future<dynamic> buildEmailDialog() {
  EmailDialogController controller = EmailDialogController.instance;
  return SmartDialog.show(
    alignment: Alignment.topCenter,
    animationType: SmartAnimationType.fade,
    clickMaskDismiss: false,
    builder: (context) => SafeArea(
      child: Container(
        width: getScreenWidth() - kDefaultPadding * 1.168 * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.transparent),
            ListTile(
              title: Text(
                'To claim your reward, please provide your email address and click Submit'
                    .tr,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              title: TextField(
                controller: controller.email.value,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  SingleClickTextButton(
                    child: Text('Cancel'.tr),
                    onPressed: () async {
                      SmartDialog.dismiss(result: false);
                    },
                  ),
                  SingleClickTextButton(
                    child: Text('Submit'.tr),
                    onPressed: () async {
                      String email = controller.email.value.text;
                      bool isValidEmail = RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                      ).hasMatch(email);
                      if (isValidEmail) {
                        controller.saveEmail(email);
                        SmartDialog.dismiss(result: true);
                      } else {
                        SmartDialog.showNotify(
                          msg: 'Invalid email address'.tr,
                          notifyType: NotifyType.failure,
                        );
                        if (kDebugMode) print('Invalid email!');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
