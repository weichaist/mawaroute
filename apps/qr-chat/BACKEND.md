# QR chat: backend contract

Everything the QR chat web app (`apps/qr-chat`) reads from or calls, taken from
the code in `lib/`. Visitors are not signed in; the app only reads.

## Firebase services used

| Service | Package | Notes |
|---|---|---|
| Cloud Firestore | `cloud_firestore` | One document read per chat. |
| Cloud Functions | `cloud_functions` | Callable functions, default region (`us-central1`). |
| App Check | `firebase_app_check` | reCAPTCHA v3 (`RECAPTCHA_SITE_KEY`); skipped when no key is set. |
| Analytics | `firebase_analytics` | Screen views via `FirebaseAnalyticsObserver` (needs `FIREBASE_MEASUREMENT_ID`). |
| Hosting | `firebase.json` | Serves `build/web` with a SPA rewrite to `/index.html`. |

Not used: Authentication, Storage, and the Realtime Database (the original
`pubspec.yaml` listed `firebase_database` and the Firebase config had a
`databaseURL`, but nothing read or wrote it; the dependency was removed).

## Cloud Functions (callable, `httpsCallable`)

| Name | Called from | Request | Response used |
|---|---|---|---|
| `FetchWeaviateRecItems` | `controllers/web_chat_controller.dart` | `{ avatarUid: string, question: string, existingUids: string[] }` | List of `{ id, title, description, link, price }` recommendation items (Weaviate search on the server). |
| `getLinkListPreview` | `controllers/web_chat_controller.dart` | `{ urls: string[] }` | List of `{ url, title, description, image }` (Open Graph preview per URL; `image` may be relative). |

## Firestore

| Path | Access | What for |
|---|---|---|
| `m_avatars/{avatarId}` | R (`get`) | The avatar named in the URL `/avatar_chat/{avatarId}`: `name`, `imageUrl`, `description`, `expertise`, `creatorName`, `avatarDefinition`, `chatStarterPrompt` (greeting), `recPrompt`, `rfrPrompt` ("why you might like it"). Security rules must allow unauthenticated reads of this collection. |

## HTTP endpoints outside Firebase

| Config key | From | Contract |
|---|---|---|
| `CHAT_STREAM_URL` | `utils/dartjs_fetch.dart` via `web/custom_scripts.js` | `POST` JSON `{ messages: [{ role, content }] }`, response is an OpenAI-style server-sent event stream (`data: {choices:[{delta:{content}}]}` ... `data: [DONE]`). |
| `CHAT_URL` | `controllers/web_chat_controller.dart` (`extractUserIntentWithChatGPT`) | `POST` JSON `{ messages: [...] }`, response is an OpenAI-style chat completion (`choices[0].message.content`). |

The app sends no API key to these endpoints. In the original deployment they
were API-gateway routes that added the model and the OpenAI key server-side.
Any replacement should do the same, and should rate-limit, because the
endpoints are called anonymously from the browser.
