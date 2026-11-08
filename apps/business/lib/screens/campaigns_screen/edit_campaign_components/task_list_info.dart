import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/edit_campaing_v2_controller.dart';
import 'package:mawaroute_business/models/campaign_task_image_model.dart';
import 'package:mawaroute_business/models/campaign_task_model.dart';
import 'package:mawaroute_business/screens/top_components/upload_file_dotted_container.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/utility.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TasksListInfo extends StatelessWidget {
  const TasksListInfo({super.key});
  @override
  Widget build(BuildContext context) {
    EditCampaignV2Controller c = EditCampaignV2Controller.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => ListView.builder(
            key: UniqueKey(),
            shrinkWrap: true,
            itemCount: c.campaignTasks.length,
            itemBuilder: (context, index) {
              CampaignTaskModel campaignTask = c.campaignTasks[index];
              return EditCampaignWidget(
                campaignTask: campaignTask,
                index: index,
                isFirst: index == 0,
                isLast: index == c.campaignTasks.length - 1,
                delete: () {
                  Get.defaultDialog(
                    title: 'Do you want to delete the task?',
                    content: Column(
                      children: [
                        ListTile(
                          title: OutlinedButton(
                            child: const Text('Delete'),
                            onPressed: () {
                              c.removeCampaignTask(index);
                            },
                          ),
                        ),
                        ListTile(
                          title: OutlinedButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Get.back();
                            },
                          ),
                        )
                      ],
                    ),
                  );
                },
                moveDown: () {
                  c.moveTaskDownInOrder(index);
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await c.onSaveCampaignTaskInfo();
                },
                icon: const Icon(CupertinoIcons.floppy_disk),
                label: Text('Save'.tr),
              ),
              const SizedBox(width: kDefaultPadding),
              ElevatedButton.icon(
                onPressed: () async {
                  Get.dialog(const EditDialog(isShop: false));
                },
                icon: const Icon(CupertinoIcons.add),
                label: Text('Add New Task'.tr),
              ),
              const SizedBox(width: kDefaultPadding),
              ElevatedButton.icon(
                onPressed: () async {
                  Get.dialog(const EditDialog(isShop: true));
                },
                icon: const Icon(CupertinoIcons.building_2_fill),
                label: Text('Select From Shops'.tr),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditCampaignWidget extends StatefulWidget {
  final CampaignTaskModel campaignTask;
  final int index;
  final bool isFirst;
  final bool isLast;
  final Function delete;
  final Function moveDown;
  const EditCampaignWidget({
    super.key,
    required this.campaignTask,
    required this.index,
    this.isFirst = false,
    this.isLast = false,
    required this.delete,
    required this.moveDown,
  });

  @override
  State<EditCampaignWidget> createState() => _EditCampaignWidgetState();
}

class _EditCampaignWidgetState extends State<EditCampaignWidget> {
  final hintTextController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  var campaignTaskFile = PlatformFile(name: '', size: 0);

  @override
  void initState() {
    hintTextController.text = widget.campaignTask.description;
    latController.text = !widget.campaignTask.lat.isNaN
        ? widget.campaignTask.lat.toString()
        : "";
    lngController.text = !widget.campaignTask.lng.isNaN
        ? widget.campaignTask.lng.toString()
        : "";
    String name = widget.campaignTask.downloadUrl!;
    if (widget.campaignTask.image != null) {
      campaignTaskFile = widget.campaignTask.image!;
    } else if (name != '') {
      campaignTaskFile = PlatformFile(name: name, size: 1);
    }
    super.initState();
  }

  @override
  void dispose() {
    hintTextController.dispose();
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.7,
      indicatorStyle: IndicatorStyle(
        width: 30,
        color: Colors.transparent,
        padding: const EdgeInsets.all(8),
        iconStyle: IconStyle(
          color: kPrimaryColor,
          iconData: Icons.circle_outlined,
        ),
      ),
      isFirst: widget.isFirst,
      isLast: widget.isLast,
      beforeLineStyle: const LineStyle(thickness: 3, color: kPrimaryLightColor),
      afterLineStyle: const LineStyle(thickness: 3, color: kPrimaryColor),
      endChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Task ${widget.index + 1}'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                Get.dialog(EditDialog(
                  index: widget.index,
                  isShop: widget.campaignTask.shopUid!.isNotEmpty,
                ));
              },
              child: const Text('Edit', style: TextStyle(fontSize: 10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                widget.delete();
              },
              child: const Text('Delete', style: TextStyle(fontSize: 10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              onPressed: () {
                widget.moveDown();
              },
              child: const Text('Move down', style: TextStyle(fontSize: 10)),
            ),
          )
        ],
      ),
      startChild: SizedBox(
        height: 510,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: TextField(
                enabled: false,
                controller: hintTextController,
                decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Hint Text *',
                    hintText: 'Enter the hint text'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9.0),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: TextField(
                        enabled: false,
                        controller: latController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(doubleFormat),
                        ],
                        decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Latitude *',
                            hintText: 'Latitude of where the picture is taken'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: TextField(
                        enabled: false,
                        controller: lngController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(doubleFormat),
                        ],
                        decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Longitude *',
                            hintText:
                                'Longitude of where the picture is taken'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            UploadFileDottedContainer(
              file: campaignTaskFile,
              absorb: true,
            ),
          ],
        ),
      ),
    );
  }
}

