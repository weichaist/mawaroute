# MaWaRoute business console

A Flutter web console for a **place**, such as a shopping mall or station
building, that runs MaWaRoute "visit to earn" campaigns with its shops. The
UI is in Japanese and English (GetX translations) and falls back to Japanese.

Package: `mawaroute_business`. Platform: web only.

## What it does

The navigation rail opens these screens:

- **Home** (`/home`): a getting-started page with placeholder campaign
  examples and next steps, and a button to make the place public.
- **Shops** (`/shops`): the place's shops and their status. Invite a shop by
  email, which calls the `SendShopEmail` function to create the shop staff
  account and email its password. Each shop shows visit and purchase counts
  (today, this month, total) and has a shop QR code you can generate and
  download as a PNG.
- **Campaigns** (`/campaigns`, `/campaign/create`, `/campaign/:id`): create
  and edit campaigns with basic info, images, target users (all customers or
  AI targeting) and a list of photo tasks. A task has a hint, a location
  (geohash through the `GeoHash` function) and a reference image. Visitors
  prove a visit by photographing the same scene in the visitor app.
- **Rewards** (`/rewards`, `/rewards/create`, `/rewards/:id`): rewards
  handed out by email, on the spot or as coupons, with their receivers. You
  can export the receivers as CSV.
- **My place** (`/my-place`): edit the place profile. Search Google Places
  (`SearchPlace`), set the location and geohash, and upload the image.
- **Top token holders** (`/top-token-holder`): the top 30 holders of the
  reward token (`GetTopGGMTHolders`), matched to user profiles by wallet address.
- **News** (`/news`, `/news/create`, `/news/:id`): create, edit and delete
  (`DeleteNews`) news items. Creating one triggers the `SendNotification`
  function, which pushes it to the FCM tokens configured for it.

There are two unfinished parts. **Elements** (`/elements`) is an empty page,
and the **Ads** screens (`/ads…`) are layout only: their controllers are
empty and save nothing.

Sign-in is Firebase Auth email/password with per-tab session persistence.
Place accounts are created by the `SendPlaceEmail` function, and the console
has no sign-up. Data lives in Cloud Firestore
(`places`, `shops`, `campaigns`, `rewards`, `mawaroute_news`, …) and images
in Firebase Storage under `v1-media/`. The backend contract is in
[`../../functions/README.md`](../../functions/README.md).

## Configuration

Firebase values are passed at build time and nothing project-specific is
committed. Copy [`config/example.json`](config/example.json) to
`config/dev.json` (gitignored) and fill in the values of your Firebase
**web app**, from Firebase console → Project settings → Your apps:

| Key | Value |
| --- | --- |
| `FIREBASE_API_KEY` | Web API key |
| `FIREBASE_APP_ID` | Web app id (`1:…:web:…`) |
| `FIREBASE_MESSAGING_SENDER_ID` | Sender id (project number) |
| `FIREBASE_PROJECT_ID` | Project id |
| `FIREBASE_AUTH_DOMAIN` | `<project>.firebaseapp.com` |
| `FIREBASE_STORAGE_BUCKET` | Storage bucket |
| `FIREBASE_MEASUREMENT_ID` | Google Analytics id (`G-…`). Optional; omit the key to leave Analytics unset |

Instead of the defines, you can run `flutterfire configure` to regenerate
`lib/firebase_options.dart` with your values. Don't commit that file then.

## Run

Flutter 3.47.9 (`.fvmrc`), Dart 3.13:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/dev.json
flutter build web --dart-define-from-file=config/dev.json   # output: build/web
flutter analyze && flutter test
```

The root `firebase.json` serves `apps/business/build/web` as the `business`
hosting target. Map it to a site with
`firebase target:apply hosting business <site-id>`, then run
`firebase deploy --only hosting:business`.

## Notes

- `file_picker` is pinned to 11.x. Version 12 rewrote the plugin and removed
  the concrete `PlatformFile(name:, size:, bytes:)` that this app uses as its
  image model, so moving on means reworking every upload screen.
- Assets: the M PLUS Rounded 1c font is under the SIL Open Font License
  (`assets/fonts/M_PLUS_Rounded_1c/OFL.txt`). The illustrations, logo and
  coin icon under `assets/images` and `assets/icons` came with the original
  app, and their license isn't recorded.
