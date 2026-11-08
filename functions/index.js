// MaWaRoute Cloud Functions (2nd gen). Every export is listed in README.md
// with its trigger, the secrets it needs and the collections it touches.
const admin = require("firebase-admin");
admin.initializeApp();

const cloudMessage = require("./src/cloud_message");
const deleteOperation = require("./src/delete");
const ethersTransfer = require("./src/ethers_transfer");
const hasher = require("./src/hasher");
const linkPreview = require("./src/link_preview");
const moralis = require("./src/moralis");
const nft = require("./src/nft");
const openai = require("./src/openai");
const searchPlace = require("./src/search_place");
const sendgrid = require("./src/sendgrid");
const translator = require("./src/translator");
const updateCounter = require("./src/update_counter");
const userVisit = require("./src/user_visit");
const vision = require("./src/vision");
const weaviate = require("./src/weaviate");

// Algolia sync of `shops` (off by default, as in the original). To enable:
// const algolia = require("./src/algolia");
// exports.ShopAdd = algolia.ShopAdd;
// exports.ShopUpdate = algolia.ShopUpdate;
// exports.ShopDelete = algolia.ShopDelete;

// ERC-20 token and native-coin transfers
exports.MintERC20Token = ethersTransfer.MintERC20Token;
exports.TransferERC20TokenFromUidV2 = ethersTransfer.TransferERC20TokenFromUidV2;
exports.TransferMatic = ethersTransfer.TransferMatic;
exports.TransferERC20TokenFromUid = ethersTransfer.TransferERC20TokenFromUid;

// NFT
exports.Mint = nft.Mint;

// Moralis: wallet data, token holders, IPFS
exports.GetWalletTokenBalances = moralis.GetWalletTokenBalances;
exports.GetWalletNFTs = moralis.GetWalletNFTs;
exports.GetWalletTokenTransfers = moralis.GetWalletTokenTransfers;
exports.GetTopGGMTHolders = moralis.GetTopGGMTHolders;
exports.UploadToIPFS = moralis.UploadToIPFS;
exports.UploadIPFSMetaData = moralis.UploadIPFSMetaData;

// Google Places
exports.SearchPlace = searchPlace.SearchPlace;
exports.sendPhotoFromGooglePlaceAPI = searchPlace.sendPhotoFromGooglePlaceAPI;

// Geohash
exports.GeoHash = hasher.GeoHash;
exports.GeoHashLimit = hasher.GeoHashLimit;

// Cloud Vision
exports.AnnotateImage = vision.AnnotateImage;
exports.AnnotateImageV2 = vision.AnnotateImageV2;

// OpenAI
exports.OpenAIApiDescriptionToTags = openai.OpenAIApiDescriptionToTags;
exports.OpenAIFindDescriptionFromName = openai.OpenAIFindDescriptionFromName;
exports.GetReviewsToDescription = openai.GetReviewsToDescription;
exports.UsersPreferencesFromTags = openai.UsersPreferencesFromTags;
exports.UsersPreferencesFromExistingTags = openai.UsersPreferencesFromExistingTags;
exports.FindCompatibilityBetweenUserAndShop = openai.FindCompatibilityBetweenUserAndShop;
exports.OpenAIAddUserTagsFromDislike = openai.OpenAIAddUserTagsFromDislike;
exports.OpenAIAddUserTagsFromDislikeV2 = openai.OpenAIAddUserTagsFromDislikeV2;
exports.OpenAIAddUserTagsFromLike = openai.OpenAIAddUserTagsFromLike;
exports.GeneratePersonalizedReason = openai.GeneratePersonalizedReason;
exports.OpenAIDynamicGpt4ForChat = openai.OpenAIDynamicGpt4ForChat;
exports.ChatWithAvatar = openai.ChatWithAvatar;
exports.StreamChatForWeb = openai.StreamChatForWeb;
exports.FetchWeaviateRecItems = openai.FetchWeaviateRecItems;
exports.FetchRecReason = openai.FetchRecReason;
exports.StreamRecReason = openai.StreamRecReason;

// SendGrid invitations and news
exports.SendShopEmail = sendgrid.SendShopEmail;
exports.SendPlaceEmail = sendgrid.SendPlaceEmail;
exports.SendNotification = cloudMessage.SendNotification;
exports.DeleteNews = cloudMessage.DeleteNews;

// Translation
exports.TranslateToEnglish = translator.TranslateToEnglish;
exports.TranslateToJapanese = translator.TranslateToJapanese;

// Visits
exports.CreateVisitFromCompletedCampaign = userVisit.CreateVisitFromCompletedCampaign;
exports.CreateVisitFromCompletedUserCampaign = userVisit.CreateVisitFromCompletedUserCampaign;

// Weaviate sync
exports.WeaviateAvatarRecUpdate = weaviate.WeaviateAvatarRecUpdate;
exports.BrandAdd = weaviate.BrandAdd;
exports.BrandUpdate = weaviate.BrandUpdate;
exports.BrandDelete = weaviate.BrandDelete;
exports.WeaviateAvatarRecBatchAdd = weaviate.WeaviateAvatarRecBatchAdd;
exports.WeaviateAvatarRecBatchDeleteWithFileUid = weaviate.WeaviateAvatarRecBatchDeleteWithFileUid;

// Link previews
exports.getLinkPreview = linkPreview.getLinkPreview;
exports.getLinkListPreview = linkPreview.getLinkListPreview;

// Deleting
exports.DeleteKnowledgeFile = deleteOperation.DeleteKnowledgeFile;

// Counters
exports.UpdateChatCounter = updateCounter.UpdateChatCounter;
exports.UpdateKnowledgePointCounter = updateCounter.UpdateKnowledgePointCounter;
exports.UpdateKnowledgePointCounterForDeletion = updateCounter.UpdateKnowledgePointCounterForDeletion;
