// OpenAI helpers: shop tags and descriptions, user preference tags, visitor
// / shop matching, and the avatar chat used by the QR web chat.
// The original models (text-davinci-003, gpt-3.5-turbo, gpt-4,
// gpt-4-1106-preview) are retired; OPENAI_FAST_MODEL replaces the GPT-3.5 /
// davinci calls and OPENAI_MODEL the GPT-4 ones.
const admin = require("firebase-admin");
const { Client } = require("@googlemaps/google-maps-services-js");
const { logger } = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { checkLogin } = require("./lib/auth");
const { openai, weaviateDb } = require("./lib/clients");
const {
  COHERE_API_KEY,
  GOOGLE_MAPS_API_KEY,
  OPENAI_API_KEY,
  OPENAI_FAST_MODEL,
  OPENAI_MODEL,
  WEAVIATE_API_KEY,
} = require("./lib/params");

const openaiOptions = { timeoutSeconds: 180, secrets: [OPENAI_API_KEY] };
const avatarChatSecrets = [OPENAI_API_KEY, WEAVIATE_API_KEY, COHERE_API_KEY];

// Was gpt-3.5-turbo.
const getChatGPTResponse = async (content, temperature = 0.7) => {
  return openai().chat.completions.create({
    model: OPENAI_FAST_MODEL.value(),
    messages: [{ role: "user", content: `${content}` }],
    temperature: temperature,
    max_completion_tokens: 1024,
  });
};

// Was gpt-4.
const getChatGPT4Response = async (userContent, temperature = 0.3, systemContent = "Assume you are a customer data analyst") => {
  return openai().chat.completions.create({
    model: OPENAI_MODEL.value(),
    messages: [
      { role: "system", content: systemContent },
      { role: "user", content: userContent },
    ],
    temperature: temperature,
    max_completion_tokens: 1500,
  });
};

// Was gpt-4-1106-preview. userContents are Maps with "role" and "message".
const getChatGPT4StreamResponse = async (userContents, systemContent, temperature = 0.3, maxTokens = 540, stream = true) => {
  return openai().chat.completions.create({
    model: OPENAI_MODEL.value(),
    messages: [
      { role: "system", content: systemContent },
      ...userContents.map((content) => ({ role: content.get("role"), content: content.get("message") })),
    ],
    temperature: temperature,
    max_completion_tokens: maxTokens,
    stream: stream,
  });
};

const getTags = async (description) => {
  const content = `
  Our shop can decribed as the following description: ${description}. 
  I would like to know the potentian customer profile who are likely to enjoy our products
  and services. Can you help me generate tags to decribe those potential customer.
  Based on these tags we want to profile the customer and understand their intention.
  please return only the tags as comma separated list in japanese without any additional explanation
  `;
  const response = await getChatGPT4Response(content);
  const tags = response.choices[0].message.content.trim().split(",");
  return tags.map((tag) => tag.trim()).filter((tag) => tag !== "");
};

const getRequiredTag = async (description) => {
  const content = `categorize the following business in one the following tags:
      #retail, #food & beverage, #other,
      give me only the plain text tag, ${description}`;
  const response = await getChatGPTResponse(content, 0.3);
  return response.choices[0].message.content.replace("#", "").replace(/ /g, "").split(",");
};

const splitTags = (text) => text.trim().split(",").map((tag) => tag.trim()).filter((tag) => tag !== "");

