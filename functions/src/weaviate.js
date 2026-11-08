// Keep Weaviate in sync with Firestore: AvatarRec (avatar recommendation
// items, from avatar_rec) and Brand (from brands). Failed syncs are logged
// to weaviate_sync_failed.
const admin = require("firebase-admin");
const { generateUuid5 } = require("weaviate-ts-client");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const {
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { checkLogin } = require("./lib/auth");
const { weaviateDb } = require("./lib/clients");
const { COHERE_API_KEY, WEAVIATE_API_KEY } = require("./lib/params");

const weaviateSecrets = [WEAVIATE_API_KEY, COHERE_API_KEY];

async function weaviateSyncFailed(docId, actionName, collectionName) {
  await admin.firestore().collection("weaviate_sync_failed").add({
    "docId": docId,
    "actionName": actionName,
    "collectionName": collectionName,
  });
}

function constructAvatarRecObj(data) {
  const obj = {
    "title": data["title"],
    "description": data["description"],
    "avatarUid": data["avatarUid"],
    "fileUid": data["fileUid"],
  };
  if (data["price"] !== null) obj["price"] = data["price"];
  if (data["geo"] !== null) obj["geo"] = data["geo"];
  if (data["link"] !== null) obj["link"] = data["link"];
  if (data["jp_price"] !== null) obj["jp_price"] = data["jp_price"];
  return obj;
}

exports.WeaviateAvatarRecUpdate = onDocumentUpdated(
  { document: "avatar_rec/{avatarRecUid}", secrets: weaviateSecrets },
  async (event) => {
    const data = event.data.after.data();
    const avatarRecUid = event.data.after.id;
    const id = generateUuid5(avatarRecUid);
    logger.info(avatarRecUid, { structuredData: true });
    try {
      await weaviateDb().data
        .updater()
        .withId(id)
        .withClassName("AvatarRec")
        .withProperties(constructAvatarRecObj(data))
        .do();
    } catch (e) {
      logger.info(e, { structuredData: true });
      await weaviateSyncFailed(avatarRecUid, "update", "AvatarRec");
    }
    return null;
  },
);

exports.BrandAdd = onDocumentCreated(
  { document: "brands/{brandId}", secrets: weaviateSecrets },
  async (event) => {
    const data = event.data.data();
    const brandUid = event.data.id;
    const id = generateUuid5(brandUid);
    try {
      await weaviateDb().data
        .creator()
        .withClassName("Brand")
        .withProperties({
          "name": data["name"],
          "genre": data["genre"],
        })
        .withId(id)
        .do();
    } catch (e) {
      logger.info(e, { structuredData: true });
      await weaviateSyncFailed(brandUid, "add", "Brand");
    }
    return null;
  },
);

exports.BrandUpdate = onDocumentUpdated(
  { document: "brands/{brandId}", secrets: weaviateSecrets },
  async (event) => {
    const data = event.data.after.data();
    const brandUid = event.data.after.id;
    const id = generateUuid5(brandUid);
    logger.info(brandUid, { structuredData: true });
    try {
      await weaviateDb().data
        .updater()
        .withId(id)
        .withClassName("Brand")
        .withProperties({
          "name": data["name"],
          "genre": data["genre"],
        })
        .do();
    } catch (e) {
      logger.info(e, { structuredData: true });
      await weaviateSyncFailed(brandUid, "update", "Brand");
    }
    return null;
  },
);

exports.BrandDelete = onDocumentDeleted(
  { document: "brands/{brandId}", secrets: weaviateSecrets },
  async (event) => {
    const id = generateUuid5(event.data.id);
    try {
      await weaviateDb().data
        .deleter()
        .withId(id)
        .withClassName("Brand")
        .do();
    } catch (e) {
      logger.info(e, { structuredData: true });
    }
    return null;
  },
);

exports.WeaviateAvatarRecBatchAdd = onCall(
  { timeoutSeconds: 180, secrets: weaviateSecrets },
  async ({ data, auth }) => {
    try {
      checkLogin(auth);
      logger.info("Start batch writing for weaviate", { structuredData: true });
      const { objects } = data;
      let batcher = weaviateDb().batch.objectsBatcher();
      for (const object of objects) {
        batcher = batcher.withObject({
          class: "AvatarRec",
          properties: constructAvatarRecObj(object),
          id: generateUuid5(object["id"]),
        });
      }
      await batcher.do();
      return "200";
    } catch (e) {
      logger.info(e, { structuredData: true });
      throw new HttpsError("unknown", "Could Not Complete Batch Writing");
    }
  },
);

exports.WeaviateAvatarRecBatchDeleteWithFileUid = onCall(
  { timeoutSeconds: 180, secrets: weaviateSecrets },
  async ({ data, auth }) => {
    try {
      checkLogin(auth);
      logger.info("Start batch delete for weaviate", { structuredData: true });
      const { fileUid } = data;
      await weaviateDb().batch
        .objectsBatchDeleter()
        .withClassName("AvatarRec")
        .withWhere({
          path: ["fileUid"],
          operator: "Equal",
          valueText: fileUid,
        })
        .do();
      return "200";
    } catch (e) {
      logger.info(e, { structuredData: true });
      throw new HttpsError("unknown", "Could Not Complete Batch Delete");
    }
  },
);
