import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/rewards_controller.dart';
import '../../../models/shop_model.dart';
import '../../../theme/constants.dart';

void buildShopListDialog({
  required BuildContext context,
  required RewardController rewardController,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Shops'.tr),
        content: SizedBox(
          width: kMaxWidth,
          child: SingleChildScrollView(
            child: Obx(
              () => GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: kDefaultPadding,
                  mainAxisSpacing: kDefaultPadding,
                  childAspectRatio: 1,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rewardController.shops.length,
                itemBuilder: (context, index) {
                  ShopModel shop = rewardController.shops[index];
                  return GestureDetector(
                    onTap: () async {
                      rewardController.selectedShop.value = shop;
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(kDefaultPadding),
                            child: Center(
                              child: Stack(
                                children: [
                                  ExtendedImage.network(
                                    shop.downloadUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                  if (rewardController.selectedShop.value.uid ==
                                      shop.uid)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 36,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.place_outlined,
                            color: Colors.blue,
                          ),
                          title: Text(
                            shop.name,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'.tr),
          ),
        ],
      );
    },
  );
}
