// Counters on m_avatars: chats started and knowledge points (avatar_qa).
const admin = require("firebase-admin");
const { logger } = require("firebase-functions/v2");
const { onDocumentCreated, onDocumentDeleted } = require("firebase-functions/v2/firestore");

const incrementAvatar = async (avatarUid, field, by) => {
  try {
    await admin.firestore().collection("m_avatars").doc(avatarUid).update({
      [field]: admin.firestore.FieldValue.increment(by),
    });
  } catch (e) {
    logger.info(e, { structuredData: true });
  }
  return null;
};

exports.UpdateChatCounter = onDocumentCreated("user_chats/{userChatId}/chats/{chatId}", (event) =>
  incrementAvatar(event.data.data()["characterUid"], "chatCount", 1));

exports.UpdateKnowledgePointCounter = onDocumentCreated("avatar_qa/{avatarQaId}", (event) =>
  incrementAvatar(event.data.data()["avatarUid"], "knowledgePointCounter", 1));

exports.UpdateKnowledgePointCounterForDeletion = onDocumentDeleted("avatar_qa/{avatarQaId}", (event) =>
  incrementAvatar(event.data.data()["avatarUid"], "knowledgePointCounter", -1));
