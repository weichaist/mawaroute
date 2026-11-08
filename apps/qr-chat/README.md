# MaWaRoute QR chat (web)

A Flutter web page for chatting with a shop's AI avatar. A QR code at the shop
links to `https://<your-host>/avatar_chat/<avatarId>`; the page loads that
avatar from Firestore (`m_avatars`), greets the visitor, answers questions
with streamed chat completions, and shows recommendation cards (with link
previews) found for the avatar. No sign-in. The UI is Japanese by default with
a language switcher (the chosen language is passed to the model).

Package name `mawaroute_qr_chat`. Web only.

The backend it expects (Cloud Functions, Firestore paths, chat endpoints) is
listed in [BACKEND.md](BACKEND.md).

## Requirements

- Flutter 3.47.9 (Dart 3.13). `.fvmrc` pins it for [FVM](https://fvm.app).
- A Firebase project with a web app, Firestore, the `FetchWeaviateRecItems`
  and `getLinkListPreview` functions, and (optionally) App Check with
  reCAPTCHA v3.
- Two chat endpoints that speak the OpenAI chat-completions format (see
  below).

## Configuration

```sh
cp config/example.json config/dev.json   # config/*.json is gitignored
# fill in config/dev.json
flutter run -d chrome --dart-define-from-file=config/dev.json
```

| Key | Needed for | Where to get it |
|---|---|---|
| `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_STORAGE_BUCKET` | Firebase | Firebase console, Project settings, your web app |
| `FIREBASE_MEASUREMENT_ID` | Analytics (optional) | Same place |
| `RECAPTCHA_SITE_KEY` | App Check (optional; App Check is skipped when empty) | reCAPTCHA v3 admin console, then register it in Firebase App Check |
| `CHAT_STREAM_URL` | Streamed avatar replies | Your own proxy: accepts `{messages}`, adds the model and OpenAI key, returns an SSE stream |
| `CHAT_URL` | Summarising the visitor's intent (used for "why you might like it") | Same proxy, non-streaming response |
| `DEFAULT_AVATAR_ID` | Avatar shown at `/` (optional; `/` shows "not found" when empty) | An `m_avatars` document id |
| `IOS_APP_STORE_URL`, `ANDROID_PLAY_STORE_URL` | "Download the app" buttons (hidden when empty) | Your store listings |

`lib/firebase_options.dart` reads the Firebase values above. You can instead
run `flutterfire configure` for your project, which overwrites that file.

Everything in the config ends up in the public JavaScript bundle, so put no
secrets there. The OpenAI key belongs in the chat proxy.

## Run, test, build

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --dart-define-from-file=config/dev.json
```

## Deploy

The repository's root `firebase.json` has a `qr-chat` hosting target that
serves `apps/qr-chat/build/web`, rewriting every path to `index.html` (the
avatar id is part of the path). Set your project and the `qr-chat` site id in
the root `.firebaserc`, build, then deploy from the repository root:

```sh
flutter build web --release --dart-define-from-file=config/<name>.json
cd ../.. && firebase deploy --only hosting:qr-chat
```

## How streaming works

Browsers cannot stream a `POST` response through `package:http`, so
`web/custom_scripts.js` defines `fetchStream()`, which uses `fetch` and a
`ReadableStream` reader and hands each chunk back to Dart.
`lib/utils/dartjs_fetch.dart` calls it through `dart:js_interop` and parses the
`data:` lines.
