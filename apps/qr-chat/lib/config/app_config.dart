/// Build-time configuration, read with `String.fromEnvironment` from
/// `--dart-define-from-file=config/<name>.json` (see `config/example.json`).
/// Everything here ends up in the public JavaScript bundle.
class AppConfig {
  AppConfig._();

  // Firebase web app (also see lib/firebase_options.dart)
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
  );
  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const firebaseMeasurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
  );

  /// reCAPTCHA v3 site key registered for Firebase App Check (web).
  static const recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

  /// OpenAI-compatible chat completions endpoint that streams
  /// (server-sent events). The app sends `{messages: [...]}` without any key,
  /// so this must be your own proxy that adds the model and API key.
  static const chatStreamUrl = String.fromEnvironment('CHAT_STREAM_URL');

  /// Same as [chatStreamUrl] but returns one JSON response (used to summarise
  /// the visitor's intent).
  static const chatUrl = String.fromEnvironment('CHAT_URL');

  /// Avatar opened at `/` (the QR codes link to `/avatar_chat/<avatarId>`).
  /// Leave empty to show the "not found" page at `/`.
  static const defaultAvatarId = String.fromEnvironment('DEFAULT_AVATAR_ID');

  /// Store links for the visitor app, shown at the top of the chat. Leave
  /// empty to hide a button.
  static const iosAppStoreUrl = String.fromEnvironment('IOS_APP_STORE_URL');
  static const androidPlayStoreUrl = String.fromEnvironment(
    'ANDROID_PLAY_STORE_URL',
  );
}
