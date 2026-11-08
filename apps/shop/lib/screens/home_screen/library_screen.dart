import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/screens/home_screen/select_upload_screen.dart';
import 'package:mawaroute_shop/theme/constants.dart';
import 'package:mawaroute_shop/utils/date_formatter.dart';

import '../../controllers/home_controller.dart';
import '../../models/shop_image_model.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = HomeController.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      c.initList();
    });
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            Obx(
              () => SliverAppBar(
                title: Image.asset(
                  'assets/images/mawaroute_text.png',
                  height: 24,
                ),
                centerTitle: false,
                actions: [
                  IconButton(
                    onPressed: () {
                      Get.to(() => const SelectUploadScreen());
                    },
                    icon: const Icon(
                      Icons.drive_folder_upload,
                      color: kPrimaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      c.multipleSelectionMode.value =
                          !c.multipleSelectionMode.value;
                      c.selectedPictures.clear();
                    },
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: kPrimaryColor,
                    ),
                  ),
                  if (c.multipleSelectionMode.isTrue)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Text(
                        c.selectedPictures.length.toString(),
                      ),
                    ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: kDefaultPadding,
              ),
              sliver: Obx(
                () => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = c.shopImages.entries.elementAt(index);
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: kDefaultPadding * 1.618),
                            child: Text(
                              dateString(entry.key),
                            ),
                          ),
                          GroupImageGrid(
                            taskImages: entry.value,
                          ),
                          // const Divider()
                        ],
                      );
                    },
                    childCount: c.shopImages.entries.length,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(
                () => c.isLastPage.isFalse
                    ? ListTile(
                        title: ElevatedButton.icon(
                          icon: const Icon(CupertinoIcons.down_arrow),
                          onPressed: () async {
                            await c.fetchShopImages();
                          },
                          label: const Text('More'),
                        ),
                        subtitle: const Text(''),
                      )
                    : const ListTile(),
              ),
            ),
          ],
        ),
        Obx(
          () => Positioned(
            bottom: 9,
            right: 9,
            child: c.multipleSelectionMode.isTrue
                ? FloatingActionButton(
                    backgroundColor: kAlertColor,
                    onPressed: () async {
                      await c.deleteImages();
                    },
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ],
    );
  }
}

class GroupImageGrid extends StatelessWidget {
  const GroupImageGrid({
    super.key,
    required this.taskImages,
  });
  final List<ShopImageModel> taskImages;
  @override
  Widget build(BuildContext context) {
    final c = HomeController.instance;
    return GridView.count(
      padding: const EdgeInsets.only(top: 9),
      crossAxisCount: 2,
      childAspectRatio: 1,
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: List.generate(
        taskImages.length,
        (index) {
          final campaignTaskImage = taskImages[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (c.multipleSelectionMode.isTrue) {
                    if (c.selectedPictures.contains(campaignTaskImage.uid)) {
                      c.selectedPictures.remove(campaignTaskImage.uid);
                    } else {
                      c.selectedPictures.add(campaignTaskImage.uid!);
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: kPrimaryContainerColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExtendedImage.network(
                      campaignTaskImage.downloadUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 3,
                left: 3,
                child: Obx(
                  () => c.selectedPictures.contains(campaignTaskImage.uid)
                      ? const CircleAvatar(
                          backgroundColor: kPrimaryColor,
                          radius: 12,
                          child: Icon(
                            Icons.check_outlined,
                            size: 15,
                            color: Colors.white,
                          ),
                        )
                      : const SizedBox(),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
