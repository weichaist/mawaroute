import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/edit_my_place_controller.dart';
import 'package:mawaroute_business/screens/edit_my_place_screen/place_dropdown.dart';
import 'package:mawaroute_business/screens/top_components/desktop/desktop_auth_sliver_appbar_v2.dart';
import 'package:mawaroute_business/screens/top_components/desktop/v2_admin_nav_rail.dart';
import 'package:mawaroute_business/screens/top_components/upload_file_dotted_container.dart';
import 'package:mawaroute_business/theme/constants.dart';

class EditMyPlaceScreen extends StatefulWidget {
  const EditMyPlaceScreen({super.key});

  @override
  State<EditMyPlaceScreen> createState() => _EditMyPlaceScreenState();
}

class _EditMyPlaceScreenState extends State<EditMyPlaceScreen> {
  @override
  Widget build(BuildContext context) {
    EditMyPlaceController placeController = EditMyPlaceController.instance;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      placeController.init();
    });
    return Title(
      title: 'My Place | MaWaRoute (マワルト)',
      color: kPrimaryColor,
      child: Scaffold(
        body: Row(
          children: [
            const V2AdminNavRail(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const DesktopAuthSliverAppBarV2(),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: kMaxWidth),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: Center(
                                child: ListTile(
                                  title: Text(
                                    'My Place'.tr,
                                    style: const TextStyle(fontSize: 27),
                                  ),
                                  subtitle: Text('Edit my place info'.tr),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: kMaxWidth),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ListTile(),
                            ListTile(
                              leading: const Icon(
                                CupertinoIcons.placemark_fill,
                                color: kPrimaryColor,
                              ),
                              title: Text('My Place Info'.tr),
                            ),
                            ListTile(
                              subtitle: Text('Profile Image'.tr),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding),
                              child: Obx(
                                () => CircleAvatar(
                                  backgroundColor: kPrimaryColor,
                                  backgroundImage: placeController
                                          .userProfileImageFile.value.name
                                          .contains("https://")
                                      ? NetworkImage(placeController
                                          .userProfileImageFile.value.name)
                                      : placeController.userProfileImageFile
                                                  .value.name !=
                                              ""
                                          ? MemoryImage(
                                              placeController
                                                  .userProfileImageFile
                                                  .value
                                                  .bytes!,
                                            ) as ImageProvider
                                          : null,
                                  radius: 48,
                                  child: IconButton(
                                    color: placeController
                                            .userProfileImageFile.value.name
                                            .contains("https://")
                                        ? Colors.transparent
                                        : Colors.white,
                                    onPressed: () async {
                                      FilePickerResult? result =
                                          await FilePicker.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['jpg', 'png'],
                                      );
                                      if (result != null) {
                                        placeController.changeUserProfileImage(
                                            result.files.single);
                                      }
                                    },
                                    icon: const Icon(Icons.photo_camera_back),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              subtitle: Text('List Image'.tr),
                            ),
                            Obx(
                              () => UploadFileDottedContainer(
                                file: placeController.imageFile.value,
                                callback: (file) =>
                                    placeController.changeImage(file),
                              ),
                            ),
                            ListTile(
                              subtitle: Text('Place Name'.tr),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding),
                              child: TextField(
                                  controller: placeController.name.value),
                            ),
                            ListTile(
                              subtitle: Text('Place Address'.tr),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding),
                              child: TextField(
                                  readOnly: true,
                                  controller: placeController.address.value),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: kDefaultPadding,
                                vertical: kDefaultPadding,
                              ),
                              child: TextFieldDialog(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: kDefaultPadding,
                                bottom: kDefaultPadding,
                              ),
                              child: ListTile(
                                leading: ElevatedButton(
                                  onPressed: () async {
                                    await placeController.onCreate();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith(
                                            (states) => kPrimaryColor),
                                  ),
                                  child: Text(
                                    'Save'.tr,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