class EditDialog extends StatelessWidget {
  final int? index;
  final bool isShop;
  const EditDialog({
    super.key,
    this.index,
    required this.isShop,
  });

  @override
  Widget build(BuildContext context) {
    EditCampaignV2Controller c = EditCampaignV2Controller.instance;
    ScrollController scrollController = ScrollController();
    if (index != null) {
      c.setCampaignTaskForEditing(index!);
    } else {
      c.clearCampaignTaskForEditing();
    }
    return SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Task Details'.tr,
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
        SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: TextField(
                  readOnly: isShop,
                  controller: c.hintTextController.value,
                  decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'About the task *'.tr,
                      hintText: 'Give user some hints about the task'.tr),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: TextField(
                          controller: c.latController.value,
                          readOnly: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(doubleFormat),
                          ],
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Latitude *'.tr,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: TextField(
                          controller: c.lngController.value,
                          readOnly: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(doubleFormat),
                          ],
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Longitude *'.tr,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => UploadFileDottedContainer(
                  absorb: true,
                  file: c.campaignTaskFile.value,
                  callback: (file) {},
                ),
              ),
              ListTile(
                subtitle: Text('Picker a task image from library'.tr),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: kDefaultPadding,
                  horizontal: kDefaultPadding / 1.35,
                ),
                height: 360,
                width: 700,
                child: Obx(
                  () {
                    List<CampaignTaskImageModel> images = isShop
                        ? c.shopImages.value.results
                        : c.campaignTaskImages.value.results;
                    int itemCount = images.length;
                    return Scrollbar(
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      thumbVisibility: true,
                      trackVisibility: true,
                      controller: scrollController,
                      child: GridView.builder(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(bottom: kDefaultPadding),
                        key: UniqueKey(),
                        shrinkWrap: true,
                        itemCount: itemCount + 1,
                        itemBuilder: (context, index) {
                          if (index == itemCount) {
                            return Container(
                              padding: const EdgeInsets.all(kDefaultPadding),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  if (isShop) {
                                    c.fetchShopImages(init: false);
                                    if (c.shopImages.value.isLast) {
                                      showToast('All shops are fetched!');
                                    }
                                  } else {
                                    c.fetchCampaignTaskImages(init: false);
                                    showToast('All images are fetched!');
                                  }
                                },
                                icon: const Icon(
                                  Icons.cloud_download,
                                  color: kPrimaryColor,
                                ),
                                label: const Text(
                                  'More',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            CampaignTaskImageModel taskImage = images[index];
                            return GestureDetector(
                              onTap: () {
                                c.selectTaskImageFromGallery(taskImage);
                              },
                              child: SizedBox(
                                height: 300,
                                width: 300,
                                child: Obx(
                                  () => Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: ExtendedImage.network(
                                          height: 300,
                                          width: 300,
                                          taskImage.downloadUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: c.campaignTaskFile.value.name ==
                                                taskImage.downloadUrl
                                            ? Colors.green
                                            : Colors.white,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                        ),
                      ),
                    );
                  },
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  c.updateCampaignTaskImage(index: index);
                },
                child: Text('Save'.tr),
              )
            ],
          ),
        )
      ],
    );
  }
}

class CampaignWidget extends StatelessWidget {
  final String description;
  final Uint8List image;
  final double lat;
  final double lng;
  final bool isFirst;
  final bool isLast;
  const CampaignWidget({
    super.key,
    required this.description,
    required this.image,
    required this.lat,
    required this.lng,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.618,
      indicatorStyle: IndicatorStyle(
        width: 30,
        color: Colors.transparent,
        padding: const EdgeInsets.all(8),
        iconStyle: IconStyle(
          color: kPrimaryColor,
          iconData: Icons.circle_outlined,
        ),
      ),
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: const LineStyle(thickness: 3, color: kPrimaryColor),
      afterLineStyle: const LineStyle(thickness: 3, color: kPrimaryColor),
      startChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text(description),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text('lat ${lat.toString()} - lng ${lng.toString()}'),
          ),
          Container(
            margin: const EdgeInsets.all(9),
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(image, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
