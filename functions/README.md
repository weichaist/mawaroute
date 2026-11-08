# MaWaRoute Cloud Functions

The whole MaWaRoute backend: Firebase Cloud Functions (2nd gen, Node.js 22,
`firebase-functions` 7, `firebase-admin` 14). The functions:

- pay rewards on Polygon: they mint and transfer the ERC-20 token, mint NFTs and
  top up new wallets with gas, all from one minter wallet
- read wallet data and upload NFT files to IPFS through Moralis
- write shop descriptions, customer tags, visitor matches and the avatar chat
  replies with OpenAI
- run Google Places search, Cloud Vision and Cloud Translation for the apps
- send SendGrid invitation emails and FCM news pushes, and build link previews
- keep Weaviate (the avatar recommendation search) in sync with Firestore

The contract ABIs the functions call are in [`abi/`](abi). The full compiled
artifacts and what each contract does are in [`../contracts`](../contracts).

## Setup

```bash
cd functions
nvm use            # Node 22 (.nvmrc)
npm install
npm run lint
npm test           # loads index.js without secrets and checks every export
```

Firebase project prerequisites: the Blaze plan, Firestore, the Realtime
Database (`StreamChatForWeb` and `StreamRecReason` write to it), Storage,
Authentication (email/password), and these Google APIs in the project: Cloud
Vision, Cloud Translation, Places, Secret Manager.

### Secrets

Set each one with `firebase functions:secrets:set NAME`. A function gets only
the secrets listed for it below, so you can skip the secrets of features you
don't deploy. The deploy fails if a deployed function needs a secret that isn't set.

