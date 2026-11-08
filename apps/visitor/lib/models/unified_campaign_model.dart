import '../enums.dart';

class UnifiedCampaignModel {
  final String uid;
  final String title;
  final String description;
  final String downloadUrl;
  final DateTime startTime;
  final int taskCount;
  final String status;
  final String campaignType;

  UnifiedCampaignModel({
    required this.uid,
    required this.title,
    required this.description,
    required this.downloadUrl,
    required this.startTime,
    required this.taskCount,
    required this.status,
    required this.campaignType,
  });
}

final emptyCampaignModel = UnifiedCampaignModel(
  uid: '',
  title: '',
  description: '',
  downloadUrl: '',
  startTime: DateTime.now(),
  taskCount: 0,
  status: CampaignStatus.active.name,
  campaignType: CampaignTypeStatus.campaign.name,
);
