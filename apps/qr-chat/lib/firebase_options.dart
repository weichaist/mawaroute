// Firebase options read from build-time defines.
//
// Pass your project's values with
//   flutter run -d chrome --dart-define-from-file=config/dev.json
// (see config/example.json), or replace this file by running
// `flutterfire configure` for your own Firebase project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'config/app_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'This app is web only; DefaultFirebaseOptions has no native config.',
    );
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: AppConfig.firebaseApiKey,
    appId: AppConfig.firebaseAppId,
    messagingSenderId: AppConfig.firebaseMessagingSenderId,
    projectId: AppConfig.firebaseProjectId,
    authDomain: AppConfig.firebaseAuthDomain.isEmpty
        ? null
        : AppConfig.firebaseAuthDomain,
    storageBucket: AppConfig.firebaseStorageBucket.isEmpty
        ? null
        : AppConfig.firebaseStorageBucket,
    measurementId: AppConfig.firebaseMeasurementId.isEmpty
        ? null
        : AppConfig.firebaseMeasurementId,
  );
}
