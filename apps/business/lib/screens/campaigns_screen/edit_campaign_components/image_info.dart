import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/edit_campaing_v2_controller.dart';
import 'package:mawaroute_business/screens/top_components/upload_file_dotted_container.dart';
import 'package:mawaroute_business/theme/constants.dart';

class ImageInfoSection extends StatelessWidget {
  const ImageInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    EditCampaignV2Controller c = EditCampaignV2Controller.instance;
    return Column(
      children: [
        ListTile(
          subtitle: Text('Banner Image (ratio 6.3:1)'.tr),
        ),
        Obx(
          () => UploadFileDottedContainer(
            file: c.bannerImageFile.value,
            height: 100,
            width: 630,
            callback: (file) => c.changeBannerImage(file),
          ),
        ),
        ListTile(
          subtitle: Text('List Image (ratio 1:1)'.tr),
        ),
        Obx(
          () => UploadFileDottedContainer(
            file: c.imageFile.value,
            height: 300,
            width: 300,
            callback: (file) => c.changeImage(file),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await c.onSaveImageInfo();
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
