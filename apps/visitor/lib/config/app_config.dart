/// Build-time configuration.
///
/// Every value is read with `String.fromEnvironment`, so it comes from
/// `--dart-define-from-file=config/<name>.json` (see `config/example.json`
/// and the README). Nothing here is a secret once the app is built: anything
/// compiled into a mobile app can be extracted from the binary.
class AppConfig {
  AppConfig._();

  // Firebase (also see lib/firebase_options.dart)
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const firebaseAndroidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const firebaseAndroidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const firebaseIosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
  );
  static const firebaseIosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const firebaseIosClientId = String.fromEnvironment(
    'FIREBASE_IOS_CLIENT_ID',
  );
  static const firebaseIosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'dev.acuri.mawarouteV2e',
  );

  /// Image used when a new user's generated avatar cannot be uploaded.
  static const defaultProfileImageUrl = String.fromEnvironment(
    'DEFAULT_PROFILE_IMAGE_URL',
  );

  // OpenAI: avatar chat, image description, voice translation.
  // WARNING: this key is shipped inside the app. See README "Security".
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const openAiChatModel = String.fromEnvironment(
    'OPENAI_CHAT_MODEL',
    defaultValue: 'gpt-4o',
  );

  // Weaviate vector search (recommendations, avatar Q&A) + Cohere vectorizer.
  // WARNING: these keys are shipped inside the app. See README "Security".
  static const weaviateGraphqlUrl = String.fromEnvironment(
    'WEAVIATE_GRAPHQL_URL',
  );
  static const weaviateApiKey = String.fromEnvironment('WEAVIATE_API_KEY');
  static const cohereApiKey = String.fromEnvironment('COHERE_API_KEY');

  // Map tiles on the home screen. With no Mapbox token the map falls back to
  // OpenStreetMap tiles.
  static const mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );
  static const mapboxStyleId = String.fromEnvironment(
    'MAPBOX_STYLE_ID',
    defaultValue: 'mapbox/streets-v12',
  );

  // Polygon ERC-20 reward token (GGMT). The RPC URL, chain id and the
  // MawaRoute wallet address are read from Firestore `env/mawaroute_wallet`.
  static const erc20ContractAddress = String.fromEnvironment(
    'ERC20_CONTRACT_ADDRESS',
    defaultValue: '',
  );

  /// Contact address shown when a user hits the chat limit.
  static const supportEmail = String.fromEnvironment('SUPPORT_EMAIL');

  // Links opened from the app. Leave empty to hide/skip them.
  static const homepageUrl = String.fromEnvironment('HOMEPAGE_URL');
  static const inviteGuideUrl = String.fromEnvironment('INVITE_GUIDE_URL');
  static const getMaticGuideUrl = String.fromEnvironment('GET_MATIC_GUIDE_URL');
  static const questionnaireUrl = String.fromEnvironment('QUESTIONNAIRE_URL');
  static const testnetFaucetUrl = String.fromEnvironment(
    'TESTNET_FAUCET_URL',
    defaultValue: 'https://faucet.polygon.technology/',
  );
}
