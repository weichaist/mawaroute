import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

Future<void> launchMaWaRouteHP() async {
  if (AppConfig.homepageUrl.isEmpty) return;
  final Uri url = Uri.parse(AppConfig.homepageUrl);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> launchGoogleMap(
  double startLat,
  double startLng,
  double lat,
  double lng,
) async {
  final Uri url = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&origin=${startLat.toString()},${startLng.toString()}&destination=${lat.toString()},${lng.toString()}&travelmode=walking',
  );
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> launchPolygon() async {
  if (AppConfig.testnetFaucetUrl.isEmpty) return;
  final Uri url = Uri.parse(AppConfig.testnetFaucetUrl);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> launchAboutMatic() async {
  if (AppConfig.getMaticGuideUrl.isEmpty) return;
  final Uri url = Uri.parse(AppConfig.getMaticGuideUrl);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> launchAppStoreUpdate(String uri) async {
  final Uri url = Uri.parse(uri);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> launchNewsUrl(String uri) async {
  final Uri url = Uri.parse(uri);
  try {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  } catch (err) {
    return;
  }
}

Future<void> launchTopMessageRedirectUrl(String uri) async {
  final Uri url = Uri.parse(uri);
  try {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  } catch (err) {
    return;
  }
}

Future<void> launchPlaceUrl(String uri) async {
  final Uri url = Uri.parse(uri);
  try {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  } catch (err) {
    SmartDialog.showNotify(
      msg: 'URL is not valid'.tr,
      notifyType: NotifyType.alert,
    );
    return;
  }
}

Future<void> launchGoogleMapSingleSpot(double lat, double lng) async {
  final Uri url = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}',
  );
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
