import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'bindings/auth_binding.dart';
import 'bindings/cashback_binding.dart';
import 'bindings/chat_rec_binding.dart';
import 'bindings/chat_rec_history_binding.dart';
import 'bindings/home_binding.dart';
import 'bindings/notification_screen_binding.dart';
import 'bindings/permission_binding.dart';
import 'bindings/profile_binding.dart';
import 'bindings/reward_details_binding.dart';
import 'bindings/send_invitation_binding.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
import 'middlewares/auth_middleware.dart';
import 'screens/auth_screen/demo_login_screen.dart';
import 'screens/auth_screen/verify_phone_screen.dart';
import 'screens/cashback_screen/cashback_screen.dart';
import 'screens/chat_history_screen/chat_history_screen.dart';
import 'screens/chat_rec_screen/chat_rec_screen.dart';
import 'screens/home_nav_wrapper/home_nav_wrapper.dart';
import 'screens/my_wallet_screen/send_invitation_screen.dart';
import 'screens/notification_screen/notification_screen.dart';
import 'screens/permission_screen/permission_screen.dart';
import 'screens/profile_screen/profile_display_name_edit_screen.dart';
import 'screens/profile_screen/profile_picture_edit_screen.dart';
import 'screens/reward_details_screen/reward_details_screen.dart';
import 'theme/dark_theme.dart';
import 'theme/main_theme.dart';
import 'translations/translations.dart';
import 'utilis/time_ago_ja.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseAppCheck.instance.activate(
    providerApple: const AppleAppAttestProvider(),
    providerAndroid: const AndroidPlayIntegrityProvider(),
  );
  OpenAI.apiKey = AppConfig.openAiApiKey;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // ThemeMode mode = ThemeMode.system;
    timeago.setLocaleMessages('ja', JaShortMessages());
    return GetMaterialApp(
      title: 'Mawaroute AI',
      debugShowCheckedModeBanner: false,
      theme: mainTheme(),
      darkTheme: darkTheme(),
      translations: TranslationMessages(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      themeMode: ThemeMode.light,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          binding: HomeBinding(),
          middlewares: [AuthMiddleware()],
          page: () => const Material3NavBar(),
        ),
        GetPage(
          name: '/auth',
          binding: AuthBinding(),
          page: () => const DemoLoginScreen(),
        ),
        GetPage(
          name: '/notification',
          binding: NotificationScreenBinding(),
          page: () => const NotificationScreen(),
        ),
        GetPage(
          name: '/profile/display-name',
          binding: ProfileBinding(),
          page: () => const ProfileDisplayNameEditScreen(),
        ),
        GetPage(
          name: '/profile/picture',
          binding: ProfileBinding(),
          page: () => const ProfilePictureEditScreen(),
        ),
        GetPage(
          name: '/verify-phone-number',
          binding: AuthBinding(),
          page: () => const VerifyPhoneNumberScreen(),
        ),
        GetPage(
          name: '/permission/:type',
          binding: PermissionBinding(),
          page: () => const PermissionScreen(),
        ),
        GetPage(
          name: '/rewards/:rewardId',
          binding: RewardDetailsBinding(),
          page: () => const RewardDetailsScreen(),
        ),
        GetPage(
          name: '/send-invitation',
          binding: SendInvitationBinding(),
          page: () => const SendInvitationScreen(),
        ),
        GetPage(
          name: '/cashback/:rewardUid',
          binding: CashBackBinding(),
          page: () => const CashBackScreen(),
        ),
        GetPage(
          name: '/chat_rec_screen/:avatarUid',
          binding: ChatRecBinding(),
          page: () => const ChatRecScreen(),
        ),
        GetPage(
          name: '/chat_rec_history',
          binding: ChatRecHistoryBinding(),
          page: () => const ChatRecHistoryScreen(),
        ),
      ],
    );
  }
}
