// Firebase options read from compile-time defines, so no project values are
// committed. Pass them with:
//
//   flutter run -d chrome --dart-define-from-file=config/dev.json
//
// (copy config/example.json to config/dev.json and fill it in). Alternatively,
// run `flutterfire configure` to regenerate this file for your own project and
// keep the result out of version control.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'The MaWaRoute business console only targets the web.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    measurementId: bool.hasEnvironment('FIREBASE_MEASUREMENT_ID')
        ? String.fromEnvironment('FIREBASE_MEASUREMENT_ID')
        : null,
  );
}
