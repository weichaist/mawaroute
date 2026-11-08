// Geohash helpers (geofire-common) for location queries.
const geofire = require("geofire-common");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");

exports.GeoHash = onCall({ timeoutSeconds: 180 }, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Calculating hash!", { structuredData: true });
    const { lat, lng } = data;
    const hash = geofire.geohashForLocation([lat, lng]);
    return { hash };
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not generate geo hash.");
  }
});

exports.GeoHashLimit = onCall({ timeoutSeconds: 180 }, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Calculating hash!", { structuredData: true });
    const { lat, lng, radius } = data;
    const center = [lat, lng];
    const bounds = geofire.geohashQueryBounds(center, radius);
    return { bounds };
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not generate geo hash limit.");
  }
});
