import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/edit_campaing_v2_controller.dart';
import 'package:mawaroute_business/screens/top_components/date_time_input.dart';
import 'package:mawaroute_business/theme/constants.dart';

class BasicInfo extends StatelessWidget {
  const BasicInfo({super.key});
  @override
  Widget build(BuildContext context) {
    EditCampaignV2Controller c = EditCampaignV2Controller.instance;
    return Column(
      children: [
        Obx(
          () => ListTile(
            title: TextField(
              controller: c.title.value,
              maxLength: 60,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Title *'.tr,
                  hintText: 'Enter a descriptive title'.tr),
            ),
          ),
        ),
        ListTile(
          title: TextField(
            controller: c.description.value,
            maxLength: 480,
            maxLines: 3,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: 'Description *'.tr,
              hintText:
                  'Enter a description explaining the details of the campaign'
                      .tr,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          title: TextField(
            controller: c.campaignTimeLimit.value,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: 'Campaign time limit'.tr,
              hintText: 'Enter the time limit of this campaign'.tr,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          title: TextField(
            controller: c.maximumTaskNumber.value,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: 'Maximum task number'.tr,
              hintText: 'Enter the maximum task number of this campaign'.tr,
            ),
          ),
        ),
        const SizedBox(height: 20),
        DateTimeInput(
          labelText: 'Start Time *'.tr,
          initialValue: c.startTime.value,
          onDateSelected: (value) {
            c.startTime.value = value;
          },
        ),
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await c.onSaveBasicInfo();
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