// Adds tags to m_user_preference/{uid}/tags (new tag: hits 0; existing tag:
// hits + 1) and stores the tag count on m_user_preference/{uid}.counter.
const addUserTags = async (uid, rawTags, cleanTag = (tag) => tag) => {
  const tagsRef = admin.firestore().collection("m_user_preference").doc(uid).collection("tags");
  for (const elem of rawTags) {
    const tag = cleanTag(elem.trim());
    const snapshot = await tagsRef.where("tag", "==", tag).get();
    if (snapshot.size === 0) {
      await tagsRef.add({
        "createdAt": admin.firestore.FieldValue.serverTimestamp(),
        "hits": 0,
        "tag": tag,
      });
    } else {
      for (const doc of snapshot.docs) {
        await tagsRef.doc(doc.id).update({ "hits": doc.data()["hits"] + 1 });
      }
    }
  }
  const countSnapshot = await tagsRef.count().get();
  const counter = countSnapshot.data().count;
  await admin.firestore().collection("m_user_preference").doc(uid).set({ "counter": counter }, { merge: true });
};

exports.OpenAIApiDescriptionToTags = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Description to tags!", { structuredData: true });
    const { description } = data;
    const res = await getTags(description);
    const res2 = await getRequiredTag(description);
    return res2.concat(res);
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not get Description to tags.");
  }
});

exports.GetReviewsToDescription = onCall(
  { timeoutSeconds: 180, secrets: [OPENAI_API_KEY, GOOGLE_MAPS_API_KEY] },
  async ({ data, auth }) => {
    try {
      checkLogin(auth);
      logger.info("Get Best Reviews!", { structuredData: true });
      const googleMapsClient = new Client({});
      const { placeId } = data;
      if (!placeId) {
        throw new HttpsError("invalid-argument", "Place ID is required.");
      }

      let reviews = [];
      try {
        const res = await googleMapsClient.placeDetails({
          params: {
            place_id: placeId,
            key: GOOGLE_MAPS_API_KEY.value(),
          },
        });
        reviews = res.data.result.reviews || [];
      } catch (e) {
        logger.info(e.response?.data?.error_message ?? e, { structuredData: true });
      }
      reviews.sort((a, b) => b.rating - a.rating);
      const mostViewedReviews = reviews.slice(0, 9).map((e) => e["text"].trim()).join("\n");
      let output = "";
      if (mostViewedReviews != "") {
        const content = `
      Given the following customer reviews,
      please generate an objective description of the shop in japaneese\n
      Reviews: ${mostViewedReviews}`;
        const response = await getChatGPTResponse(content, 0.3);
        output = response.choices[0].message.content.trim();
      }
      return output;
    } catch (error) {
      logger.error("Error fetching reviews:", error);
      throw new HttpsError("unknown", "Error fetching reviews.");
    }
  },
);

exports.UsersPreferencesFromTags = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Users Preferences From Tags!", { structuredData: true });
    const { tags } = data;
    const content = `a user likes a shop with following tags: [${tags}]
    give this user five tags from above tags to describe this user’s preference with comma separated without any explainations.`;
    const response = await getChatGPTResponse(content);
    return splitTags(response.choices[0].message.content);
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not get Users Preferences From Tags.");
  }
});

exports.UsersPreferencesFromExistingTags = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Users Preferences From Tags!", { structuredData: true });
    const { existingTags, newTags } = data;
    const content = `this user previously following preference tags: [${existingTags}],
    recently, this user has some more preference tags: [${newTags}],
    give this user a fixed length of 20 preference tags in a array with the following rule:
    1.remove tags with similar meanings,
    2.rank new tags that are similar to the tags in the previous tag list,
    3.return only the array for data processing without explaining`;
    const response = await getChatGPTResponse(content);
    return splitTags(response.choices[0].message.content);
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not get Users Preferences From Existing Tags.");
  }
});

// Used by the shop app's visitor list. Was a text-davinci-003 completion.
exports.FindCompatibilityBetweenUserAndShop = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Find Compatibility Between User And Shop!", { structuredData: true });
    const { userTags, shopDescription, language } = data;
    const content = `
        one user has the following tags: ${userTags}
        my shop is a retail shop with description : ${shopDescription}
        Please analyze the compatibility between the user’s preferences and the shop/restaurant,
        and provide a brief summary of how well they match,
        along with suggestions on how the shop/restaurant can cater to this user’s preferences.
        Reply in ${language}`;
    const response = await getChatGPTResponse(content);
    return response.choices[0].message.content;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Find Compatibility Between User And Shop.");
  }
});

