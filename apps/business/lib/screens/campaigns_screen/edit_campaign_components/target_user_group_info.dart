import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/edit_campaing_v2_controller.dart';
import 'package:mawaroute_business/enums.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/utility.dart';

class TargetUerGroupInfo extends StatelessWidget {
  const TargetUerGroupInfo({super.key});

  @override
  Widget build(BuildContext context) {
    EditCampaignV2Controller c = EditCampaignV2Controller.instance;
    return Column(
      children: [
        ListTile(
          title: TextField(
            controller: c.targetUserText.value,
            enabled: false,
            decoration: const InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: 'Who Can Join *',
              hintText: 'Select an Option',
              hintStyle: TextStyle(color: kTextColor),
              prefixIcon: Icon(
                Icons.arrow_drop_down,
                color: kPrimaryColor,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              color: kPrimaryColor,
              radius: const Radius.circular(12),
              padding: const EdgeInsets.all(6),
            ),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: TargetUser.values.length,
                  itemBuilder: (context, index) {
                    String targetUser = TargetUser.values[index].name;
                    return Obx(
                      () => ListTile(
                        leading: IconButton(
                          icon: Icon(
                            targetUserString[targetUser] ==
                                    c.selectedTargetUser.value
                                ? CupertinoIcons.check_mark_circled
                                : CupertinoIcons.circle,
                          ),
                          onPressed: () {
                            // c.targetUser.value.text = targetUser;
                            // c.changeSelectedTargetUser(
                            //     targetUserString[targetUser]!);
                          },
                        ),
                        title: Text(targetUserString[targetUser]!),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  // await c.onSaveTargetUserInfo();
                  showAlert('Not available now'.tr);
                },
                icon: const Icon(CupertinoIcons.floppy_disk),
                label: Text('Save'.tr),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
