import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../theme/constants.dart';
import '../../../theme/size_config.dart';

Future<dynamic> buildTooFarAwayDialog(double distance) {
  return SmartDialog.show(
    tag: 'faraway',
    animationType: SmartAnimationType.fade,
    builder: (context) => Container(
      width: getScreenWidth() - kDefaultPadding * 1.168 * 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Lottie.asset(
              'assets/lottie_files/far_away.json',
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            title: Text(
              '${'You are so far away'.tr}👩🏻‍🚀 ${distance.toStringAsFixed(0)}m',
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              onPressed: () {
                SmartDialog.dismiss(tag: 'faraway');
              },
              icon: const Icon(
                CupertinoIcons.right_chevron,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
