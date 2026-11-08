import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'bindings/ads_screen_binding.dart';
import 'bindings/auth_binding.dart';
import 'bindings/campaign_v2_screen_binding.dart';
import 'bindings/create_ad_screen_binding.dart';
import 'bindings/create_campaign_v2_screen_binding.dart';
import 'bindings/edit_ad_screen_binding.dart';
import 'bindings/edit_campaign_v2_screen_binding.dart';
import 'bindings/edit_my_place_screen_binding.dart';
import 'bindings/elements_screen_binding.dart';
import 'bindings/home_screen_binding.dart';
import 'bindings/news_screen_binding.dart';
import 'bindings/rewards_screen_binding.dart';
import 'bindings/shops_screen_binding.dart';
import 'bindings/top_token_holder_screen_binding.dart';
import 'firebase_options.dart';
import 'middlewares/auth_middleware.dart';
import 'screens/ads_screen/ads_screen.dart';
import 'screens/ads_screen/create_ad_screen.dart';
import 'screens/ads_screen/edit_ad_screen.dart';
import 'screens/auth_screen/login_screen.dart';
import 'screens/campaigns_screen/campaigns_v2_screen.dart';
import 'screens/campaigns_screen/create_campaign_v2_screen.dart';
import 'screens/campaigns_screen/edit_campaign_v2_screen.dart';
import 'screens/edit_my_place_screen/edit_my_place_screen.dart';
import 'screens/elements_screen/elements_screen.dart';
import 'screens/home_screen/home_screen.dart';
import 'screens/news_screen/news_action_screen.dart';
import 'screens/news_screen/news_screen.dart';
import 'screens/rewards_screen/create_reward_screen.dart';
import 'screens/rewards_screen/edit_reward_screen.dart';
import 'screens/rewards_screen/rewards_screen.dart';
import 'screens/shops_screen/shops_screen.dart';
import 'screens/top_token_holder_screen/top_token_holder_screen.dart';
import 'screens/unknown_screen/unknown_screen.dart';
import 'theme/main_theme.dart';
import 'translations/translations.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MaWaRoute Retail',
      theme: mainTheme(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('ja', 'JP'),
      navigatorObservers: [observer, FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      translations: TranslationMessages(),
      unknownRoute: GetPage(
        name: '/404',
        page: () => const UnknownScreen(),
      ),
      initialRoute: '/auth',
      initialBinding: HomeBinding(),
      getPages: [
        GetPage(
          name: '/auth',
          binding: AuthBinding(),
          page: () => const LoginScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/home',
          binding: HomeBinding(),
          page: () => const HomeScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/elements',
          binding: ElementsScreenBinding(),
          page: () => const ElementsScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/campaigns',
          binding: CampaignV2ScreenBinding(),
          page: () => const CampaignV2Screen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/campaign/create',
          binding: CreateCampaignV2ScreenBinding(),
          page: () => const CreateCampaignV2Screen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/campaign/:campaignId',
          binding: EditCampaignV2ScreenBinding(),
          page: () => const EditCampaignV2Screen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/ads',
          binding: AdsScreenBinding(),
          page: () => const AdsScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/ads/create',
          binding: CreateAdScreenBinding(),
          page: () => const CreateAdScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/ads/:adId',
          binding: EditAdScreenBinding(),
          page: () => const EditAdScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/my-place',
          binding: EditMyPlaceScreenBinding(),
          page: () => const EditMyPlaceScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/shops',
          binding: ShopsScreenBinding(),
          page: () => const ShopsScreen(),
          middlewares: [AuthMiddleware()],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: '/rewards',
          binding: RewardsScreenBinding(),
          page: () => const RewardsScreen(),
          transition: Transition.noTransition,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/rewards/create',
          binding: RewardsScreenBinding(),
          page: () => const CreateRewardScreen(),
          transition: Transition.noTransition,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/rewards/:rewardId',
          binding: RewardsScreenBinding(),
          page: () => const EditRewardScreen(),
          transition: Transition.noTransition,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/top-token-holder',
          binding: TopTokenHolderScreenBinding(),
          page: () => const TopTokenHolderScreen(),
          transition: Transition.noTransition,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/news',
          binding: NewsScreenBinding(),
          page: () => const NewsScreen(),
          transition: Transition.noTransition,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/news/create',
          binding: NewsScreenBinding(),
          page: () => const NewsActionScreen(),
          transition: Transition.noTransition,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/news/:newsId',
          binding: NewsScreenBinding(),
          page: () => const NewsActionScreen(),
          transition: Transition.noTransition,
          middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}
