import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/theme/constants.dart';

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: kAlertColor,
              size: 96,
            ),
            const Text(
              '404',
              style: TextStyle(fontSize: 36),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/auth');
              },
              child: const Text(
                'Reload',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
