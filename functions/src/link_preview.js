// Open Graph link previews (title, description, image) for chat links.
const axios = require("axios");
const cheerio = require("cheerio");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3";

const fetchPreview = async (url) => {
  const response = await axios.get(url, { headers: { "User-Agent": USER_AGENT } });
  const $ = cheerio.load(response.data);
  return {
    title: $("meta[property=\"og:title\"]").attr("content") || $("title").text(),
    description: $("meta[property=\"og:description\"]").attr("content") || $("meta[name=\"description\"]").attr("content"),
    image: $("meta[property=\"og:image\"]").attr("content") || $("#landingImage").attr("src"),
  };
};

exports.getLinkPreview = onCall(async ({ data }) => {
  try {
    return await fetchPreview(data.url);
  } catch (error) {
    throw new HttpsError("internal", "Failed to fetch link preview");
  }
});

exports.getLinkListPreview = onCall(async ({ data }) => {
  const result = [];
  for (const url of data.urls) {
    let preview = { title: "", description: "", image: "" };
    try {
      preview = await fetchPreview(url);
    } catch (e) {
      logger.info(e, { structuredData: true });
    }
    result.push({ url, ...preview });
  }
  return result;
});
