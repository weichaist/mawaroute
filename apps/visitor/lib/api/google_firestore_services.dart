import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mawaroute_visitor/models/app_info_model.dart';
import 'package:mawaroute_visitor/models/m_user_credentials.dart';

import '../enums.dart';
import '../models/m_user.dart';
import '../models/mawaroute_wallet_model.dart';
import '../models/reward_model.dart';
import '../models/reward_receiver_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addUser(Map<String, dynamic> userObj) async {
    DocumentReference user = _db
        .collection('m_users')
        .doc(_auth.currentUser?.uid);
    await user.set(userObj, SetOptions(merge: true));
  }

  Future<void> addUsersPrivateKeyToCredentials(
    Map<String, dynamic> credentials,
  ) async {
    CollectionReference credentialRef = _db
        .collection('m_users')
        .doc(_auth.currentUser?.uid)
        .collection('credentials');
    await credentialRef.add(credentials);
  }

  Future<void> updateUser(Map<String, dynamic> userObj) async {
    DocumentReference user = _db
        .collection('m_users')
        .doc(_auth.currentUser?.uid);
    await user.update(userObj);
  }

  Future<void> updateUserDisplayName({required String displayName}) async {
    await updateUser({'display_name': displayName});
  }

  Future<int> checkUserDisplayNameExist({required String displayName}) async {
    int count = 0;
    await _db
        .collection('m_users')
        .where(FieldPath.documentId, isNotEqualTo: _auth.currentUser?.uid)
        .where('display_name', isEqualTo: displayName)
        .count()
        .get()
        .then((value) {
          count = value.count ?? 0;
        });
    return count;
  }

  Future<void> updateUserImage({required String image}) async {
    await updateUser({'image': image});
  }

  Future<void> updateUserSignInTimeStamp() async {
    await updateUser({'sign_in_at': DateTime.now()});
  }

  Future<MUser?> getUserDetails() async {
    MUser? mUser;
    DocumentReference user = _db
        .collection('m_users')
        .doc(_auth.currentUser?.uid);
    await user.get().then((value) {
      if (value.exists) {
        mUser = MUser.fromJson(value.data() as Map<String, dynamic>, value.id);
      }
    });
    return mUser;
  }

  Future addCashBackRewardReceiver({
    required String rewardUid,
    required Map<String, dynamic> rewardReceiverObj,
  }) async {
    await _db
        .collection('top_rewards')
        .doc(rewardUid)
        .collection('cashback_receivers')
        .add(rewardReceiverObj);
  }

  Future applyCoupon({
    required String rewardUid,
    required String rewardReceiverUid,
  }) async {
    await _db
        .collection('rewards')
        .doc(rewardUid)
        .collection('reward_receivers')
        .doc(rewardReceiverUid)
        .update({"applied": true, "appliedTimestamp": DateTime.now()});
  }

  Future<bool> reduceUpperLimit({
    required String rewardUid,
    required int limitChange,
  }) async {
    bool isSuccessful = false;
    final sfDocRef = _db.collection('rewards').doc(rewardUid);
    await _db
        .runTransaction((transaction) async {
          final value = await transaction.get(sfDocRef);
          if (value.exists) {
            RewardModel rewardModel = RewardModel.fromJson(
              value.data() as Map<String, dynamic>,
              value.id,
            );
            int upperLimit = rewardModel.upperLimit;
            if (limitChange < 0) {
              if (upperLimit > 0) {
                transaction.update(sfDocRef, {
                  'upperLimit': upperLimit + limitChange,
                });
                isSuccessful = true;
              }
            } else {
              if (upperLimit >= 0) {
                transaction.update(sfDocRef, {
                  'upperLimit': upperLimit + limitChange,
                });
                isSuccessful = true;
              }
            }
          } else {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'predefined-condition-failed',
            );
          }
        })
        .catchError((e) {
          if (kDebugMode) print(e);
        });
    return isSuccessful;
  }

  Future didUserReceivedReward({
    required String rewardUid,
    required String receiverUid,
  }) async {
    bool isUserReceivedReward = false;
    await _db
        .collection('rewards')
        .doc(rewardUid)
        .collection('reward_receivers')
        .where('receiver', isEqualTo: receiverUid)
        .count()
        .get()
        .then((value) {
          isUserReceivedReward = (value.count ?? 0) > 0;
        });
    return isUserReceivedReward;
  }

  Future<RewardModel> fetchRewardByUid({required String uid}) async {
    RewardModel rewardModel = emptyReward;
    await _db.collection('rewards').doc(uid).get().then((value) {
      if (value.exists) {
        RewardModel reward = RewardModel.fromJson(
          value.data() as Map<String, dynamic>,
          value.id,
        );
        if (reward.status == RewardType.active.name) {
          rewardModel = reward;
        }
      }
    });
    return rewardModel;
  }

  Future addRewardReceiver({
    required String rewardUid,
    required Map<String, dynamic> rewardReceiverObj,
  }) async {
    await _db
        .collection('rewards')
        .doc(rewardUid)
        .collection('reward_receivers')
        .add(rewardReceiverObj);
  }

  Future<List<RewardReceiverModel>> fetchRewardsUsageHistory({
    required String rewardUid,
  }) async {
    List<RewardReceiverModel> list = [];
    await _db
        .collection('rewards')
        .doc(rewardUid)
        .collection('reward_receivers')
        .where('rewardUid', isEqualTo: rewardUid)
        .where('receiver', isEqualTo: _auth.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) {
          for (var doc in value.docs) {
            list.add(RewardReceiverModel.fromJson(doc.data(), doc.id));
          }
        });
    return list;
  }

  Future<AppInfoModel> getAppInfo() async {
    AppInfoModel appInfo = emptyAppInfo;
    String doc = Platform.isIOS ? 'ios_version' : 'android_version';
    await _db.collection('env').doc(doc).get().then((value) {
      if (value.exists) {
        var data = value.data();
        appInfo = AppInfoModel.fromJson(data!);
      }
    });
    return appInfo;
  }

  Future<MawarouteWalletModel?> getMawarouteWalletInfo() async {
    MawarouteWalletModel? wallet;
    await _db.collection('env').doc('mawaroute_wallet').get().then((value) {
      if (value.exists) {
        wallet = MawarouteWalletModel.fromJson(value.data()!);
      }
    });
    return wallet;
  }

  Future<MUserCredential> getUserCredentials() async {
    MUserCredential credential = emptyMUserCredential;
    await _db
        .collection('m_users')
        .doc(_auth.currentUser?.uid)
        .collection('credentials')
        .limit(1)
        .get()
        .then((value) {
          if (value.docs.isNotEmpty) {
            var doc = value.docs[0];
            credential = MUserCredential.fromJson(doc.data(), doc.id);
          }
        });
    return credential;
  }

  Future updateUserCredentials({
    required String uid,
    required Map<String, dynamic> obj,
  }) async {
    await _db
        .collection('m_users')
        .doc(_auth.currentUser?.uid)
        .collection('credentials')
        .doc(uid)
        .update(obj);
  }

  Future<bool> isAccountDeleteRequested() async {
    bool deleted = false;
    await _db
        .collection('account_deletion_requests')
        .where("userUid", isEqualTo: _auth.currentUser!.uid)
        .get()
        .then((value) {
          var docs = value.docs;
          if (docs.isNotEmpty) {
            deleted = true;
          }
        });
    return deleted;
  }

  Future accountDeleteRequestedAdd() async {
    await _db.collection('account_deletion_requests').add({
      "userUid": _auth.currentUser!.uid,
      "timestamp": DateTime.now(),
    });
  }
}