exports.OpenAIFindDescriptionFromName = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Find Description From Name!", { structuredData: true });
    const { shopName } = data;
    const content = `
       do you know the brand called ${shopName},
       if yes, give me a short description,
       if no, answer no without any explanation in japaneese
       add to shop description together with reviews`;
    const response = await getChatGPT4Response(content);
    let res = response.choices[0].message.content;
    if (res.includes("No")) {
      res = "Local Brand.";
    }
    return res;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Find Description From Name.");
  }
});

exports.OpenAIAddUserTagsFromDislike = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Add User Tags!", { structuredData: true });
    const { userTags } = data;
    const content = `
       you are a data scientist. one of my user dislike a shop with following tags
       ${userTags}
       can you help to generate some attribute tags for this user which he/she might be interested in?
       Give me answer in a list of string with comma separated format without any explanations.
    `;
    const response = await getChatGPTResponse(content);
    await addUserTags(auth.uid, response.choices[0].message.content.trim().split(","));
    return "OK";
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Add User Tags  From Dislike.");
  }
});

exports.OpenAIAddUserTagsFromDislikeV2 = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Add User Tags V2!", { structuredData: true });
    const { userTags } = data;
    const content = `
       one of my user dislike product with following tags
       ${userTags}
       can you help to generate some attribute tags for this user which he/she might be interested in?
       Give me answer in a list of string with comma separated format without any explanations.
    `;
    const response = await getChatGPT4Response(content, 0.3);
    await addUserTags(
      auth.uid,
      response.choices[0].message.content.trim().split(","),
      (tag) => tag.replaceAll("\"", ""),
    );
    return "OK";
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Add User Tags  From Dislike V2.");
  }
});

exports.OpenAIAddUserTagsFromLike = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Add User Tags!", { structuredData: true });
    const uid = auth.uid;
    const { campaignUid, taskUid } = data;
    const firestore = admin.firestore();
    let shopId = "";
    const taskSnapshot = await firestore
      .collection("m_users").doc(uid)
      .collection("user_campaigns").doc(campaignUid)
      .collection("user_campaign_tasks").doc(taskUid)
      .get();
    if (taskSnapshot.exists) {
      shopId = taskSnapshot.data().shopId;
    }

    let shopTags = [];
    const shopSnapshot = await firestore.collection("shops").doc(shopId).get();
    if (shopSnapshot.exists) {
      shopTags = shopSnapshot.data().tags.map((e) => e.toString());
    }
    const content = `
       you are a data scientist. one of my user like a shop with following tags
       ${shopTags}
       can you help to generate some attribute tags for this user which he/she might be interested in?
       Give me answer in a list of string with comma separated format without any explanations.
    `;
    const response = await getChatGPTResponse(content);
    await addUserTags(uid, response.choices[0].message.content.trim().split(","));
    return "OK";
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Add User Tags From Like.");
  }
});

exports.GeneratePersonalizedReason = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Generate Personalized Reason!", { structuredData: true });
    const { description, tags } = data;
    let content = "";
    if (tags.length === 0) {
      content = `
        You are a sales expert.
        Give the potential customer of the shop a recommendation for the shop with following description: ${description}
      `;
    } else {
      content = `
        You are a sales expert.
       This user can be described with the following tags: ${tags}, \n
       Give the potential customer of the shop a recommendation for the shop with following description: ${description}
      `;
    }
    const response = await getChatGPTResponse(content, 0.3);
    return response.choices[0].message.content;
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Generate Personalized Reason.");
  }
});

exports.OpenAIDynamicGpt4ForChat = onCall(openaiOptions, async ({ data, auth }) => {
  try {
    checkLogin(auth);
    logger.info("Dynamic GPT-4 for chat!", { structuredData: true });
    const { systemContent, userContent } = data;
    const response = await getChatGPT4Response(userContent, 0.42, systemContent);
    return response.choices[0].message.content.trim();
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Complete OpenAIDynamicGpt4ForChat");
  }
});

