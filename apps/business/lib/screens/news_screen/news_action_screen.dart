import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/news_controller.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';
import '../top_components/desktop/v2_admin_nav_rail.dart';

class NewsActionScreen extends StatelessWidget {
  const NewsActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NewsController c = NewsController.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await c.initUpdate();
    });
    return Obx(
      () => Title(
        title:
            '${c.isEdit.isTrue == true ? "Edit" : "Create"} News | MaWaRoute (マワルト)',
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
                          constraints:
                              const BoxConstraints(maxWidth: kMaxWidth),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 180,
                                width: double.infinity,
                                child: Center(
                                  child: ListTile(
                                    title: Text(
                                      (c.isEdit.isTrue
                                              ? "Edit News".tr
                                              : "Create News".tr)
                                          .tr,
                                      style: const TextStyle(fontSize: 27),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ReactiveForm(
                        formGroup: c.newsForm,
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: kMaxWidth),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ListTile(
                                        title: ReactiveTextField(
                                          readOnly: false,
                                          formControlName: 'title',
                                          maxLength: 30,
                                          validationMessages: {
                                            'required': (error) =>
                                                'This field must not be empty'
                                                    .tr,
                                            'maxLength': (error) =>
                                                'Text is too long'.tr,
                                          },
                                          decoration: InputDecoration(
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelText: 'News Title *'.tr,
                                            hintText:
                                                'Enter a descriptive news title'
                                                    .tr,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: ReactiveTextField(
                                          readOnly: false,
                                          formControlName: 'body',
                                          maxLength: 90,
                                          validationMessages: {
                                            'required': (error) =>
                                                'This field must not be empty'
                                                    .tr,
                                            'maxLength': (error) =>
                                                'Text is too long'.tr,
                                          },
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelText: 'News Description *'.tr,
                                            hintText:
                                                'Enter a description explaining the details of the news'
                                                    .tr,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: ReactiveTextField(
                                          readOnly: false,
                                          formControlName: 'link',
                                          maxLength: 255,
                                          validationMessages: {
                                            'required': (error) =>
                                                'This field must not be empty'
                                                    .tr,
                                            'maxLength': (error) =>
                                                'Text is too long'.tr,
                                          },
                                          decoration: InputDecoration(
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelText: 'News Link *'.tr,
                                            hintText: 'Enter a valid url'.tr,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: ReactiveTextField(
                                          readOnly: false,
                                          formControlName: 'leadingIcon',
                                          maxLength: 1,
                                          validationMessages: {
                                            'required': (error) =>
                                                'This field must not be empty'
                                                    .tr,
                                            'maxLength': (error) =>
                                                'Text is too long'.tr,
                                          },
                                          decoration: InputDecoration(
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelText: 'News Leading Icon *'.tr,
                                            hintText: 'Enter a Icon'.tr,
                                          ),
                                        ),
                                      ),
                                      const Divider(color: Colors.transparent),
                                      const ListTile(),
                                      ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                await c.onSave();
                                              },
                                              child: Text(
                                                'Create News'.tr,
                                              ),
                                            ),
                                            //make a button to delete news
                                            if (c.isEdit.isTrue)
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await c.deleteNews();
                                                },
                                                child: Text(
                                                  'Delete News'.tr,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const ListTile(),
                                    ],
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
