// Lazily created API clients. Param and secret values are only available
// while a function runs, never at deploy time, so nothing here runs at load.
const { default: weaviate } = require("weaviate-ts-client");
const OpenAI = require("openai");
const Moralis = require("moralis").default;
const sgMail = require("@sendgrid/mail");
const { Translate } = require("@google-cloud/translate").v2;
const {
  COHERE_API_KEY,
  GOOGLE_TRANSLATE_API_KEY,
  MORALIS_API_KEY,
  OPENAI_API_KEY,
  SENDGRID_API_KEY,
  WEAVIATE_API_KEY,
  WEAVIATE_HOST,
} = require("./params");

let openaiClient;
const openai = () => {
  if (!openaiClient) {
    openaiClient = new OpenAI({ apiKey: OPENAI_API_KEY.value() });
  }
  return openaiClient;
};

let weaviateClient;
const weaviateDb = () => {
  if (!weaviateClient) {
    weaviateClient = weaviate.client({
      scheme: "https",
      host: WEAVIATE_HOST.value(),
      apiKey: new weaviate.ApiKey(WEAVIATE_API_KEY.value()),
      headers: {
        "X-Cohere-Api-Key": COHERE_API_KEY.value(),
      },
    });
  }
  return weaviateClient;
};

let moralisStart;
const moralis = async () => {
  if (!moralisStart) {
    moralisStart = Moralis.start({ apiKey: MORALIS_API_KEY.value() });
  }
  await moralisStart;
  return Moralis;
};

let sendgridReady = false;
const sendgrid = () => {
  if (!sendgridReady) {
    sgMail.setApiKey(SENDGRID_API_KEY.value());
    sendgridReady = true;
  }
  return sgMail;
};

let translateClient;
const translator = () => {
  if (!translateClient) {
    translateClient = new Translate({ key: GOOGLE_TRANSLATE_API_KEY.value() });
  }
  return translateClient;
};

module.exports = { moralis, openai, sendgrid, translator, weaviateDb };
