// Japanese <-> English translation (Cloud Translation API v2).
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");
const { translator } = require("./lib/clients");
const { GOOGLE_TRANSLATE_API_KEY } = require("./lib/params");

const translateOptions = { timeoutSeconds: 180, secrets: [GOOGLE_TRANSLATE_API_KEY] };

const translateText = async (text, from, to) => {
  let [translations] = await translator().translate(text, { from, to });
  translations = Array.isArray(translations) ? translations : [translations];
  return translations;
};

exports.TranslateToEnglish = onCall(translateOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Translate To English!", { structuredData: true });
    return await translateText(data.text, "ja", "en");
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Translate To English.");
  }
});

exports.TranslateToJapanese = onCall(translateOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Translate To Japanese!", { structuredData: true });
    return await translateText(data.text, "en", "ja");
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Translate To Japanese.");
  }
});
