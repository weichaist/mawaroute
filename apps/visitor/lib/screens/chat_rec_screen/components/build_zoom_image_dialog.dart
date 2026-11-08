import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../../theme/constants.dart';
import '../../../theme/size_config.dart';

Future buildZoomImageDialog(String imageUrl) async {
  return SmartDialog.show(
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: getScreenWidth(),
            width: getScreenWidth(),
            child: ExtendedImage.network(
              imageUrl,
              fit: BoxFit.contain,
              //enableLoadState: false,
              mode: ExtendedImageMode.gesture,
              initGestureConfigHandler: (state) {
                return GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 3.0,
                  animationMaxScale: 3.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: false,
                  initialAlignment: InitialAlignment.center,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: IconButton(
              onPressed: () {
                SmartDialog.dismiss();
              },
              icon: const Icon(Icons.close),
              color: Colors.white,
              style: ButtonStyle(
                backgroundColor: WidgetStateColor.resolveWith(
                  (states) => kPrimaryColor,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
