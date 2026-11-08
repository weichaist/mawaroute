class AppInfoModel {
  final String version;
  final String appStoreUrl;
  AppInfoModel({required this.version, required this.appStoreUrl});

  factory AppInfoModel.fromJson(Map<String, dynamic> json) {
    return AppInfoModel(
      version: json["version"],
      appStoreUrl: json["appStoreUrl"],
    );
  }
  Map<String, dynamic> toJson() {
    return {"version": version, "appStoreUrl": appStoreUrl};
  }
}

final emptyAppInfo = AppInfoModel(version: "", appStoreUrl: "");
