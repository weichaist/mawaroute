// Delete an avatar knowledge file and its avatar_rec rows.
const admin = require("firebase-admin");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");

exports.DeleteKnowledgeFile = onCall({ timeoutSeconds: 180 }, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    const { avatarUid, fileUid } = data;
    logger.info("Delete Knowledge File!", { structuredData: true });
    const avatarDocRef = admin.firestore().collection("m_avatars").doc(avatarUid);
    const query = avatarDocRef
      .collection("knowledge_files")
      .where("creatorUid", "==", auth.uid)
      .where("weaviateFileUid", "==", fileUid);
    const knowledgeFilesSnapshot = await query.get();
    if (knowledgeFilesSnapshot.empty) throw new Error("Invalid parameter");
    knowledgeFilesSnapshot.forEach((doc) => doc.ref.delete());

    const avatarRecSnapshot = await admin.firestore().collection("avatar_rec").where("fileUid", "==", fileUid).get();
    avatarRecSnapshot.forEach((doc) => doc.ref.delete());
    return "Success";
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Delete Knowledge File.");
  }
});
