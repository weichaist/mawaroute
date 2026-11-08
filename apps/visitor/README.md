# MaWaRoute visitor app

The phone app for MaWaRoute visitors (Flutter, GetX, Firebase). Package name
`mawaroute_visitor`; Android application id `dev.acuri.mawaroute_v2e`, iOS
bundle id `dev.acuri.mawarouteV2e` (kept from the published app). In-app copy
is Japanese and English.

What the code on this branch does:

- **Sign-in** with a phone number (Firebase Auth SMS code). On first sign-in the
  app creates a Polygon wallet on the device, stores the profile in
  `m_users/{uid}`, and asks the backend (`TransferMatic`) to send some MATIC for
  gas.
- **Chat** tab: a map backdrop and a list of AI guide avatars (`m_avatars`),
  filterable by shopping / sightseeing. Chatting with an avatar streams answers
  from OpenAI using the avatar's prompts and the user's location, and shows
  recommendation cards found in Weaviate (`AvatarRec`). Users can send a photo
  for the avatar to describe. Chats are saved and listed in the chat history.
- **Photo task** ("capture image to earn"): the visitor takes a photo at a
  shop; it is uploaded and compared with the shop's reference photo using
  Cloud Vision labels/text returned by the `AnnotateImageV2` function.
- **Translate** tab (experimental, see below): voice translation between
  two languages.
- **Wallet** tab: profile, GGMT (ERC-20) and MATIC balances read from Polygon,
  invitation codes and promo codes that trigger token transfers from the
  backend, recent avatars and chat history, notifications (`mawaroute_news`),
  account deletion request.
- **Rewards and cash-back**: redeeming GGMT for coupons / cash-back
  (`rewards`, `top_rewards`). The screens are in the code
  (`RewardHomeScreen`, `/rewards/:id`, `/cashback/:id`) but on this branch the
  rewards tab is not linked from the bottom navigation.

The backend this app expects (Cloud Functions, Firestore paths, Storage paths)
is listed in [BACKEND.md](BACKEND.md).

## Experimental: voice translation

The Translate tab (`VoiceAssistantScreen` / `VoiceAssistantController`) was
work in progress when development stopped. It records audio, transcribes it
with OpenAI Whisper, and asks a chat model to correct and translate it. It
compiles and is wired into the navigation, but it has not been tested on a
device after the upgrade.

## Requirements

- Flutter 3.47.9 (Dart 3.13). `.fvmrc` pins it for [FVM](https://fvm.app).
- A Firebase project with Auth (phone provider), Firestore, Storage, Functions,
  Cloud Messaging and App Check, and the backend functions from this repo.
- Android Studio / Xcode for device builds. There is no web build.

## Configuration

All configuration is passed at build time:

```sh
cp config/example.json config/dev.json   # config/*.json is gitignored
# fill in config/dev.json
flutter run --dart-define-from-file=config/dev.json
```

| Key | Needed for | Where to get it |
|---|---|---|
| `FIREBASE_PROJECT_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_STORAGE_BUCKET` | Firebase | Firebase console, Project settings |
| `FIREBASE_ANDROID_API_KEY`, `FIREBASE_ANDROID_APP_ID` | Firebase on Android | Project settings, your Android app (`google-services.json` has the same values) |
| `FIREBASE_IOS_API_KEY`, `FIREBASE_IOS_APP_ID`, `FIREBASE_IOS_CLIENT_ID` (optional), `FIREBASE_IOS_BUNDLE_ID` | Firebase on iOS | Project settings, your iOS app (`GoogleService-Info.plist`) |
| `DEFAULT_PROFILE_IMAGE_URL` | Fallback avatar if the generated one can't be uploaded | Any public image URL |
| `OPENAI_API_KEY` | Avatar chat, photo description, voice translation | platform.openai.com |
| `OPENAI_CHAT_MODEL` | Chat model (default `gpt-4o`; must accept images) | OpenAI model list |
| `WEAVIATE_GRAPHQL_URL`, `WEAVIATE_API_KEY` | Recommendation cards | Your Weaviate cluster (needs an `AvatarRec` class) |
| `COHERE_API_KEY` | Weaviate's Cohere vectorizer (`X-Cohere-Api-Key` header) | dashboard.cohere.com |
| `MAPBOX_ACCESS_TOKEN`, `MAPBOX_STYLE_ID` | Home map tiles (optional; OpenStreetMap tiles without a token) | account.mapbox.com |
| `ERC20_CONTRACT_ADDRESS` | GGMT token contract on Polygon. Empty hides token balances. The original token was on the retired Mumbai testnet | Your deployed ERC-20 (see `contracts/README.md`) |
| `SUPPORT_EMAIL` | Contact shown when a user hits the chat limit | Your address |
| `HOMEPAGE_URL`, `INVITE_GUIDE_URL`, `GET_MATIC_GUIDE_URL`, `QUESTIONNAIRE_URL`, `TESTNET_FAUCET_URL` | Links opened from the app; empty ones are hidden or skipped | Your own pages |

The Polygon RPC URL, chain id and the MaWaRoute treasury wallet address are not
build-time values: the app reads them from Firestore `env/mawaroute_wallet`.

`lib/firebase_options.dart` reads the Firebase values above. Instead of the
defines you can run `flutterfire configure` for your own project, which
overwrites that file (and can add `google-services.json` /
`GoogleService-Info.plist`, both gitignored).

### iOS

- Phone sign-in needs the reversed client id as a URL scheme: copy
  `ios/Flutter/Secrets.xcconfig.example` to `ios/Flutter/Secrets.xcconfig`
  (gitignored) and set `FIREBASE_REVERSED_CLIENT_ID` (from
  `GoogleService-Info.plist`).
- Push notifications and App Attest are enabled in
  `ios/Runner/Runner.entitlements`; set your own team in Xcode.
- Permissions (usage strings in `Info.plist`): camera, photo library,
  location, microphone. With CocoaPods the matching `permission_handler`
  macros are set in `ios/Podfile`; with Swift Package Manager they are derived
  from `Info.plist`.

### Android

- Permissions in `AndroidManifest.xml`: camera, photos, location, microphone,
  notifications.
- Release signing: create `android/key.properties` (gitignored) with
  `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. Without it release
  builds use the debug key.

## Run and test

```sh
flutter pub get
flutter analyze
flutter test
flutter run --dart-define-from-file=config/dev.json
```

Icons and the splash screen are generated with `flutter_launcher_icons` and
`flutter_native_splash` (settings in `pubspec.yaml`).

## Security

This app was built as a prototype and has known design problems. Read these
before deploying it:

- **API keys in the app.** `OPENAI_API_KEY`, `WEAVIATE_API_KEY` and
  `COHERE_API_KEY` are compiled into the app and sent from the device. Anyone
  with the app can extract them. Move those calls behind your own backend
  before a public release.
- **Wallet private keys in Firestore.** The wallet is created on the device,
  but its private key is also written to `m_users/{uid}/credentials` (and kept
  in shared preferences). Whoever can read that document controls the wallet.
- **Client-trusted token transfers.** The app calls
  `TransferERC20TokenFromUidV2` with the amount and recipient, and updates
  reward limits from the client. The functions and security rules must check
  these themselves.
