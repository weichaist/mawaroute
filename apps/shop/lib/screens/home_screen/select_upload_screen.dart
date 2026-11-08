import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/home_controller.dart';
import 'package:mawaroute_shop/theme/constants.dart';
import 'package:mawaroute_shop/theme/size_config.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class SelectUploadScreen extends StatelessWidget {
  const SelectUploadScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = HomeController.instance;
    c.initUpload();
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text(
                '📸',
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: SizedBox(
                    width: getScreenWidth() - kDefaultPadding,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Column(
                        children: [
                          ListTile(
                            isThreeLine: true,
                            title: Text(
                              'Upload shop image'.tr,
                              style: const TextStyle(
                                  fontSize: 18, color: kPrimaryColor),
                            ),
                            subtitle: Text(
                              'Image metadata (latitude, longitude) can be uploaded at the same time for your convenience.'
                                  .tr,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              leading: OutlinedButton.icon(
                                onPressed: () async {
                                  final List<AssetEntity>? result =
                                      await AssetPicker.pickAssets(
                                    context,
                                    pickerConfig: const AssetPickerConfig(
                                        maxAssets: 10,
                                        themeColor: kPrimaryColor,
                                        requestType: RequestType.image),
                                  );
                                  if (result != null) {
                                    List<AssetEntity> resultForCheck = [];
                                    for (AssetEntity imageFile in result) {
                                      if (imageFile.latitude == 0 &&
                                          imageFile.longitude == 0) {
                                        EasyLoading.showToast(
                                          'Image without geo info cannot be uploaded'
                                              .tr,
                                          toastPosition:
                                              EasyLoadingToastPosition.bottom,
                                        );
                                      } else {
                                        resultForCheck.add(imageFile);
                                      }
                                    }
                                    c.selectedImages.value = resultForCheck;
                                  }
                                },
                                icon: const Icon(
                                    CupertinoIcons.photo_on_rectangle),
                                label: Text('SELECT'.tr),
                              ),
                            ),
                          ),
                          // ListTile(
                          //   title: const Text("Description"),
                          //   subtitle: TextField(
                          //     controller: c.descriptionController,
                          //   ),
                          // ),
                          // ListTile(
                          //   title: const Text("Type"),
                          //   subtitle: TextField(
                          //     controller: c.typeController,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: kDefaultPadding,
              ),
              sliver: Obx(
                () => SliverGrid.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  children: List.generate(
                    c.selectedImages.length,
                    (index) {
                      final image = c.selectedImages[index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: kPrimaryColor,
                              image: DecorationImage(
                                image: AssetEntityImageProvider(
                                  image,
                                  isOriginal: true,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (c.selectedImages[index].latitude! == 0)
                            Positioned(
                              top: 3,
                              right: 3,
                              child: GestureDetector(
                                onTap: () async {
                                  await EasyLoading.showError(
                                      'Coordinate data error');
                                  c.selectedImages.removeAt(index);
                                },
                                child: const Icon(
                                  Icons.error,
                                  size: 24,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          Positioned(
                            top: 3,
                            left: 3,
                            child: GestureDetector(
                              onTap: () {
                                c.selectedImages.removeAt(index);
                              },
                              child: const CircleAvatar(
                                backgroundColor: kPrimaryColor,
                                radius: 12,
                                child: Icon(
                                  Icons.delete,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        Obx(
          () => c.selectedImages.isNotEmpty
              ? Positioned(
                  bottom: 9,
                  right: 9,
                  child: SafeArea(
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        await c.upload();
                      },
                      label: const Text('Upload'),
                      icon: const Icon(Icons.cloud_upload_outlined),
                    ),
                  ),
                )
              : const SizedBox(),
        )
      ],
    );
  }
}
