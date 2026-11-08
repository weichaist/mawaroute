import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/timetable_controller.dart';
import 'package:mawaroute_shop/theme/constants.dart';

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = TimeTableController.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.init();
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Set Time Table'.tr,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.clock,
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(3),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (c.days.length == index) {
                    return Padding(
                        padding: const EdgeInsets.only(
                          top: kDefaultPadding,
                          bottom: kDefaultPadding * 1.618 * 3,
                        ),
                        child: ListTile(
                          title: OutlinedButton(
                            onPressed: () async {
                              await c.updateTimeTable();
                            },
                            child: Text("Save".tr),
                          ),
                        ));
                  } else {
                    String day = c.days[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            child: Center(child: Text(day.tr)),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () {
                                    dynamic value = c.timeTableList[day];
                                    if (value != null) {
                                      value = value["open"];
                                    }
                                    value == null
                                        ? value = "Start Time"
                                        : value =
                                            value.format(context).toString();
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton(
                                          child: Text(value.toString().tr),
                                          onPressed: () async {
                                            await c.pickTime(
                                              context,
                                              day,
                                              "open",
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 4.0),
                                        if (value != "Start Time")
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () {
                                              c.timeTableList[day]!["open"] =
                                                  null;
                                              c.timeTableList.refresh();
                                              // Close button pressed
                                            },
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const Text(' ~ '),
                              Expanded(
                                child: Obx(
                                  () {
                                    dynamic value = c.timeTableList[day];
                                    if (value != null) {
                                      value = value["close"];
                                    }
                                    value == null
                                        ? value = "End Time"
                                        : value =
                                            value.format(context).toString();
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton(
                                          child: Text(value.toString().tr),
                                          onPressed: () async {
                                            await c.pickTime(
                                              context,
                                              day,
                                              "close",
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 4.0),
                                        if (value != "End Time")
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () {
                                              c.timeTableList[day]!["close"] =
                                                  null;
                                              c.timeTableList.refresh();
                                              // Close button pressed
                                            },
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
                childCount: c.days.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
