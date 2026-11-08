import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:mawaroute_visitor/theme/size_config.dart';

import '../../controllers/capture_product_image_controller.dart';
import '../top_level_components/common_widgets/build_too_far_away_dialog.dart';
import '../top_level_components/common_widgets/single_click_elevated_button.dart';

class CaptureImageToEarnScreen extends StatelessWidget {
  const CaptureImageToEarnScreen({super.key});
  @override
  Widget build(BuildContext context) {
    CaptureProductImageController c = CaptureProductImageController.instance;
    c.init();
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Obx(
        () => c.isLoading.isFalse
            ? SafeArea(
                child: Container(
                  color: kPrimaryColor,
                  height: getScreenHeight(),
                  width: getScreenWidth(),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Obx(
                            () => DottedBorder(
                              options: const RoundedRectDottedBorderOptions(
                                color: Colors.white,
                                dashPattern: [9, 9],
                                radius: Radius.circular(12),
                                padding: EdgeInsets.all(9),
                              ),
                              child: c.capturedImagePath.value.isNotEmpty
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Image.file(
                                        File(c.capturedImagePath.value),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.back();
                                // c.capturedImagePath.value = '';
                              },
                              child: const CircleAvatar(
                                radius: 24,
                                backgroundColor: kPrimaryContainerColor,
                                child: Icon(CupertinoIcons.back),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                c.capturedImagePath.value = '';
                                final XFile? res = await ImagePicker()
                                    .pickImage(source: ImageSource.camera);
                                if (res != null) {
                                  c.capturedImagePath.value = res.path;
                                }
                              },
                              child: const CircleAvatar(
                                radius: 36,
                                backgroundColor: kPrimaryContainerColor,
                                child: Icon(
                                  CupertinoIcons.camera_viewfinder,
                                  size: 36,
                                ),
                              ),
                            ),
                            SingleClickElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith(
                                  (states) => kPrimaryContainerColor,
                                ),
                              ),
                              onPressed: () async {
                                if (c.capturedImagePath.isEmpty) return;
                                if (c.calculateDistance() >
                                    c.thresholdDistance) {
                                  await buildTooFarAwayDialog(
                                    c.calculateDistance(),
                                  );
                                  return;
                                }
                                SmartDialog.showLoading(
                                  msg: 'Calculating similarity...'.tr,
                                );
                                await c.runAISimilarityCalculation();
                                SmartDialog.dismiss();
                                buildSimilarityScoreDialog(c);
                              },
                              child: Text(
                                'SUBMIT'.tr,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: DottedBorder(
                            options: const RoundedRectDottedBorderOptions(
                              color: Colors.white,
                              dashPattern: [9, 9],
                              radius: Radius.circular(12),
                              padding: EdgeInsets.all(9),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: c.url.isNotEmpty
                                  ? ExtendedImage.network(c.url.value)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const Center(
                child: CupertinoActivityIndicator(color: Colors.white),
              ),
      ),
    );
  }

  Future<dynamic> buildSimilarityScoreDialog(CaptureProductImageController c) {
    return SmartDialog.show(
      animationType: SmartAnimationType.fade,
      clickMaskDismiss: false,
      builder: (context) => Container(
        height: getScreenWidth() - kDefaultPadding * 1.168 * 2,
        width: getScreenWidth() - kDefaultPadding * 1.168 * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: c.similarityScore >= c.similarityThreshold
                    ? Lottie.asset('assets/lottie_files/pixel_coin_rain.json')
                    : Lottie.asset('assets/lottie_files/wrong.json'),
              ),
            ),
            ListTile(
              title: Text(
                '${'Score'.tr}: ${(c.similarityScore * 100).toStringAsFixed(2)}%',
              ),
              subtitle: c.similarityScore >= c.similarityThreshold
                  ? Text('Congrats!!! You have found the spot!'.tr)
                  : Text(
                      'Oops... Your score is below 50% similarity 🥲 , please Try again'
                          .tr,
                    ),
            ),
            ListTile(
              title: const Text(
                '',
                style: TextStyle(fontSize: 12, color: kHintTextColor),
              ),
              trailing: SingleClickElevatedButton(
                onPressed: () async {
                  if (c.similarityScore >= c.similarityThreshold) {
                    SmartDialog.dismiss();
                    Get.back(result: c.capturedImageUploadedUrl.value);
                  } else {
                    await c.addFailedTask();
                    SmartDialog.dismiss();
                  }
                },
                child: c.similarityScore >= c.similarityThreshold
                    ? Text('OK'.tr)
                    : Text('Try again'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
