// Google Places text search and photo download.
const axios = require("axios");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");
const { GOOGLE_MAPS_API_KEY } = require("./lib/params");

const placesOptions = { timeoutSeconds: 180, secrets: [GOOGLE_MAPS_API_KEY] };

exports.SearchPlace = onCall(placesOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Search Place!", { structuredData: true });
    const apiKey = GOOGLE_MAPS_API_KEY.value();
    const { text } = data;

    const requestURL = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=" + text +
      "&key=" + apiKey + "&region=jp&language=ja";
    const apiResponse = await axios.get(requestURL);
    const results = apiResponse.data.results;
    return results;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Search.");
  }
});

exports.sendPhotoFromGooglePlaceAPI = onCall(placesOptions, async ({ data, auth }) => {
  checkLogin(auth);
  logger.info("Fetch photo from photo reference", { structuredData: true });
  const { photoReference } = data;
  const apiKey = GOOGLE_MAPS_API_KEY.value();
  try {
    const apiUrl = `https://maps.googleapis.com/maps/api/place/photo?maxwidth=900&photo_reference=${photoReference}&key=${apiKey}`;
    const apiResponse = await axios.get(apiUrl, { responseType: "arraybuffer" });
    const base64Image = Buffer.from(apiResponse.data, "binary").toString("base64");
    return { image: base64Image };
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not save photos.");
  }
});
