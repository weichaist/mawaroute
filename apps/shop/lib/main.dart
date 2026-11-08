import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/bindings/chat_about_visitor_binding.dart';
import 'package:mawaroute_shop/bindings/coupon_usage_binding.dart';
import 'package:mawaroute_shop/bindings/timetable_binding.dart';
import 'package:mawaroute_shop/bindings/visitor_list_binding.dart';
import 'package:mawaroute_shop/screens/admin_screen/admin_screen.dart';
import 'package:mawaroute_shop/screens/chat_about_visitor_screen/chat_about_visitor_screen.dart';
import 'package:mawaroute_shop/screens/coupon_usage_history/coupon_usage_screen.dart';
import 'package:mawaroute_shop/screens/timetable_screen/timetable_screen.dart';
import 'package:mawaroute_shop/screens/visitor_list_screen/visitor_list_screen.dart';
import 'package:mawaroute_shop/translations/translations.dart';

import 'bindings/admin_binding.dart';
import 'bindings/auth_binding.dart';
import 'bindings/home_binding.dart';
import 'firebase_options.dart';
import 'middlewares/auth_middleware.dart';
import 'screens/auth_screens/emai_auth_screen.dart';
import 'screens/home_screen/home_screen.dart';
import 'theme/constants.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.spinningCircle
    ..userInteractions = false
    ..dismissOnTap = false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
    configLoading();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MaWaRoute Shop App',
      theme: ThemeData(colorSchemeSeed: kPrimaryColor, useMaterial3: true),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('ja', 'JP'),
      translations: TranslationMessages(),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: EasyLoading.init(
        builder: FlutterSmartDialog.init(),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          binding: HomeBinding(),
          middlewares: [AuthMiddleware()],
          page: () => const HomeScreen(),
        ),
        GetPage(
          name: '/auth',
          binding: AuthBinding(),
          page: () => const EmailAuthScreen(),
        ),
        GetPage(
          name: '/visitors/:timeframe',
          binding: VisitorListBinding(),
          page: () => const VisitorListScreen(),
        ),
        GetPage(
          name: '/shop-time-table',
          binding: TimeTableBinding(),
          page: () => const TimeTableScreen(),
        ),
        GetPage(
          name: '/chat-about-visitor',
          binding: ChatAboutVisitorBinding(),
          page: () => const ChatAboutVisitorScreen(),
        ),
        GetPage(
          name: '/admin',
          binding: AdminBinding(),
          page: () => const AdminScreen(),
        ),
        GetPage(
          name: '/coupon-usage',
          binding: CouponUsageBinding(),
          page: () => const CouponUsageScreen(),
        ),
      ],
    );
  }
}