// --- Avatar chat (QR web chat) ------------------------------------------------

async function fetchAvatar(avatarUid) {
  let avatar = null;
  try {
    const snapshot = await admin.firestore().collection("m_avatars").doc(avatarUid).get();
    if (snapshot.exists) {
      avatar = snapshot.data();
    }
  } catch (e) {
    logger.info(e, { structuredData: true });
  }
  return avatar;
}

// Weaviate AvatarRec items near the question, as background knowledge text.
async function avatarRecQuery(avatarUid, query) {
  let result = "";
  try {
    const response = await weaviateDb().graphql
      .get()
      .withClassName("AvatarRec")
      .withNearText({ concepts: [query] })
      .withLimit(3)
      .withFields("title description")
      .withWhere({
        path: ["avatarUid"],
        operator: "Equal",
        valueText: avatarUid,
      })
      .do();
    if (response.data) {
      for (const el of response.data["Get"]["AvatarRec"]) {
        result += `\n${el["title"]}, ${el["description"]}\n`;
      }
    }
  } catch (e) {
    logger.info(e, { structuredData: true });
  }
  return result;
}

// Weaviate AvatarRec items near the question, skipping ids already shown.
async function recItemQuery(avatarUid, query, recItemUids) {
  const result = [];
  let whereFilter;
  const avatarOperand = {
    path: ["avatarUid"],
    operator: "Equal",
    valueText: avatarUid,
  };
  if (recItemUids.length > 0) {
    const recItemOperands = [avatarOperand];
    for (const recItemUid of recItemUids) {
      recItemOperands.push({
        path: ["id"],
        operator: "NotEqual",
        valueText: recItemUid,
      });
    }
    whereFilter = {
      "operator": "And",
      "operands": recItemOperands,
    };
  } else {
    whereFilter = avatarOperand;
  }
  try {
    const response = await weaviateDb().graphql
      .get()
      .withClassName("AvatarRec")
      .withNearText({ concepts: [query] })
      .withLimit(3)
      .withFields("title description price link _additional {id}")
      .withWhere(whereFilter)
      .do();
    if (response.data) {
      for (const el of response.data["Get"]["AvatarRec"]) {
        result.push({
          "title": el["title"],
          "description": el["description"],
          "link": el["link"],
          "price": el["price"],
          "id": el["_additional"]["id"],
        });
      }
    }
  } catch (e) {
    logger.info(e, { structuredData: true });
  }
  return result;
}

async function processUserContents(avatarUid, chats, question) {
  const userContent = new Map();
  const date = new Intl.DateTimeFormat("en-US", {
    timeZone: "Asia/Tokyo",
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    second: "numeric",
    hour12: true,
  }).format(new Date());
  userContent.set(
    "message", `
    Your friend's name: guest.
    datetime: ${date}.
    `,
  );
  userContent.set("role", "user");
  const chatsMap = chats.map((entry) => new Map(Object.entries(entry)));
  const userContents = [userContent, ...chatsMap];
  if (chats.length > 0) {
    const backgroundKnowledge = await avatarRecQuery(avatarUid, question);
    const userQuestion = new Map();
    userQuestion.set(
      "message", `
      friend's question: ${question}.\n
      background knowledge:${backgroundKnowledge}.\n
      `,
    );
    userQuestion.set("role", "user");
    userContents.push(userQuestion);
  }
  return userContents;
}

const avatarChatRequest = async (data, stream) => {
  const { avatarUid, chats, question, languageSetting } = data;
  const avatar = await fetchAvatar(avatarUid);
  const userContents = await processUserContents(avatarUid, chats, question);
  const systemContent = `${avatar.chatStarterPrompt}\n Please answer in ${languageSetting}`;
  return getChatGPT4StreamResponse(userContents, systemContent, 1, 300, stream);
};

