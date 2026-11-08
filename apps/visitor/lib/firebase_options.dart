// Firebase options read from build-time defines.
//
// Pass your project's values with
//   flutter run --dart-define-from-file=config/dev.json
// (see config/example.json), or replace this file by running
// `flutterfire configure` for your own Firebase project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'config/app_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: AppConfig.firebaseAndroidApiKey,
    appId: AppConfig.firebaseAndroidAppId,
    messagingSenderId: AppConfig.firebaseMessagingSenderId,
    projectId: AppConfig.firebaseProjectId,
    storageBucket: AppConfig.firebaseStorageBucket,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: AppConfig.firebaseIosApiKey,
    appId: AppConfig.firebaseIosAppId,
    messagingSenderId: AppConfig.firebaseMessagingSenderId,
    projectId: AppConfig.firebaseProjectId,
    storageBucket: AppConfig.firebaseStorageBucket,
    iosClientId: AppConfig.firebaseIosClientId.isEmpty
        ? null
        : AppConfig.firebaseIosClientId,
    iosBundleId: AppConfig.firebaseIosBundleId,
  );
}
