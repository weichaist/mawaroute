import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/theme/constants.dart';

class EditSingleFieldScreen extends StatelessWidget {
  const EditSingleFieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String fieldName = Get.arguments["fieldName"];
    String value = Get.arguments["fieldValue"];
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            automaticallyImplyLeading: false,
            leading: const BackButton(color: Colors.black),
            title: Text(
              'Edit $fieldName'.tr,
              style: const TextStyle(color: kPrimaryColor),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 3),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    title: TextFormField(
                      initialValue: value,
                      maxLength: 270,
                      maxLines: fieldName == 'Shop Description' ? 15 : 1,
                      minLines: fieldName == 'Shop Description' ? 5 : 1,
                      onChanged: (e) {
                        value = e;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.transparent,
                  ),
                  ListTile(
                    dense: true,
                    title: ElevatedButton(
                      onPressed: () {
                        if (fieldName == 'Marketing URL') {
                          if (!value.isURL) {
                            SmartDialog.showNotify(
                                msg: 'Not valid URL'.tr,
                                notifyType: NotifyType.failure);
                            return;
                          }
                        }
                        Get.back(result: value);
                      },
                      child: Text("Save".tr),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
