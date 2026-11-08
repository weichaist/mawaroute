import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/screens/top_components/all_rights_reserved_bar.dart';
import 'package:mawaroute_business/screens/top_components/desktop/desktop_auth_sliver_appbar.dart';
import 'package:mawaroute_business/theme/constants.dart';
import 'package:mawaroute_business/theme/responsive.dart';
import 'package:mawaroute_business/theme/size_config.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Title(
      title: 'MaWaRoute -Sign In',
      color: kTextColor,
      child: const Scaffold(
        backgroundColor: kBgColor,
        body: LoginBody(),
        bottomNavigationBar: BottomAllRightsReserved(),
      ),
    );
  }
}

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = AuthController.instance;
    return Responsive(
      desktop: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/auth_cover.png',
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                const DesktopAuthSliverAppBar(),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        height: kDefaultHeight,
                        constraints: const BoxConstraints(maxWidth: kMaxWidth),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: 360,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ListTile(
                                          subtitle: TextField(
                                              onChanged: (String value) {
                                            authController.email.value = value;
                                          }),
                                          title: const Text('Email'),
                                        ),
                                        ListTile(
                                          title: const Text('Password'),
                                          subtitle: TextField(
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                suffixIcon: Icon(
                                                  CupertinoIcons.eye_slash,
                                                  size: 15,
                                                ),
                                              ),
                                              onChanged: (String value) {
                                                authController.password.value =
                                                    value;
                                              }),
                                        ),
                                        ListTile(
                                          dense: true,
                                          title: const Text(''),
                                          subtitle: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            onTap: () {
                                              authController.signIn();
                                            },
                                            highlightColor:
                                                Colors.white.withValues(alpha: 0.3),
                                            splashColor:
                                                Colors.white.withValues(alpha: 0.3),
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: kThemeColor,
                                              ),
                                              child: const SizedBox(
                                                height: 36,
                                                child: Center(
                                                  child: Text(
                                                    'Login',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      mobile: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Text(
              "I apologize for the inconvenience, but unfortunately, our current platform does not support mobile browsers. We recommend using a desktop or laptop with a compatible browser for the best user experience. We're working on improving our platform to make it more accessible in the future. Thank you for your understanding."
                  .tr),
        ),
      ),
      key: UniqueKey(),
    );
  }
}
