import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mawaroute_visitor/controllers/auth_controller.dart';
import 'package:mawaroute_visitor/models/m_avatar_model.dart';
import 'package:mawaroute_visitor/utilis/pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

import '../api/google_firestore_services.dart';
import '../config/app_config.dart';
import '../contracts.dart';
import '../enums.dart';
import '../models/m_user_credentials.dart';
import '../models/mawaroute_wallet_model.dart';

class WalletController extends GetxController {
  static WalletController instance = Get.find<WalletController>();
  AuthController authController = AuthController.instance;
  final _db = cloud_firestore.FirebaseFirestore.instance;
  FirestoreService f = FirestoreService();

  Rx<TextEditingController> transferAmountController =
      TextEditingController().obs;

  RxDouble tokenBalance = 0.0.obs;
  RxString walletAddress = ''.obs;

  RxDouble maticBalance = 0.0.obs;
  RxInt chainId = 1.obs;
  RxString mawarouteWalletAddress = ''.obs;
  RxInt transferAmount = 0.obs;
  Web3Client client = Web3Client('', Client());
  MawarouteWalletModel? walletModel;
  DeployedContract? contract;

  List<String> recentIdList = [];
  Rx<Pagination<MAvatarModel>> mAvatars = Pagination<MAvatarModel>(
    query: null,
    fromJson: (json, id) => MAvatarModel.fromJson(json, id),
  ).obs;

  final selectedTab = 0.obs;

  Future<void> init() async {
    selectedTab.value = 0;
    mAvatars.value = Pagination<MAvatarModel>(
      query: null,
      fromJson: (json, id) => MAvatarModel.fromJson(json, id),
    );
  }

  Future<void> fetchPaginatedAvatars() async {
    int end = min(mAvatars.value.limit, recentIdList.length);
    List<String> recentList = recentIdList.sublist(0, end);
    recentIdList.removeRange(0, end);
    mAvatars.value.snapshot = null;
    mAvatars.value.query = _db
        .collection('m_avatars')
        .where(cloud_firestore.FieldPath.documentId, whereIn: recentList);
    await mAvatars.value.fetch();
    mAvatars.refresh();
  }

