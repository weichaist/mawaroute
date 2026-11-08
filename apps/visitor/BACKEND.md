# Visitor app: backend contract

Everything the visitor app (`apps/visitor`) reads from or writes to, taken from
the code in `lib/`. "R" = read, "W" = create/update/delete.

## Firebase services used

| Service | Package | Notes |
|---|---|---|
| Authentication | `firebase_auth` | Phone number sign-in only (`verifyPhoneNumber` + SMS code). |
| Cloud Firestore | `cloud_firestore` | Default database. |
| Cloud Storage | `firebase_storage` | Default bucket (`FIREBASE_STORAGE_BUCKET`). |
| Cloud Functions | `cloud_functions` | Callable functions, default region (`us-central1`). |
| Cloud Messaging | `firebase_messaging` | Push notifications; token stored in Firestore. |
| App Check | `firebase_app_check` | App Attest (iOS), Play Integrity (Android). |

## Cloud Functions (callable, `httpsCallable`)

| Name | Called from | Request | Response used |
|---|---|---|---|
| `TransferMatic` | `controllers/auth_controller.dart` (first sign-in) | `{ transferAddress: string }` (new wallet address) | none. Expected to send a little MATIC for gas. |
| `TransferERC20TokenFromUidV2` | `utilis/token_transfers/transfer_functions.dart` (invitation + special reward codes) | `{ transferredAmount: int, uid: string }` | none. Expected to send that many GGMT tokens to the user's wallet. |
| `AnnotateImageV2` | `utilis/image_matching.dart` (photo task) | `{ uri: "gs://<bucket>/<path>" }` | Google Cloud Vision style result: `fullTextAnnotation`, `labelAnnotations[]`, `localizedObjectAnnotations[]`. |

No HTTP (`onRequest`) functions are called. (Older builds also called
`GeoHashLimit` from an unused home controller; that code was removed.)

## Firestore

| Path | Access | What for |
|---|---|---|
| `m_users/{uid}` | R, W (`set` merge, `update`) | Profile: `display_name`, `image`, `publicAddress` (wallet), `sign_in_at`, `invitation_code`. Created on first sign-in. Queried by `display_name` (uniqueness check), by `invitation_code`, and by document id `whereIn` (invited friends). |
| `m_users/{uid}/credentials/{id}` | R, W (`add`, `update`) | **Wallet private key** (`key`), `email`, `fcmToken`. See the security note in the README. |
| `m_avatars/{avatarId}` | R | AI guide avatars: `name`, `imageUrl`, `description`, `expertise`, prompts (`chatStarterPrompt`, `recPrompt`, `visionPrompt`), counters. Queried by `invited == true`, `filters array-contains 'shopping' / 'sightseeing'`, ordered by `knowledgePointCounter`; and by id `whereIn`. |
| `user_rec_chats/{uid}` | R, W (`set`) | `recent_chats`: list of avatar ids the user chatted with. |
| `user_rec_chats/{uid}/chats/{chatId}` | R, W (`add`, `update deleted=true`) | One chat session: `avatarUid`, `avatarUrl`, `query`, `deleted`, `createdAt`. Queried by `deleted == false`. |
| `user_rec_chats/{uid}/chats/{chatId}/chat_elements/{id}` | R, W (`add`) | Messages and recommendation cards (`type`, `message`, `messageOfAvatar`, `recLink`, `recUid`, `imageUrl`, `timestamp`, ...), ordered by `timestamp`. |
| `mawaroute_news/{id}` | R | Notification list, ordered by `timestamp` desc. |
| `rewards/{rewardId}` | R, W (transaction on `upperLimit`) | Rewards (coupon / email / on-spot). Queried by `rewardDistributionType`, `status == 'active'`, ordered by `startTime`. |
| `rewards/{rewardId}/reward_receivers/{id}` | R, W (`add`, `update applied`) | Who redeemed a reward (`rewardUid`, `receiver`, `timestamp`, `email`, `tokenTransferred`, `applied`, `appliedTimestamp`). |
| `top_rewards/{id}` | R | Cash-back campaigns (`type == 'cashback'`, ordered by `title`; `condition`). |
| `top_rewards/{id}/cashback_receivers/{id}` | R, W (`add`) | Cash-back claims (`receiver`, `timestamp`, `email`, `tokenTransferred`, `cashBackAmount`, `status`). Queried by `receiver` and `timestamp` range. |
| `shop_purchases` (collection group) | R (count) | Daily purchase count per user (`userUid`, `timestamp` range) to cap cash-back claims. |
| `shops/{shopId}` | R | Reference photo for a photo task, looked up by `googlePlaceId` (`downloadUrl`). |
| `image_to_be_deleted/{id}` | W (`add`) | `{ url }` of a task photo that failed matching, for cleanup by the backend. |
| `invitation_received/{id}` | R, W (`add`) | Invitation code redemptions (`invitation_sender_uid`, `invitation_receiver_uid`, `invitation_code`, `timestamp`). |
| `special_reward_code/{id}` | R | Promo codes (`code`, `isLive`, `tokenNumber`). |
| `special_reward_code/{id}/special_reward_receivers/{id}` | R, W (`add`) | Promo code redemptions (`receiverUid`, `invitation_code`, `timestamp`). |
| `env/mawaroute_wallet` | R | `address` (MaWaRoute treasury wallet that receives redeemed GGMT), `rpcUrl` (Polygon RPC), `chainId`. |
| `env/ios_version`, `env/android_version` | R | `version`, `appStoreUrl` for the update prompt. |
| `account_deletion_requests/{id}` | R, W (`add`) | `{ userUid, timestamp }`. |

Indexes the queries above need (composite) are not checked in; Firestore
prints a link to create each one the first time a query runs.

## Cloud Storage

| Path | Access | What for |
|---|---|---|
| `v1-media/profile/img-<timestamp>.<ext>` | W, then download URL | Profile pictures (also the generated DiceBear avatar on first sign-in). |
| `v1-media/vision_rec/{uid}/img-<timestamp>.jpg` | W, then download URL | Photos sent to the avatar chat (passed to OpenAI as an image URL). |
| `v1-media/uploaded_product_pictures/{uid}/img-<timestamp>.jpg` | W | Photo-task pictures, sent to `AnnotateImageV2` as `gs://` URLs. |
| any `v1-media/...` path | R (via `gs://` URL) | The reference image of a shop (from `shops.downloadUrl`) is passed to `AnnotateImageV2`. |

## Services outside Firebase

| Service | From | Notes |
|---|---|---|
| OpenAI API | `controllers/rec_chat_controller.dart`, `controllers/voice_assistant_controller.dart` | Chat completions (streamed), Whisper transcription, TTS. Called directly from the app with `OPENAI_API_KEY`. |
| Weaviate (GraphQL) | `utilis/graphql.dart`, `screens/chat_rec_screen/rec_graphql.dart` | Class `AvatarRec` (`avatarUid`, `title`, `description`, `price`, `link`, `geo`), `nearText` search with a Cohere vectorizer. Called directly with `WEAVIATE_API_KEY` + `COHERE_API_KEY`. |
| Polygon JSON-RPC | `controllers/wallet_controller.dart` | `balanceOf` / `transfer` on the GGMT ERC-20 contract (`ERC20_CONTRACT_ADDRESS`), MATIC balance. RPC URL from `env/mawaroute_wallet`. |
| DiceBear | `controllers/auth_controller.dart` | `https://api.dicebear.com/7.x/thumbs/png?seed=...` for the first avatar. |
| Mapbox / OpenStreetMap tiles | `screens/home_nav_wrapper/v3_home_screen.dart` | Background map on the home screen. |
