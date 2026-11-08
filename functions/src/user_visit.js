// Record a visit in shops/{shopUid}/shop_visits when a visitor completes a
// campaign task, so the shop app can list visitors with their tags.
const admin = require("firebase-admin");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");

const getRequired = async (ref, label) => {
  const doc = await ref.get();
  if (!doc.exists) {
    throw new Error(`${label} document does not exist.`);
  }
  return doc.data();
};

const addVisit = async ({ visitorUid, campaignUid, taskUid, capturedImageUploadedUrl, placeUid, shopUid }) => {
  const firestore = admin.firestore();
  const mUser = await getRequired(firestore.doc(`m_users/${visitorUid}`), "User");
  const visitorProfile = mUser.image;

  const visitorTags = [];
  const tagsSnapshot = await firestore
    .collection(`m_user_preference/${visitorUid}/tags`)
    .orderBy("hits")
    .limit(30)
    .get();
  tagsSnapshot.forEach((doc) => {
    visitorTags.push(doc.data().tag);
  });

  await firestore.collection(`shops/${shopUid}/shop_visits`).add({
    visitorUid,
    campaignUid,
    taskUid,
    placeUid,
    shopUid,
    visitTime: admin.firestore.FieldValue.serverTimestamp(),
    visitorName: mUser.display_name,
    visitorProfile,
    visitorTags,
    capturedImageUploadedUrl,
  });
};

// Campaign copied to the user: m_users/{uid}/user_campaigns/{campaignUid}.
exports.CreateVisitFromCompletedUserCampaign = onCall({ timeoutSeconds: 180 }, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Create Visit From CompletedUserCampaign!", { structuredData: true });
    const { campaignUid, taskUid, capturedImageUploadedUrl } = data;
    const visitorUid = auth.uid;
    const firestore = admin.firestore();
    const campaignModel = await getRequired(
      firestore.doc(`m_users/${visitorUid}/user_campaigns/${campaignUid}`), "Campaign");
    const userCampaignTaskModel = await getRequired(
      firestore.doc(`m_users/${visitorUid}/user_campaigns/${campaignUid}/user_campaign_tasks/${taskUid}`), "Task");
    await addVisit({
      visitorUid,
      campaignUid,
      taskUid,
      capturedImageUploadedUrl,
      placeUid: campaignModel.placeUid,
      shopUid: userCampaignTaskModel.shopId,
    });
    return "OK.";
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Complete Create Visit From CompletedUserCampaign.");
  }
});

// Shared campaign: campaigns/{campaignUid}/campaign_tasks/{taskUid}.
exports.CreateVisitFromCompletedCampaign = onCall({ timeoutSeconds: 180 }, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Create Visit From CompletedCampaign!", { structuredData: true });
    const { campaignUid, taskUid, capturedImageUploadedUrl } = data;
    const visitorUid = auth.uid;
    const firestore = admin.firestore();
    const campaignModel = await getRequired(firestore.doc(`campaigns/${campaignUid}`), "Campaign");
    const campaignTaskModel = await getRequired(
      firestore.doc(`campaigns/${campaignUid}/campaign_tasks/${taskUid}`), "Task");
    // Some tasks have shopUid "".
    const shopUid = campaignTaskModel.shopUid;
    if (!shopUid || shopUid === "") {
      throw new Error("Shop does not exist.");
    }
    await addVisit({
      visitorUid,
      campaignUid,
      taskUid,
      capturedImageUploadedUrl,
      placeUid: campaignModel.placeUid,
      shopUid,
    });
    return "OK.";
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Complete Create Visit From CompletedCampaign.");
  }
});
