import 'package:blur/blur.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

import 'api/google_firestore_services.dart';
import 'models/m_user_credentials.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FirestoreService f = FirestoreService();

  Future<void> setup() async {
    await _firebaseMessaging.requestPermission();
    // The backend sends to FCM registration tokens stored in
    // m_users/{uid}/credentials, so keep using getToken() rather than the
    // newer register()/onRegistered (which yields an installation id).
    // ignore: deprecated_member_use
    final String? fcmToken = await _firebaseMessaging.getToken();
    MUserCredential credential = await f.getUserCredentials();
    if (credential.id != "") {
      if (fcmToken != credential.fcmToken) {
        await f.updateUserCredentials(
          uid: credential.id!,
          obj: {"fcmToken": fcmToken},
        );
      }
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Get.toNamed('/notification');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        SmartDialog.show(
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child:
                    ListTile(
                      onTap: () {
                        Get.toNamed('/notification');
                      },
                      leading: const Icon(
                        CupertinoIcons.bell_circle,
                        color: Colors.white,
                      ),
                      title: Text(
                        message.notification!.title!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        message.notification!.body!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ).frosted(
                      frostColor: kPrimaryColor,
                      frostOpacity: 0.9,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
              ),
            );
          },
          displayTime: const Duration(milliseconds: 3000),
          alignment: Alignment.topCenter,
          maskColor: Colors.transparent,
        );
      }
    });
  }
}
