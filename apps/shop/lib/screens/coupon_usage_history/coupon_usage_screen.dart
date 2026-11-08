import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/models/reward_receiver_model.dart';
import 'package:mawaroute_shop/theme/constants.dart';

import '../../controllers/coupon_usage_controller.dart';
import '../../utils/date_formatter.dart';

class CouponUsageScreen extends StatelessWidget {
  const CouponUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CouponUsageController couponUsageController =
        CouponUsageController.instance;
    couponUsageController.init();
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: kPrimaryColor,
        color: Colors.white,
        displacement: 96,
        onRefresh: () async {
          HapticFeedback.heavyImpact();
          await Future.delayed(
            const Duration(seconds: 1),
          );
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                'Coupon History'.tr,
              ),
            ),
            Obx(
              () => SliverList.builder(
                itemBuilder: (context, index) {
                  RewardReceiverModel usage =
                      couponUsageController.couponUsages[index];
                  return Column(
                    children: [
                      ListTile(
                        subtitle: Text(
                          'Coupon is applied'.tr,
                        ),
                        title: Text(
                          dateString(usage.timestamp),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider()
                    ],
                  );
                },
                itemCount: couponUsageController.couponUsages.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
