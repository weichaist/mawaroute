// Optional: mirror the `shops` collection into an Algolia index.
// Not exported by default (the original had these triggers switched off);
// to turn them on, uncomment the Algolia lines in index.js and set
// ALGOLIA_APP_ID, ALGOLIA_INDEX_NAME and the ALGOLIA_ADMIN_API_KEY secret.
const { algoliasearch } = require("algoliasearch");
const { defineSecret, defineString } = require("firebase-functions/params");
const { logger } = require("firebase-functions/v2");
const {
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");

const ALGOLIA_APP_ID = defineString("ALGOLIA_APP_ID");
const ALGOLIA_INDEX_NAME = defineString("ALGOLIA_INDEX_NAME", { default: "mawaroute_jp" });
const ALGOLIA_ADMIN_API_KEY = defineSecret("ALGOLIA_ADMIN_API_KEY");

let client;
const algolia = () => {
  if (!client) {
    client = algoliasearch(ALGOLIA_APP_ID.value(), ALGOLIA_ADMIN_API_KEY.value());
  }
  return client;
};

// "09:30" -> 930, so opening hours can be filtered numerically.
function convertTimeToInt(timeString) {
  const [hours, minutes] = timeString.split(":");
  return parseInt(hours, 10) * 100 + parseInt(minutes, 10);
}

const saveShop = (objectID, data) =>
  algolia()
    .saveObject({ indexName: ALGOLIA_INDEX_NAME.value(), body: { ...data, objectID } })
    .catch((err) => logger.info(err, { structuredData: true }));

exports.ShopAdd = onDocumentCreated(
  { document: "shops/{shopId}", secrets: [ALGOLIA_ADMIN_API_KEY] },
  (event) => saveShop(event.data.id, event.data.data()),
);

exports.ShopUpdate = onDocumentUpdated(
  { document: "shops/{shopId}", secrets: [ALGOLIA_ADMIN_API_KEY] },
  (event) => {
    const data = event.data.after.data();
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    weekdays.forEach((weekday) => {
      [`${weekday}_open`, `${weekday}_close`].forEach((timeKey) => {
        if (Object.prototype.hasOwnProperty.call(data, timeKey) && data[timeKey] !== null) {
          data[timeKey] = convertTimeToInt(data[timeKey]);
        }
      });
    });
    return saveShop(event.data.after.id, data);
  },
);

exports.ShopDelete = onDocumentDeleted(
  { document: "shops/{shopId}", secrets: [ALGOLIA_ADMIN_API_KEY] },
  (event) =>
    algolia()
      .deleteObject({ indexName: ALGOLIA_INDEX_NAME.value(), objectID: event.data.id })
      .catch((err) => logger.info(err, { structuredData: true })),
);
