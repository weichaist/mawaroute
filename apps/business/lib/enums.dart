// This file is similar to STATUS enums used in cloud functions
import 'package:get/get.dart';

const status = {
  "UPLOADED_IMAGE_TO_IPFS": "UPLOADED_IMAGE_TO_IPFS",
  "STORING_METADATA_IN_DB": "STORING_METADATA_IN_DB",
  "UPLOADED_METADATA_TO_IPFS": "UPLOADED_METADATA_TO_IPFS",
  "MINTED": "MINTED",
};

enum TaskType { imageMatching, iot }

enum RewardType { active, archive }

enum RewardDistributionType { email, onspot, coupon }

enum ShopStatusType { onBoarded, notOnBoarded, sent, published }

enum TargetUser { allCustomer, aiUserTargeting }

enum CampaignStatus { active, draft, inActive, completed }

enum QRType { st1 }

Map<String, String> taskTypeString = {
  'imageMatching': 'Image Matching Task',
  'iot': 'IoT Task',
};

Map<String, String> targetUserString = {
  'allCustomer': 'All customers'.tr,
  'aiUserTargeting': 'AI user targeting'.tr,
};
