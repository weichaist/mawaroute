// News: push a notification when a news item is created, and delete news.
const admin = require("firebase-admin");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { checkLogin } = require("./lib/auth");
const { NEWS_PUSH_TEST_TOKENS, NEWS_PUSH_TO_ALL_USERS } = require("./lib/params");

exports.SendNotification = onDocumentCreated("mawaroute_news/{mawarouteNewsUid}", async (event) => {
  logger.info("SendNotification!", { structuredData: true });
  // The original sent only to a hard-coded test device and left the
  // all-users loop switched off; both are now configurable.
  const tokens = [...NEWS_PUSH_TEST_TOKENS.value()].filter((t) => t);
  const onCreatedData = event.data.data();
  const size = 500;
  if (NEWS_PUSH_TO_ALL_USERS.value()) {
    const query = await admin.firestore().collectionGroup("credentials").get();
    query.forEach((doc) => {
      const data = doc.data();
      if (data["fcmToken"]) {
        tokens.push(data["fcmToken"]);
      }
    });
  }
  try {
    for (let i = 0; i < tokens.length; i += size) {
      const message = {
        notification: { title: onCreatedData["title"], body: onCreatedData["body"] },
        tokens: tokens.slice(i, i + size),
      };
      await admin.messaging().sendEachForMulticast(message);
    }
  } catch (e) {
    logger.info(e, { structuredData: true });
  }
});

exports.DeleteNews = onCall(async ({ data, auth }) => {
  logger.info("DeleteNews!", { structuredData: true });
  checkLogin(auth);
  const { newsId } = data;
  if (!newsId) {
    throw new HttpsError("invalid-argument", "Missing newId in request data");
  }
  try {
    await admin.firestore().collection("mawaroute_news").doc(newsId).delete();
    return "200";
  } catch (error) {
    logger.error("Error deleting document", { structuredData: true });
    throw new HttpsError("internal", "Failed to delete document");
  }
});