| Secret | Used for | Where to get it |
| --- | --- | --- |
| `MINTER_PRIVATE_KEY` | The wallet that owns the contracts. It mints, transfers and pays gas | A wallet you control, funded with the chain's native coin (POL) |
| `RPC_URL` | JSON-RPC endpoint for `CHAIN_ID` | Alchemy, Infura, QuickNode, or a public Polygon RPC |
| `MORALIS_API_KEY` | Wallet balances, NFTs, transfers, token holders, IPFS uploads | [moralis.com](https://moralis.com) |
| `OPENAI_API_KEY` | All OpenAI calls | [platform.openai.com](https://platform.openai.com) |
| `GOOGLE_MAPS_API_KEY` | Places text search, photos, place details and reviews | Google Cloud console, with the Places API enabled |
| `GOOGLE_TRANSLATE_API_KEY` | Cloud Translation v2 | Google Cloud console, with the Cloud Translation API enabled |
| `SENDGRID_API_KEY` | Invitation emails | [sendgrid.com](https://sendgrid.com) |
| `WEAVIATE_API_KEY` | Weaviate cluster | Weaviate Cloud console |
| `COHERE_API_KEY` | Passed to Weaviate in the `X-Cohere-Api-Key` header for its `text2vec-cohere` vectorizer | [cohere.com](https://cohere.com) |
| `ALGOLIA_ADMIN_API_KEY` | Only if you turn on the optional Algolia triggers | Algolia dashboard |

Cloud Vision uses the functions' service account. It needs no key.

### Params (non-secret)

Put these in `functions/.env` or `functions/.env.<project-id>`
([`.env.example`](.env.example)). If one is missing, `firebase deploy` asks for it.

| Param | Default | Meaning |
| --- | --- | --- |
| `CHAIN_ID` | `80002` | EVM chain: `80002` is Polygon Amoy (testnet), `137` is Polygon mainnet. The original ran on Mumbai (80001), which was shut down in 2024 |
| `ERC20_TOKEN_ADDRESS` | (none) | Deployed `ERC20Token` contract |
| `ERC20_TOKEN_SYMBOL` | `GGMT` | The symbol `GetWalletTokenBalances` reports |
| `NFT_CONTRACT_ADDRESS` | (none) | Deployed `NFT` contract |
| `OPENAI_MODEL` | `gpt-4.1` | Replaces the retired `gpt-4` / `gpt-4-1106-preview` |
| `OPENAI_FAST_MODEL` | `gpt-4.1-mini` | Replaces the retired `gpt-3.5-turbo` / `text-davinci-003` |
| `SENDGRID_FROM_EMAIL` | (none) | A verified sender address |
| `SENDGRID_SHOP_TEMPLATE_ID` | (none) | A dynamic template (`d-…`) that receives `email`, `placeId` and `password` |
| `WEAVIATE_HOST` | (none) | Cluster host, without `https://` |
| `NEWS_PUSH_TO_ALL_USERS` | `false` | Push news to every stored FCM token |
| `NEWS_PUSH_TEST_TOKENS` | empty | Comma-separated FCM tokens that always get news pushes |
| `ALGOLIA_APP_ID`, `ALGOLIA_INDEX_NAME` | (none), `mawaroute_jp` | Only for the optional Algolia triggers |

The calls send `temperature` and `max_completion_tokens`. OpenAI reasoning
models (o-series, `gpt-5*`) reject a custom temperature, so pick a model
that accepts one.

### Deploy

```bash
firebase use --add                      # pick your project (root .firebaserc)
firebase functions:secrets:set OPENAI_API_KEY   # …and the other secrets
firebase deploy --only functions,firestore,database,storage
```

Polygon PoS needs a priority fee of at least about 25–30 gwei. If transfers
fail with "transaction underpriced", your RPC's fee estimate is too low.

## Functions

Every function runs in `us-central1` (the default) and is 2nd gen. "Login"
means it throws if the caller isn't signed in with Firebase Auth. Nothing
checks roles: any signed-in user can call any login-only function, including
the token ones (see [Security notes](#security-notes)).

### Blockchain

| Function | Trigger | Auth | Input → output | Secrets / params | Collections |
| --- | --- | --- | --- | --- | --- |
| `MintERC20Token` | callable | login | `{mintAmount}` → `null`. Mints `mintAmount` tokens to the minter wallet | `MINTER_PRIVATE_KEY`, `RPC_URL`; `CHAIN_ID`, `ERC20_TOKEN_ADDRESS` | (none) |
| `TransferERC20TokenFromUidV2` | callable | login | `{transferredAmount, uid}` → `null`. Sends tokens from the minter to `m_users/{uid}.public_address` | same as above | reads `m_users`; writes `transfer_failures` on failure |
| `TransferERC20TokenFromUid` | callable | login | same as V2 (older name, same code) | same | same |
| `TransferMatic` | callable | login | `{transferAddress}` → `null`. Sends 0.001 of the native coin (POL, formerly MATIC) so a new wallet can pay gas | `MINTER_PRIVATE_KEY`, `RPC_URL`; `CHAIN_ID` | writes `transfer_failures` on failure |
| `Mint` | callable | login | `{uri, bizUserId, nftId}` → `null`. Calls `NFT.mint(uri)` and marks the NFT minted | `MINTER_PRIVATE_KEY`, `RPC_URL`; `CHAIN_ID`, `NFT_CONTRACT_ADDRESS` | updates `biz_users/{bizUserId}/nfts/{nftId}` (`status: MINTED`, `minted_by`) |

### Moralis (wallet data and IPFS)

| Function | Trigger | Auth | Input → output | Secrets / params | Collections |
| --- | --- | --- | --- | --- | --- |
| `GetWalletTokenBalances` | callable | login | `{address}` → balance of `ERC20_TOKEN_SYMBOL` as a decimal string | `MORALIS_API_KEY`; `CHAIN_ID`, `ERC20_TOKEN_SYMBOL` | (none) |
| `GetWalletNFTs` | callable | login | `{address}` → image URLs of up to 10 NFTs (fetches each token URI) | `MORALIS_API_KEY`; `CHAIN_ID` | (none) |
| `GetWalletTokenTransfers` | callable | login | `{address}` → last 10 ERC-20 transfers `[{fromAddress, toAddress, value}]` | `MORALIS_API_KEY`; `CHAIN_ID` | (none) |
| `GetTopGGMTHolders` | callable | login | no input → top 30 holders `[{address, value}]` (whole tokens as an integer string), minter excluded | `MORALIS_API_KEY`, `MINTER_PRIVATE_KEY`; `CHAIN_ID`, `ERC20_TOKEN_ADDRESS` | (none) |
| `UploadToIPFS` | callable | login | `{imageData (bytes), fileName}` → new NFT doc id. Step 1 of the NFT flow | `MORALIS_API_KEY` | creates `biz_users/{uid}/nfts/{id}` (`image`, `status`) |
| `UploadIPFSMetaData` | callable | login | `{id, name, price, description, externalLink, supply, blockchain}` → metadata IPFS URI. Step 2 (step 3 is `Mint`) | `MORALIS_API_KEY` | updates `biz_users/{uid}/nfts/{id}` |

`GetWalletNFTs`, `GetWalletTokenTransfers`, `UploadToIPFS`, `UploadIPFSMetaData`
and `Mint` come from the older `mawaroute_token_cloud_functions` backend. No
app in this repo calls them.

### Places, geo, vision, translation

| Function | Trigger | Auth | Input → output | Secrets | Collections |
| --- | --- | --- | --- | --- | --- |
| `SearchPlace` | callable | login | `{text}` → Places text-search results (`region=jp`, `language=ja`) | `GOOGLE_MAPS_API_KEY` | (none) |
| `sendPhotoFromGooglePlaceAPI` | callable | login | `{photoReference}` → `{image}` (base64, 900 px wide) | `GOOGLE_MAPS_API_KEY` | (none) |
| `GeoHash` | callable | login | `{lat, lng}` → `{hash}` | (none) | (none) |
| `GeoHashLimit` | callable | login | `{lat, lng, radius}` (metres) → `{bounds}` for geohash range queries | (none) | (none) |
| `AnnotateImage` | callable | login | `{uri}` → `{fullTextAnnotation, labelAnnotations}` | (service account) | (none) |
| `AnnotateImageV2` | callable | login | `{uri}` → V1 fields plus `localizedObjectAnnotations` (photo-task matching in the visitor app) | (service account) | (none) |
| `TranslateToEnglish` | callable | login | `{text}` (string or list) → list of translations, ja→en | `GOOGLE_TRANSLATE_API_KEY` | (none) |
| `TranslateToJapanese` | callable | login | same, en→ja | `GOOGLE_TRANSLATE_API_KEY` | (none) |

### OpenAI

All of these need `OPENAI_API_KEY` and use `OPENAI_MODEL` / `OPENAI_FAST_MODEL`.

| Function | Trigger | Auth | Input → output | Extra secrets | Collections |
| --- | --- | --- | --- | --- | --- |
| `OpenAIApiDescriptionToTags` | callable | login | `{description}` → `[category, …customer tags]` (category is retail / food & beverage / other; tags in Japanese) | (none) | (none) |
| `OpenAIFindDescriptionFromName` | callable | login | `{shopName}` → short brand description, or `"Local Brand."` | (none) | (none) |
| `GetReviewsToDescription` | callable | login | `{placeId}` → Japanese description written from the place's Google reviews | `GOOGLE_MAPS_API_KEY` | (none) |
| `UsersPreferencesFromTags` | callable | login | `{tags}` → 5 preference tags | (none) | (none) |
| `UsersPreferencesFromExistingTags` | callable | login | `{existingTags, newTags}` → merged list of 20 tags | (none) | (none) |
| `FindCompatibilityBetweenUserAndShop` | callable | login | `{userTags, shopDescription, language}` → match summary text | (none) | (none) |
| `OpenAIAddUserTagsFromDislike` | callable | login | `{userTags}` → `"OK"`; adds generated tags for the caller | (none) | writes `m_user_preference/{uid}` (`counter`) and `m_user_preference/{uid}/tags` |
| `OpenAIAddUserTagsFromDislikeV2` | callable | login | same, with a different prompt and `OPENAI_MODEL` | (none) | same |
| `OpenAIAddUserTagsFromLike` | callable | login | `{campaignUid, taskUid}` → `"OK"`; tags from the shop of a completed task | (none) | reads `m_users/{uid}/user_campaigns/{c}/user_campaign_tasks/{t}`, `shops/{shopId}`; writes `m_user_preference` |
| `GeneratePersonalizedReason` | callable | login | `{description, tags}` → recommendation text | (none) | (none) |
| `OpenAIDynamicGpt4ForChat` | callable | login | `{systemContent, userContent}` → reply text | (none) | (none) |
| `ChatWithAvatar` | callable | **none** | `{avatarUid, chats: [{role, message}], question, languageSetting}` → avatar reply | `WEAVIATE_API_KEY`, `COHERE_API_KEY` | reads `m_avatars/{avatarUid}.chatStarterPrompt`; Weaviate `AvatarRec` |
| `StreamChatForWeb` | callable | **none** | same input → RTDB path `/chats/{key}`; the reply is streamed into `message` in chunks, then `"///"` marks the end | `WEAVIATE_API_KEY`, `COHERE_API_KEY` | reads `m_avatars`; writes RTDB `chats/{key}` |
| `FetchWeaviateRecItems` | callable | **none** | `{avatarUid, question, existingUids}` → up to 3 `[{title, description, link, price, id}]` | `WEAVIATE_API_KEY`, `COHERE_API_KEY` only (no OpenAI) | Weaviate `AvatarRec` |
| `FetchRecReason` | callable | **none** | `{avatarUid, needs, recommendation, languageSetting}` → reason text | (none) | reads `m_avatars/{avatarUid}.recPrompt` |
| `StreamRecReason` | callable | **none** | same input → RTDB path, streamed like `StreamChatForWeb` | (none) | reads `m_avatars`; writes RTDB `chats/{key}` |

The two `Stream*` functions return the path and keep writing after the
response, as the original did. Cloud Functions doesn't guarantee CPU after a
callable returns, so the stream can stall. The QR web chat in this repo uses
`FetchWeaviateRecItems` and `getLinkListPreview`, not these two.

### Email, news, visits

| Function | Trigger | Auth | Input → output | Secrets / params | Collections |
| --- | --- | --- | --- | --- | --- |
| `SendShopEmail` | callable | login | `{email, placeId}` → new Auth uid. Creates a shop staff account with a random password and emails it | `SENDGRID_API_KEY`; `SENDGRID_FROM_EMAIL`, `SENDGRID_SHOP_TEMPLATE_ID` | creates `places/{placeId}/place_shops/{id}` (`email`, `password`, `status`, `timestamp`) |
| `SendPlaceEmail` | callable | login | `{email}` → message. Creates a business-console account and an empty place, emails the password | same | creates `places/{uid}` |
| `SendNotification` | Firestore `onDocumentCreated` `mawaroute_news/{id}` | (none) | pushes `title` / `body` over FCM to `NEWS_PUSH_TEST_TOKENS`, plus every `fcmToken` if `NEWS_PUSH_TO_ALL_USERS` | `NEWS_PUSH_*` | reads collection group `credentials` (`m_users/{uid}/credentials`) |
| `DeleteNews` | callable | login | `{newsId}` → `"200"` | (none) | deletes `mawaroute_news/{newsId}` |
| `CreateVisitFromCompletedCampaign` | callable | login | `{campaignUid, taskUid, capturedImageUploadedUrl}` → `"OK."` | (none) | reads `campaigns/{c}`, `campaigns/{c}/campaign_tasks/{t}` (`shopUid`), `m_users/{uid}`, `m_user_preference/{uid}/tags`; creates `shops/{shopUid}/shop_visits/{id}` |
| `CreateVisitFromCompletedUserCampaign` | callable | login | same input | (none) | reads `m_users/{uid}/user_campaigns/{c}` and its `user_campaign_tasks/{t}` (`shopId`) instead; same writes |

A `shop_visits` document has these fields: `visitorUid, campaignUid, taskUid, placeUid,
shopUid, visitTime, visitorName, visitorProfile, visitorTags (≤30),
capturedImageUploadedUrl`. The shop app's visitor list reads them.

### Weaviate sync and avatar knowledge

| Function | Trigger | Auth | What it does | Secrets | Collections |
| --- | --- | --- | --- | --- | --- |
| `WeaviateAvatarRecUpdate` | Firestore `onDocumentUpdated` `avatar_rec/{id}` | (none) | updates the Weaviate `AvatarRec` object (uuid5 of the doc id) | `WEAVIATE_API_KEY`, `COHERE_API_KEY` | reads `avatar_rec`; writes `weaviate_sync_failed` on failure |
| `BrandAdd` / `BrandUpdate` / `BrandDelete` | Firestore create / update / delete `brands/{id}` | (none) | mirrors `name`, `genre` to Weaviate `Brand` | same | reads `brands`; writes `weaviate_sync_failed` |
| `WeaviateAvatarRecBatchAdd` | callable | login | `{objects: [{id, title, description, avatarUid, fileUid, price?, geo?, link?, jp_price?}]}` → `"200"` | same | (none) |
| `WeaviateAvatarRecBatchDeleteWithFileUid` | callable | login | `{fileUid}` → `"200"`; deletes `AvatarRec` objects of that file | same | (none) |
| `DeleteKnowledgeFile` | callable | login | `{avatarUid, fileUid}` → `"Success"` | (none) | deletes `m_avatars/{avatarUid}/knowledge_files` docs (own, matching `weaviateFileUid`) and `avatar_rec` docs with that `fileUid` |
| `UpdateChatCounter` | Firestore `onDocumentCreated` `user_chats/{u}/chats/{c}` | (none) | `m_avatars/{characterUid}.chatCount += 1` | (none) | `user_chats`, `m_avatars` |
| `UpdateKnowledgePointCounter` | Firestore `onDocumentCreated` `avatar_qa/{id}` | (none) | `m_avatars/{avatarUid}.knowledgePointCounter += 1` | (none) | `avatar_qa`, `m_avatars` |
| `UpdateKnowledgePointCounterForDeletion` | Firestore `onDocumentDeleted` `avatar_qa/{id}` | (none) | `knowledgePointCounter -= 1` | (none) | same |

The Weaviate schema (`AvatarRec`, `Brand` classes with the `text2vec-cohere`
vectorizer) isn't created by this repo. Create it in your cluster first.

### Link previews

| Function | Trigger | Auth | Input → output |
| --- | --- | --- | --- |
| `getLinkPreview` | callable | **none** | `{url}` → `{title, description, image}` from Open Graph tags |
| `getLinkListPreview` | callable | **none** | `{urls}` → `[{url, title, description, image}]` (empty strings on failure) |

### Optional: Algolia

[`src/algolia.js`](src/algolia.js) holds the `ShopAdd`, `ShopUpdate` and
`ShopDelete` triggers. They mirror `shops/{id}` into an Algolia index and
store opening hours as numbers (`"09:30"` becomes `930`). The original had
them switched off, so `index.js` doesn't export them. To use them, uncomment
the lines in `index.js` and set `ALGOLIA_APP_ID`, `ALGOLIA_INDEX_NAME` and
`ALGOLIA_ADMIN_API_KEY`.

## Who calls what

From the app sources:

| App | Functions |
| --- | --- |
| Business console (`apps/business`) | `GeoHash`, `SearchPlace`, `SendShopEmail`, `GetTopGGMTHolders`, `DeleteNews` |
| Shop app (`apps/shop`) | `SearchPlace`, `GeoHash`, `SendShopEmail`, `OpenAIApiDescriptionToTags`, `OpenAIFindDescriptionFromName`, `GetReviewsToDescription`, `FindCompatibilityBetweenUserAndShop`, `TranslateToEnglish`, `TranslateToJapanese`, `TransferERC20TokenFromUidV2` |
| Visitor app (source `mawaroute_v2e_beta@dev_1.3.2`) | `GeoHashLimit`, `AnnotateImageV2`, `TransferMatic`, `TransferERC20TokenFromUidV2` (plus a commented-out `RegisterDeviceIdentity`, which this backend no longer has) |
| QR web chat (source `mawaroute_qr_chat@main`) | `FetchWeaviateRecItems`, `getLinkListPreview` |

No app here calls the other exports: most of the OpenAI tag functions, the
avatar chat functions, the Weaviate batch functions and the NFT flow. They come from
the dev branch of the backend, so other clients may have used them.

## Security notes

These are reported as found. None of them has been redesigned.

- **Any signed-in user can move tokens.** `MintERC20Token` mints any amount,
  `TransferERC20TokenFromUid(V2)` sends any amount to any user's wallet,
  `TransferMatic` sends gas to any address on every call, and `Mint` mints any
  URI. Nothing checks a role, the caller's relation to the recipient, or a
  limit. Anyone who can create an account can drain the minter wallet. In the
  shop app the shop's QR scan triggers the transfer of 3 tokens, but the
  server doesn't check that either.
- **Unauthenticated functions that cost money**: `ChatWithAvatar`,
  `StreamChatForWeb`, `FetchRecReason`, `StreamRecReason` (OpenAI),
  `FetchWeaviateRecItems` (Weaviate/Cohere). They're open by design for the
  QR web chat, but they have no rate limit or App Check.
- **`getLinkPreview` / `getLinkListPreview` fetch any URL without auth**
  (server-side request forgery, and a free proxy for anyone).
- **`SendShopEmail` stores the generated password in plain text** in
  `places/{placeId}/place_shops`, and any signed-in user can call it and
  `SendPlaceEmail` to create Auth accounts.
- **`DeleteNews` lets any signed-in user delete any news item.**
- `SendPlaceEmail` used a fixed, hard-coded password for every new place in
  the original. It now generates a random one, the same way `SendShopEmail` does.
- `StreamChatForWeb` replies land in RTDB `chats/{key}`, and anyone can read them
  (`database.rules.json`). The key is unguessable, but it isn't access control.
- The root `firestore.rules` let anyone read most collections (`places`,
  `shops`, `campaigns`, `rewards`, …) and let any signed-in user create or
  update them, including other people's shops and campaigns. `m_users/{uid}`
  is readable by every signed-in user. `storage.rules` let any signed-in user
  read and overwrite every file.
