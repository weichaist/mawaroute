// This file is similar to STATUS enums used in cloud functions
const status = {
  "UPLOADED_IMAGE_TO_IPFS": "UPLOADED_IMAGE_TO_IPFS",
  "STORING_METADATA_IN_DB": "STORING_METADATA_IN_DB",
  "UPLOADED_METADATA_TO_IPFS": "UPLOADED_METADATA_TO_IPFS",
  "MINTED": "MINTED",
};

enum ActivityName { started, cleared }

enum TaskType { imageMatching, iot }

enum RewardType { active, finished }

enum RewardDistributionType { email, onspot, coupon }

enum TargetUser { allCustomer, customerWithPurchaseHistory, aiUserTargeting }

enum CampaignStatus { active, draft, inActive, completed }

enum CampaignTypeStatus { campaign, userCampaign }

enum ShopStatusType { onBoarded, notOnBoarded }

enum CashBackStatusType { sent, notSent }

enum InStoreProductCampaignStatus { draft, completed }

enum QRType { st1 }

enum ChatMode { recommendations, question }

enum RecChatElementType {
  loading,
  streamText,
  text,
  recItem,
  recReason,
  imageText,
}

Map<String, String> taskTypeString = {
  'imageMatching': 'Image Matching Task',
  'iot': 'IoT Task',
};

Map<String, String> targetUserString = {
  'allCustomer': 'All customers',
  'customerWithPurchaseHistory': 'Customers with purchase history',
  'aiUserTargeting': 'AI user targeting',
};

List<String> recommendationFilters = ['retail', 'food&beverage', ''];

enum UsersChatBubbleType { userInput, productItem, output, shopItem }