const recReasonRequest = async (data, stream) => {
  const { avatarUid, needs, recommendation, languageSetting } = data;
  const userContent = new Map();
  userContent.set(
    "message",
    `needs: ${needs}.\n
    recommendation:${recommendation}.\n`,
  );
  userContent.set("role", "user");
  const avatar = await fetchAvatar(avatarUid);
  const systemContent = `${avatar.recPrompt} \n Please answer in ${languageSetting}`;
  return getChatGPT4StreamResponse([userContent], systemContent, 1, 300, stream);
};

// Streams the completion into the Realtime Database at `ref` (chunks of ~18
// tokens in "message"), then writes "///" to mark the end.
async function streamToDatabase(ref, responsePromise) {
  const response = await responsePromise;
  let text = "";
  let counter = 0;
  if (response) {
    for await (const part of response) {
      text += part.choices[0]?.delta?.content || "";
      counter++;
      if (counter === 18) {
        await admin.database().ref(ref).update({ "message": text });
        text = "";
        counter = 0;
      }
    }
  } else {
    logger.info("No data provided", { structuredData: true });
  }
  await admin.database().ref(ref).update({ "message": text });
  await admin.database().ref(ref).update({ "message": "///" });
  logger.info("Stream To Database finished");
}

// Creates /chats/{key} in the Realtime Database, returns its path at once and
// keeps streaming after the response. NOTE: work after a callable returns is
// not guaranteed to get CPU on Cloud Functions; this is how the original ran.
const startDatabaseStream = async (responseFactory) => {
  const ref = admin.database().ref("chats").push().key;
  const path = `/chats/${ref}`;
  await admin.database().ref(path).update({ "message": "" });
  streamToDatabase(path, responseFactory()).catch((e) => logger.info(e, { structuredData: true }));
  return path;
};

exports.ChatWithAvatar = onCall({ timeoutSeconds: 300, secrets: avatarChatSecrets }, async ({ data }) => {
  try {
    logger.info("Started Chat With Avatar");
    const response = await avatarChatRequest(data, false);
    return response.choices[0].message.content.trim();
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Finish Chat With Avatar.");
  }
});

exports.StreamChatForWeb = onCall({ timeoutSeconds: 300, secrets: avatarChatSecrets }, async ({ data }) => {
  try {
    logger.info("Started Chat With Avatar");
    return await startDatabaseStream(() => avatarChatRequest(data, true));
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Finish Chat With Avatar.");
  }
});

exports.FetchWeaviateRecItems = onCall(
  { timeoutSeconds: 300, secrets: [WEAVIATE_API_KEY, COHERE_API_KEY] },
  async ({ data }) => {
    try {
      logger.info("Fetching FetchWeaviateRecItems");
      const { avatarUid, question, existingUids } = data;
      return await recItemQuery(avatarUid, question, existingUids);
    } catch (e) {
      logger.info(e, { structuredData: true });
      throw new HttpsError("unknown", "Could Not Fetch FetchWeaviateRecItem.");
    }
  },
);

exports.FetchRecReason = onCall({ timeoutSeconds: 300, secrets: [OPENAI_API_KEY] }, async ({ data }) => {
  try {
    logger.info("Started Stream Rec Reason");
    const response = await recReasonRequest(data, false);
    return response.choices[0].message.content.trim();
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Finish Stream Rec Reason.");
  }
});

exports.StreamRecReason = onCall({ timeoutSeconds: 300, secrets: [OPENAI_API_KEY] }, async ({ data }) => {
  try {
    logger.info("Started Stream Rec Reason");
    return await startDatabaseStream(() => recReasonRequest(data, true));
  } catch (e) {
    logger.info(e, { structuredData: true });
    throw new HttpsError("unknown", "Could Not Finish Stream Rec Reason.");
  }
});
