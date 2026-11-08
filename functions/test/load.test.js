// Loads index.js the way the Firebase CLI does at deploy time (no secrets,
// no credentials) and checks the exported triggers and their secrets.
const { test } = require("node:test");
const assert = require("node:assert/strict");

process.env.GCLOUD_PROJECT = "demo-mawaroute";
process.env.FIREBASE_CONFIG = JSON.stringify({
  projectId: "demo-mawaroute",
  databaseURL: "https://demo-mawaroute-default-rtdb.firebaseio.com",
  storageBucket: "demo-mawaroute.appspot.com",
});

const functions = require("../index");
const { declaredParams } = require("firebase-functions/params");

const callables = [
  "MintERC20Token", "TransferERC20TokenFromUidV2", "TransferMatic", "TransferERC20TokenFromUid",
  "Mint",
  "GetWalletTokenBalances", "GetWalletNFTs", "GetWalletTokenTransfers", "GetTopGGMTHolders",
  "UploadToIPFS", "UploadIPFSMetaData",
  "SearchPlace", "sendPhotoFromGooglePlaceAPI",
  "GeoHash", "GeoHashLimit",
  "AnnotateImage", "AnnotateImageV2",
  "OpenAIApiDescriptionToTags", "OpenAIFindDescriptionFromName", "GetReviewsToDescription",
  "UsersPreferencesFromTags", "UsersPreferencesFromExistingTags", "FindCompatibilityBetweenUserAndShop",
  "OpenAIAddUserTagsFromDislike", "OpenAIAddUserTagsFromDislikeV2", "OpenAIAddUserTagsFromLike",
  "GeneratePersonalizedReason", "OpenAIDynamicGpt4ForChat", "ChatWithAvatar", "StreamChatForWeb",
  "FetchWeaviateRecItems", "FetchRecReason", "StreamRecReason",
  "SendShopEmail", "SendPlaceEmail", "DeleteNews",
  "TranslateToEnglish", "TranslateToJapanese",
  "CreateVisitFromCompletedCampaign", "CreateVisitFromCompletedUserCampaign",
  "WeaviateAvatarRecBatchAdd", "WeaviateAvatarRecBatchDeleteWithFileUid",
  "getLinkPreview", "getLinkListPreview",
  "DeleteKnowledgeFile",
];

const firestoreTriggers = {
  SendNotification: "mawaroute_news/{mawarouteNewsUid}",
  WeaviateAvatarRecUpdate: "avatar_rec/{avatarRecUid}",
  BrandAdd: "brands/{brandId}",
  BrandUpdate: "brands/{brandId}",
  BrandDelete: "brands/{brandId}",
  UpdateChatCounter: "user_chats/{userChatId}/chats/{chatId}",
  UpdateKnowledgePointCounter: "avatar_qa/{avatarQaId}",
  UpdateKnowledgePointCounterForDeletion: "avatar_qa/{avatarQaId}",
};

const secretsOf = (name) =>
  (functions[name].__endpoint.secretEnvironmentVariables || []).map((s) => s.key).sort();

test("exports exactly the documented functions", () => {
  const expected = [...callables, ...Object.keys(firestoreTriggers)].sort();
  assert.deepEqual(Object.keys(functions).sort(), expected);
});

test("callables are 2nd gen callable triggers", () => {
  for (const name of callables) {
    const endpoint = functions[name].__endpoint;
    assert.equal(endpoint.platform, "gcfv2", name);
    assert.ok(endpoint.callableTrigger, `${name} is not callable`);
  }
});

test("Firestore triggers watch the expected documents", () => {
  for (const [name, document] of Object.entries(firestoreTriggers)) {
    const endpoint = functions[name].__endpoint;
    assert.ok(endpoint.eventTrigger, `${name} is not an event trigger`);
    assert.equal(endpoint.eventTrigger.eventFilterPathPatterns.document, document, name);
  }
});

test("functions bind the secrets they read", () => {
  assert.deepEqual(secretsOf("TransferMatic"), ["MINTER_PRIVATE_KEY", "RPC_URL"]);
  assert.deepEqual(secretsOf("Mint"), ["MINTER_PRIVATE_KEY", "RPC_URL"]);
  assert.deepEqual(secretsOf("GetTopGGMTHolders"), ["MINTER_PRIVATE_KEY", "MORALIS_API_KEY"]);
  assert.deepEqual(secretsOf("UploadToIPFS"), ["MORALIS_API_KEY"]);
  assert.deepEqual(secretsOf("GetReviewsToDescription"), ["GOOGLE_MAPS_API_KEY", "OPENAI_API_KEY"]);
  assert.deepEqual(secretsOf("StreamChatForWeb"), ["COHERE_API_KEY", "OPENAI_API_KEY", "WEAVIATE_API_KEY"]);
  assert.deepEqual(secretsOf("SendShopEmail"), ["SENDGRID_API_KEY"]);
  assert.deepEqual(secretsOf("TranslateToJapanese"), ["GOOGLE_TRANSLATE_API_KEY"]);
  assert.deepEqual(secretsOf("BrandAdd"), ["COHERE_API_KEY", "WEAVIATE_API_KEY"]);
  assert.deepEqual(secretsOf("GeoHash"), []);
});

test("declares the documented params", () => {
  const names = declaredParams.map((p) => p.name).sort();
  assert.deepEqual(names, [
    "CHAIN_ID", "COHERE_API_KEY", "ERC20_TOKEN_ADDRESS", "ERC20_TOKEN_SYMBOL",
    "GOOGLE_MAPS_API_KEY", "GOOGLE_TRANSLATE_API_KEY", "MINTER_PRIVATE_KEY", "MORALIS_API_KEY",
    "NEWS_PUSH_TEST_TOKENS", "NEWS_PUSH_TO_ALL_USERS", "NFT_CONTRACT_ADDRESS",
    "OPENAI_API_KEY", "OPENAI_FAST_MODEL", "OPENAI_MODEL", "RPC_URL",
    "SENDGRID_API_KEY", "SENDGRID_FROM_EMAIL", "SENDGRID_SHOP_TEMPLATE_ID",
    "WEAVIATE_API_KEY", "WEAVIATE_HOST",
  ]);
});

test("the optional Algolia module loads", () => {
  const algolia = require("../src/algolia");
  for (const name of ["ShopAdd", "ShopUpdate", "ShopDelete"]) {
    assert.ok(algolia[name].__endpoint.eventTrigger, name);
  }
});

test("GeoHash and GeoHashLimit run locally", async () => {
  const auth = { uid: "user-1", token: {} };
  const { hash } = await functions.GeoHash.run({ data: { lat: 35.681236, lng: 139.767125 }, auth });
  assert.match(hash, /^xn76/);
  const { bounds } = await functions.GeoHashLimit.run({
    data: { lat: 35.681236, lng: 139.767125, radius: 1000 },
    auth,
  });
  assert.ok(bounds.length > 0);
  await assert.rejects(functions.GeoHash.run({ data: { lat: 0, lng: 0 } }));
});

test("chain helpers read CHAIN_ID", () => {
  process.env.CHAIN_ID = "80002";
  const { chainHex, fromWei, toWei } = require("../src/lib/chain");
  assert.equal(chainHex(), "0x13882");
  assert.equal(toWei(3), 3000000000000000000n);
  assert.equal(fromWei("1500000000000000000"), "1.5");
});
