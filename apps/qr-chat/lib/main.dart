import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import 'bindings/init_binding.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
import 'screens/chat_screen/web_chat_screen.dart';
import 'screens/unknown_screen/unknown_screen.dart';
import 'theme/constants.dart';
import 'translations/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (AppConfig.recaptchaSiteKey.isNotEmpty) {
    await FirebaseAppCheck.instance.activate(
      providerWeb: ReCaptchaV3Provider(AppConfig.recaptchaSiteKey),
    );
  }
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'マワルトレコメンドAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF08162E)),
        inputDecorationTheme: inputDecorationTheme(),
        useMaterial3: true,
      ),
      locale: const Locale('ja', 'JP'),
      fallbackLocale: const Locale('en', 'US'),
      navigatorObservers: [observer, FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      translations: TranslationMessages(),
      unknownRoute: GetPage(name: '/404', page: () => const UnknownScreen()),
      initialRoute: AppConfig.defaultAvatarId.isEmpty
          ? '/404'
          : '/avatar_chat/${AppConfig.defaultAvatarId}',
      initialBinding: InitBinding(),
      getPages: [
        GetPage(
          name: '/avatar_chat/:uid',
          page: () => const WebChatScreen(),
          transition: Transition.noTransition,
        ),
      ],
    );
  }
}
