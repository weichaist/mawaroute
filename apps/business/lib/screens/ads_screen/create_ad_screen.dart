import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mawaroute_business/screens/top_components/desktop/components/shop_desktop_nav_rail.dart';
import 'package:mawaroute_business/theme/constants.dart';

import '../top_components/desktop/desktop_auth_sliver_appbar_v2.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  @override
  Widget build(BuildContext context) {
    return Title(
      title: '広告を作成 | MaWaRoute (マワルト)',
      color: kPrimaryColor,
      child: Scaffold(
        body: Row(
          children: [
            const ShopDesktopNavigationRail(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const DesktopAuthSliverAppBarV2(),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: kMaxWidth,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: Center(
                                child: ListTile(
                                  title: Text(
                                    '広告を作成',
                                    style: TextStyle(
                                      fontSize: 27,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'あなたのビジネスに、より多くの足を呼び込むためのお手伝いをします',
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Padding(
                                padding: EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: Text("以前の広告を再利用しますか？"),
                              ),
                              subtitle: Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    label: const Text('再利用する'),
                                    icon: const Icon(
                                      CupertinoIcons.arrow_2_circlepath,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const ListTile(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: kMaxWidth,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const ListTile(
                                    title: Text(
                                      '基本情報',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const ListTile(
                                    title: TextField(
                                      maxLength: 60,
                                      decoration: InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          labelText: 'タイトル *',
                                          hintText: 'タイトルを入力してください'),
                                    ),
                                  ),
                                  const ListTile(
                                    title: TextField(
                                      enabled: false,
                                      decoration: InputDecoration(
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelText: 'ターゲット顧客 *',
                                        hintText: 'ターゲット顧客を選択',
                                        hintStyle: TextStyle(color: kTextColor),
                                        prefixIcon: Icon(
                                          Icons.arrow_drop_down,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Checkbox(
                                      value: true,
                                      onChanged: (_) {},
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    title: const Text('全員'),
                                    trailing: const Icon(
                                        CupertinoIcons.person_3_fill),
                                  ),
                                  ListTile(
                                    leading: Checkbox(
                                      value: false,
                                      onChanged: (_) {},
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    title: const Text('購入履歴のあるお客様'),
                                    trailing: const Icon(CupertinoIcons.cart),
                                  ),
                                  ListTile(
                                    leading: Checkbox(
                                      value: false,
                                      onChanged: (_) {},
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    title: const Text('AI自動選択'),
                                    trailing: const Icon(Icons.auto_graph),
                                  ),
                                  const ListTile(),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          child: const Text(
                                            '作成する',
                                            style: TextStyle(
                                                color: kHintTextColor),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const ListTile(),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: kDefaultPadding),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color:
                                          kPrimaryLightColor.withValues(alpha: 0.3),
                                    ),
                                    child: const Column(
                                      children: [
                                        ListTile(
                                          title: Text('オーディエンスサイズ'),
                                          trailing: Icon(
                                              CupertinoIcons.question_circle),
                                        ),
                                        ListTile(
                                          leading: Icon(
                                              CupertinoIcons.person_3_fill),
                                          title: Text(
                                            '1200',
                                            style: TextStyle(fontSize: 48),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(CupertinoIcons.info),
                                          subtitle: Text(
                                            '近くにMaWaRouteを持って歩いているユーザー数',
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
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
