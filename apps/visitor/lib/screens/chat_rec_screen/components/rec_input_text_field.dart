import 'dart:io';

import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mawaroute_visitor/screens/chat_rec_screen/components/chat_rec_dialogs.dart';

import '../../../controllers/rec_chat_controller.dart';
import '../../../theme/constants.dart';
import '../../../theme/size_config.dart';

class RecScreenInputTextField extends StatelessWidget {
  const RecScreenInputTextField({super.key});
  @override
  Widget build(BuildContext context) {
    final c = RecChatController.instance;
    return SafeArea(
      bottom: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => c.imageFilePath.value.isNotEmpty
                ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      SizedBox(
                        height: getScreenWidth() / 1.618 / 1.618,
                        width: getScreenWidth() / 1.618,
                        child: ExtendedImage.file(
                          File(c.imageFilePath.value),
                          fit: BoxFit.contain,
                        ),
                      ).frosted(
                        frostColor: const Color(0xFF5DDFE5),
                        frostOpacity: 0.9,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          c.imageFilePath.value = '';
                        },
                        icon: const Icon(
                          CupertinoIcons.clear_circled,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          Builder(
            builder: (context) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: getScreenWidth(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Obx(
                        () => Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9.0,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  if (!c.mAvatar.value.proAvatar) {
                                    SmartDialog.showNotify(
                                      msg:
                                          '${c.mAvatar.value.name}${" does not support\nvision recommendation".tr}',
                                      notifyType: NotifyType.warning,
                                    );
                                    return;
                                  }
                                  await SmartDialog.showAttach(
                                    targetContext: context,
                                    alignment: Alignment.topLeft,
                                    maskColor: Colors.transparent,
                                    animationType: SmartAnimationType.fade,
                                    builder: (context) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(9.0),
                                            child:
                                                IconButton(
                                                  onPressed: () async {
                                                    c.imageFilePath.value = '';
                                                    SmartDialog.dismiss();
                                                    final XFile? res =
                                                        await ImagePicker()
                                                            .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .camera,
                                                            );
                                                    if (res != null) {
                                                      c.imageFilePath.value =
                                                          res.path;
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    CupertinoIcons.camera,
                                                    color: Colors.white,
                                                  ),
                                                ).frosted(
                                                  frostColor: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  frostOpacity: 1.0,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(9.0),
                                            child:
                                                IconButton(
                                                  onPressed: () async {
                                                    c.imageFilePath.value = '';
                                                    SmartDialog.dismiss();
                                                    final XFile? res =
                                                        await ImagePicker()
                                                            .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery,
                                                            );
                                                    if (res != null) {
                                                      c.imageFilePath.value =
                                                          res.path;
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    CupertinoIcons.photo,
                                                    color: Colors.white,
                                                  ),
                                                ).frosted(
                                                  frostColor: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  frostOpacity: 1.0,
                                                ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  CupertinoIcons.add,
                                  color: c.isStreaming.isTrue
                                      ? kHintTextColor
                                      : kPrimaryColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: c.inputController,
                                enabled: c.isStreaming.isFalse,
                                minLines: 1,
                                maxLines: 3,
                              ),
                            ),
                            c.isStreaming.isTrue
                                ? GestureDetector(
                                    onTap: () async {
                                      await c.cancelSubscription();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 9.0,
                                      ),
                                      child: Icon(
                                        CupertinoIcons.stop_circle,
                                        size: 30,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      if (c.chatsForDisplay.length >= 30) {
                                        await buildRecAccountLimitationDialog(
                                          chatLimit: 3,
                                          messageLimit: 12,
                                        );
                                        return;
                                      }
                                      if (c.imageFilePath.isNotEmpty) {
                                        c.addImageInputBubble();
                                      } else {
                                        c.addInputBubble();
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 9.0,
                                      ),
                                      child: Icon(
                                        CupertinoIcons.arrow_up_circle_fill,
                                        size: 30,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ).frosted(
                    frostColor: const Color(0xFF5DDFE5),
                    frostOpacity: 0.96,
                    blur: 0.9,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
