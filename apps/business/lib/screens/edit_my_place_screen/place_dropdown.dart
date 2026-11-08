import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/models/google_map_model.dart';

import '../../controllers/edit_my_place_controller.dart';
import '../../theme/constants.dart';

class TextFieldDialog extends StatefulWidget {
  const TextFieldDialog({super.key});

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EditMyPlaceController placeController = EditMyPlaceController.instance;

    return ElevatedButton(
      child: Text('Place Address'.tr),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search place'.tr,
                    style: const TextStyle(
                      color: kPrimaryLightColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    splashRadius: 24,
                    splashColor: kPrimaryLightColor,
                    icon: const Icon(CupertinoIcons.clear),
                  ),
                ],
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  height: 420,
                  width: 450,
                  child: Obx(
                    () => Column(
                      children: [
                        TextFormField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Search place'.tr,
                            suffixIcon: GestureDetector(
                              onTap: () async {
                                await placeController
                                    .callPlaceApi(_textController.value.text);
                              },
                              child: const Icon(Icons.search),
                            ),
                          ),
                          onFieldSubmitted: (value) async {
                            await placeController.callPlaceApi(value);
                          },
                        ),
                        const SizedBox(height: 10),
                        if (placeController.places.isNotEmpty)
                          Container(
                            height: 250,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                itemCount: placeController.places.length,
                                itemBuilder: (BuildContext context, int index) {
                                  GoogleMap place =
                                      placeController.places[index];
                                  return GestureDetector(
                                      onTap: () {
                                        placeController.selectedIndex.value =
                                            index;
                                        placeController.name.value.text =
                                            place.name;
                                        placeController.address.value.text =
                                            place.formattedAddress;
                                        placeController.lat.value.text =
                                            place.lat.toString();
                                        placeController.lng.value.text =
                                            place.lng.toString();
                                        Get.back();
                                      },
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Text(place.name),
                                            subtitle:
                                                Text(place.formattedAddress),
                                            trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Obx(
                                                  () => Icon(
                                                    placeController
                                                                .selectedIndex
                                                                .value ==
                                                            index
                                                        ? Icons
                                                            .check_circle_outline
                                                        : Icons.circle_outlined,
                                                    color: kPrimaryColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          const Divider(),
                                        ],
                                      ));
                                }),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
