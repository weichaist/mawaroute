# MaWaRoute shop app

The phone app for **shop staff** at a MaWaRoute place. It runs on Android
and iOS, and its UI is in Japanese and English (GetX translations), falling
back to Japanese. It's portrait only.

Package: `mawaroute_shop`. Bundle ids, kept from the original:

- Android: `app.mawaroute.mawaroute_shop_app`
- iOS: `app.mawaroute.mawarouteShopApp`

## What it does

- **Sign in** with the place id and the email and password the place sent.
  The business console's "invite shop" calls the `SendShopEmail` function,
  which creates the account and emails them. The first sign-in creates an
  empty `shops` document managed by that user.
- **Home**: today's and this month's visits and purchases, and credits. The
  "nearby users" figure is a fixed placeholder (250).
- **QR scan**: scan a visitor's coupon QR code
  (`campaignUid_taskUid_shopUid_userUid`). If the signed-in user manages that
  shop and the code hasn't been used, the app records the purchase in
  `shops/{shopUid}/shop_purchases` and calls `TransferERC20TokenFromUidV2`
  to send the visitor 3 reward tokens.
- **Coupon history**: coupons redeemed for the shop's rewards.
- **Time table**: set business hours per weekday.
- **Library / spot photo**: upload shop images. Photos must carry GPS EXIF
  data. You can also pick the spot image for "まわる to earn" campaigns.
- **Account**: pick the shop from a Google Places search (`SearchPlace`),
  which stores its location and geohash (`GeoHash`) and builds a description
  and tags from Google reviews and OpenAI (`GetReviewsToDescription`,
  `OpenAIFindDescriptionFromName`, `OpenAIApiDescriptionToTags`). Also edit
  the marketing URL and the token reward for purchases, and sign out.

The code also holds a **visitor list** (`/visitors/:timeframe`), a **chat
about a visitor** (`/chat-about-visitor`, which asks OpenAI about a
visitor's tags and translates through `TranslateToEnglish` /
`TranslateToJapanese`) and an **admin** screen (`/admin`, which creates
shops). Their entry buttons are commented out in the dashboard in the
original, so the app doesn't open them.

Data lives in Firestore (`shops`, `places`, `shop_visits`, `shop_purchases`,
`rewards`, `reward_receivers`) and images in Firebase Storage. The backend
contract is in [`../../functions/README.md`](../../functions/README.md).

## Configuration

Copy [`config/example.json`](config/example.json) to `config/dev.json`
(gitignored) and fill it in. The Firebase values come from Firebase console
→ Project settings → Your apps, using the Android and iOS apps registered
with the bundle ids above.

| Key | Value |
| --- | --- |
| `FIREBASE_PROJECT_ID` | Project id |
| `FIREBASE_MESSAGING_SENDER_ID` | Sender id (project number) |
| `FIREBASE_STORAGE_BUCKET` | Storage bucket |
| `FIREBASE_ANDROID_API_KEY`, `FIREBASE_ANDROID_APP_ID` | From the Android app (`google-services.json`: `current_key`, `mobilesdk_app_id`) |
| `FIREBASE_IOS_API_KEY`, `FIREBASE_IOS_APP_ID` | From the iOS app (`GoogleService-Info.plist`: `API_KEY`, `GOOGLE_APP_ID`) |
| `FIREBASE_IOS_CLIENT_ID` | iOS OAuth client id (`CLIENT_ID`). Optional |
| `OPENAI_API_KEY` | Only for the visitor chat screen, which calls the OpenAI API **from the device** |
| `OPENAI_MODEL` | Model for that screen (default `gpt-4.1-mini`; the original's `gpt-3.5-turbo-0613` is retired) |

Instead of the defines, you can run `flutterfire configure` to regenerate
`lib/firebase_options.dart` (and the native `google-services.json` /
`GoogleService-Info.plist`, which are gitignored).

An `OPENAI_API_KEY` passed this way is compiled into the app and can be
pulled out of it. If you turn the chat screen back on, use a restricted,
low-limit key, or move the call behind a Cloud Function (the backend has a
similar `OpenAIDynamicGpt4ForChat`).

## Run

Flutter 3.47.9 (`.fvmrc`), Dart 3.13:

```bash
flutter pub get
flutter run --dart-define-from-file=config/dev.json
flutter analyze && flutter test
```

Building needs the Android SDK and/or Xcode. Before release, set your own
signing: the release build type uses debug keys, and the iOS project has no
team set.

## Notes

- The platform folders were regenerated with Flutter 3.47.9. The app name
  (Mawaroute店舗), launcher icons, permissions (photos, camera) and their
  Japanese iOS usage strings, and portrait-only orientation were carried
  over. `dart run flutter_launcher_icons` regenerates the icons from
  `assets/icons/shop_icon.png`.
- The discontinued `qr_code_scanner` was replaced by its maintained fork
  `qr_code_scanner_plus`, which has the same API.
- The original iOS `NSAllowsArbitraryLoads` exception and the unused
  push-notification entitlement were dropped.
