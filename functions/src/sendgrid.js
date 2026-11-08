// Account invitations: create a Firebase Auth user and email the sign-in
// details with a SendGrid dynamic template.
const crypto = require("node:crypto");
const admin = require("firebase-admin");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");
const { sendgrid } = require("./lib/clients");
const {
  SENDGRID_API_KEY,
  SENDGRID_FROM_EMAIL,
  SENDGRID_SHOP_TEMPLATE_ID,
} = require("./lib/params");

const sendgridOptions = { timeoutSeconds: 180, secrets: [SENDGRID_API_KEY] };

const generatePassword = () => {
  const letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
  const letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const number = "0123456789";
  const special = "@#%^*>$@?/[]=+";
  const chars = letterLowerCase + letterUpperCase + number + special;
  const length = 8;

  return Array.from({ length }, () => chars.charAt(crypto.randomInt(chars.length))).join("");
};

const sendInvitation = (email, placeId, password) =>
  sendgrid().send({
    to: email,
    from: SENDGRID_FROM_EMAIL.value(),
    templateId: SENDGRID_SHOP_TEMPLATE_ID.value(),
    dynamicTemplateData: {
      email: email,
      placeId: placeId,
      password: password,
    },
  });

// Creates a shop staff account under a place and emails its password.
exports.SendShopEmail = onCall(sendgridOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Sending shop email!", { structuredData: true });
    const { email, placeId } = data;
    const password = generatePassword();
    const user = await admin.auth().createUser({ email: email, password: password });
    await admin.firestore().collection("places").doc(placeId).collection("place_shops").add({
      email: email,
      password: password,
      status: "sent",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    await sendInvitation(email, placeId, password);
    return user.uid;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not send shop email.");
  }
});

// Creates a place (business console) account, an empty places/{uid}
// document, and emails the sign-in details.
exports.SendPlaceEmail = onCall(sendgridOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Sending place email!", { structuredData: true });
    const { email } = data;
    const password = generatePassword();
    const user = await admin.auth().createUser({ email: email, password: password });
    const placeId = user.uid;
    await admin.firestore().collection("places").doc(placeId).set({
      "name": "",
      "address": "",
      "_geoloc": {
        "lat": 0.0,
        "lng": 0.0,
      },
      "geoHash": "",
      "imageLink": "",
      "downloadUrl": "",
      "profileUrl": "",
      "isPublic": false,
    });
    await sendInvitation(email, placeId, password);
    return "Successfully send the mail.";
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not send shop email.");
  }
});
