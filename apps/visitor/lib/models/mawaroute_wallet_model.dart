class MawarouteWalletModel {
  final String address;
  final String rpcUrl;
  final int chainId;
  MawarouteWalletModel({
    required this.address,
    required this.rpcUrl,
    required this.chainId,
  });

  factory MawarouteWalletModel.fromJson(Map<String, dynamic> json) {
    return MawarouteWalletModel(
      address: json['address'],
      rpcUrl: json['rpcUrl'],
      chainId: json['chainId'],
    );
  }
}
