// Google Cloud Vision: text, labels and objects in a task photo.
// Uses the functions' default service account (enable the Vision API).
const { ImageAnnotatorClient } = require("@google-cloud/vision");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");

let visionClient;
const vision = () => {
  if (!visionClient) visionClient = new ImageAnnotatorClient();
  return visionClient;
};

const annotate = async (uri, features) => {
  const [result] = await vision().batchAnnotateImages({
    "requests": [
      {
        "image": {
          "source": {
            "imageUri": uri,
          },
        },
        "features": features,
      },
    ],
  });
  return result.responses[0];
};

// Older variant kept for clients that still call it.
exports.AnnotateImage = onCall({ timeoutSeconds: 180 }, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Text Recognition!", { structuredData: true });
    const { uri } = data;
    const response = await annotate(uri, [
      { "type": "TEXT_DETECTION", "maxResults": 1 },
      { "type": "LABEL_DETECTION", "maxResults": 10 },
    ]);
    return {
      "fullTextAnnotation": response["fullTextAnnotation"] != null ? response["fullTextAnnotation"]["text"] : null,
      "labelAnnotations": response["labelAnnotations"],
    };
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Complete Text Recognition.");
  }
});

exports.AnnotateImageV2 = onCall({ timeoutSeconds: 180 }, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Text Recognition V2!", { structuredData: true });
    const { uri } = data;
    const response = await annotate(uri, [
      { "type": "TEXT_DETECTION", "maxResults": 1 },
      { "type": "LABEL_DETECTION", "maxResults": 10 },
      { "type": "OBJECT_LOCALIZATION", "maxResults": 10 },
    ]);
    return {
      "fullTextAnnotation": response["fullTextAnnotation"] != null ? response["fullTextAnnotation"]["text"] : null,
      "labelAnnotations": response["labelAnnotations"],
      "localizedObjectAnnotations": response["localizedObjectAnnotations"],
    };
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Complete Text Recognition v2.");
  }
});