  Future<void> fetchRecentChats() async {
    if (recentIdList.isEmpty) {
      await _db
          .collection("user_rec_chats")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
            if (value.exists) {
              recentIdList = value
                  .data()!["recent_chats"]
                  .cast<String>()
                  .toList();
            }
          });
    }
    await fetchPaginatedAvatars();
  }

  void setClientAndContract() {
    // No token configured (ERC20_CONTRACT_ADDRESS empty): skip GGMT balances.
    contract = AppConfig.erc20ContractAddress.isEmpty
        ? null
        : DeployedContract(
            ContractAbi.fromJson(json.encode(erc20ContractAbi), 'GGMT'),
            EthereumAddress(hexToBytes(AppConfig.erc20ContractAddress)),
          );
    client = Web3Client(walletModel!.rpcUrl, Client());
  }

  Future<void> initTokenBalanceCheck() async {
    await authController.updateUserprofile();
    walletModel = await f.getMawarouteWalletInfo();
    setClientAndContract();
    if (authController.profile.value.publicAddress.isNotEmpty) {
      walletAddress.value = authController.profile.value.publicAddress;
      await fetchTokenBalance();
    }
  }

  Future fetchTokenBalance() async {
    try {
      if (walletModel != null && contract != null) {
        final List<dynamic> result = await client.call(
          contract: contract!,
          function: contract!.function('balanceOf'),
          params: [
            EthereumAddress(
              hexToBytes(authController.profile.value.publicAddress),
            ),
          ],
        );
        tokenBalance.value = EtherAmount.fromBigInt(
          EtherUnit.wei,
          result[0],
        ).getInEther.toDouble();
      }
    } catch (e) {
      if (kDebugMode) print('Could not get User Token Balance.');
    }
  }

  Future fetchNativeBalanceForPolygon() async {
    try {
      EtherAmount balance = await client.getBalance(
        EthereumAddress(hexToBytes(walletAddress.value)),
      );
      double res = balance.getValueInUnit(EtherUnit.ether);
      maticBalance.value = res;
    } catch (e) {
      if (kDebugMode) print('Could not get User Balance.');
    }
  }

  String getPublicAddress(String privateKey) {
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = credentials.address;
    return address.with0x;
  }

  Future<String> getPrivateKey() async {
    String privateKey = "";
    try {
      MUserCredential credential = await f.getUserCredentials();
      privateKey = credential.key;
    } catch (e) {
      if (kDebugMode) {
        print("Could not get private key");
      }
    }
    return privateKey;
  }

  Future transferGGMTToken(String rewardUid, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString(
      'mawaroute_private_key_${authController.profile.value.id}',
    );
    privateKey ??= '';
    if (privateKey.isEmpty) {
      await prefs.setString(
        "mawaroute_private_key_${authController.profile.value.id}",
        privateKey,
      );
      privateKey = await getPrivateKey();
    }
    if (privateKey.isEmpty) {
      SmartDialog.showToast('Cannot find your private key'.tr);
      return;
    }
    String publicKey = getPublicAddress(privateKey);
    if (publicKey != walletAddress.value) {
      SmartDialog.showToast('Credentials mismatch'.tr);
      return;
    }

    if (transferAmount.value == 0) {
      SmartDialog.showToast('Please enter transfer amount'.tr);
      return;
    }
    if (transferAmount.value > tokenBalance.value) {
      SmartDialog.showToast('Insufficient Balance'.tr);
      return;
    }
    bool limitReduced = false;
    try {
      SmartDialog.showLoading(msg: "Processing...");
      limitReduced = await f.reduceUpperLimit(
        rewardUid: rewardUid,
        limitChange: -1,
      );
      if (!limitReduced) {
        SmartDialog.dismiss();
        SmartDialog.showNotify(
          msg: 'All rewards have been redeemed',
          notifyType: NotifyType.alert,
        );
        return;
      }
      EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
      setClientAndContract();
      final transfer = contract!.function('transfer');
      await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract!,
          function: transfer,
          parameters: [
            EthereumAddress(hexToBytes(mawarouteWalletAddress.value)),
            EtherAmount.fromInt(EtherUnit.ether, transferAmount.value).getInWei,
          ],
        ),
        chainId: chainId.value,
      );
      await f.addRewardReceiver(
        rewardUid: rewardUid,
        rewardReceiverObj: {
          "rewardUid": rewardUid,
          "receiver": authController.profile.value.id,
          "timestamp": DateTime.now(),
          "email": email.isNotEmpty
              ? email
              : authController.profile.value.displayName,
          'tokenTransferred': transferAmount.value,
        },
      );
      SmartDialog.dismiss();
      SmartDialog.showToast('${'Transferred'.tr}${transferAmount.value} GGMT');
      SmartDialog.dismiss(tag: 'transferDialog');
      SmartDialog.showNotify(
        msg: 'Congratulations! You have got this reward'.tr,
        notifyType: NotifyType.success,
      );
    } catch (e) {
      if (kDebugMode) print(e);
      SmartDialog.dismiss();
      if (limitReduced) {
        await f.reduceUpperLimit(rewardUid: rewardUid, limitChange: 1);
      }
      if (e.toString().contains('gas required exceeds allowance')) {
        SmartDialog.showToast('Get MATIC first, then transfer GGMT'.tr);
      } else {
        SmartDialog.showToast('Could not transfer GGMT token.'.tr);
      }
    }
  }

  Future<void> initGGMTTransfer() async {
    await initTokenBalanceCheck();
    MawarouteWalletModel? walletModel = await f.getMawarouteWalletInfo();
    if (walletModel != null) {
      SmartDialog.showLoading(msg: 'Processing...'.tr);
      mawarouteWalletAddress.value = walletModel.address;
      chainId.value = walletModel.chainId;
      setClientAndContract();
      await fetchNativeBalanceForPolygon();
      await fetchTokenBalance();
      SmartDialog.dismiss();
    } else {
      SmartDialog.dismiss();
      SmartDialog.showNotify(
        msg: 'Oops, an error has occurred during loading your wallet...',
        notifyType: NotifyType.failure,
      );
    }
  }

  Future<bool> transferGGMTTokenForCashBack({
    required String rewardUid,
    required int transferAmount,
    required int cashBackAmount,
    required String email,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString(
      'mawaroute_private_key_${authController.profile.value.id}',
    );
    privateKey ??= '';
    if (privateKey.isEmpty) {
      await prefs.setString(
        "mawaroute_private_key_${authController.profile.value.id}",
        privateKey,
      );
      privateKey = await getPrivateKey();
    }
    if (privateKey.isEmpty) {
      SmartDialog.showToast('Cannot find your private key'.tr);
      return false;
    }
    String publicKey = getPublicAddress(privateKey);
    if (publicKey != walletAddress.value) {
      SmartDialog.showToast('Credentials mismatch'.tr);
      return false;
    }

    if (transferAmount == 0) {
      SmartDialog.showToast('Please enter transfer amount'.tr);
      return false;
    }

    if (transferAmount > tokenBalance.value) {
      await SmartDialog.showToast(
        'Insufficient Balance'.tr,
        usePenetrate: true,
      );
      return false;
    }
    try {
      SmartDialog.showLoading(msg: "Processing...");
      EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
      final transfer = contract!.function('transfer');
      await client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract!,
          function: transfer,
          parameters: [
            EthereumAddress(hexToBytes(mawarouteWalletAddress.value)),
            EtherAmount.fromInt(EtherUnit.ether, transferAmount).getInWei,
          ],
        ),
        chainId: chainId.value,
      );
      User currentUser = FirebaseAuth.instance.currentUser!;
      await f.addCashBackRewardReceiver(
        rewardUid: rewardUid,
        rewardReceiverObj: {
          "rewardUid": rewardUid,
          "receiver": currentUser.uid,
          "timestamp": DateTime.now(),
          "email": email,
          'tokenTransferred': transferAmount,
          'cashBackAmount': cashBackAmount,
          'status': CashBackStatusType.notSent.name,
        },
      );
      SmartDialog.dismiss();
      SmartDialog.showToast('${'Transferred'.tr}$transferAmount GGMT');
      SmartDialog.showToast('Congratulations! You have got this reward'.tr);
      return true;
    } catch (e) {
      if (kDebugMode) print(e);
      SmartDialog.dismiss();
      if (e.toString().contains('gas required exceeds allowance')) {
        SmartDialog.showToast('Get MATIC first, then transfer GGMT'.tr);
      } else {
        SmartDialog.showToast('Could not transfer GGMT token.'.tr);
      }
      return false;
    }
  }

  Future requestAccountDelete() async {
    try {
      bool deleted = await f.isAccountDeleteRequested();
      if (!deleted) {
        await f.accountDeleteRequestedAdd();
      } else {
        SmartDialog.showToast(
          'We are processing your request. We will get back to you soon.'.tr,
        );
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
    client.dispose();
  }
}
