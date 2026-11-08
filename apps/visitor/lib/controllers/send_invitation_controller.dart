import "dart:convert";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:crypto/crypto.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter_smart_dialog/flutter_smart_dialog.dart";
import "package:get/get.dart";
import "package:mawaroute_visitor/models/m_user.dart";

import "../api/google_firestore_services.dart";
import "../utilis/token_transfers/transfer_functions.dart";

class SendInvitationController extends GetxController {
  static SendInvitationController instance =
      Get.find<SendInvitationController>();
  FirestoreService api = FirestoreService();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  RxString userInvitationCode = "".obs;
  RxString redeemedInvitationCode = "".obs;
  RxList<MUser> top30Friends = <MUser>[].obs;

  Future<void> init() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    String value = sha256.convert(utf8.encode(userUid)).toString();
    userInvitationCode.value = await updateInvitationCode(
      userUid,
      value.substring(0, 8),
    );
    redeemedInvitationCode.value = "";
    top30Friends.value = await getTop30Friends();
  }

  Future<List<MUser>> getTop30Friends() async {
    List<String> friends = [];
    List<MUser> top30 = [];
    await _db
        .collection("invitation_received")
        .where("invitation_sender_uid", isEqualTo: _auth.currentUser!.uid)
        .orderBy("timestamp", descending: true)
        .limit(30)
        .get()
        .then((value) {
          List<QueryDocumentSnapshot> docs = value.docs;
          for (QueryDocumentSnapshot doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            friends.add(data["invitation_receiver_uid"]);
          }
        });
    if (friends.isNotEmpty) {
      await _db
          .collection('m_users')
          .where(FieldPath.documentId, whereIn: friends)
          .get()
          .then((value) {
            var docs = value.docs;
            for (QueryDocumentSnapshot doc in docs) {
              top30.add(
                MUser.fromJson(doc.data() as Map<String, dynamic>, doc.id),
              );
            }
          });
    }
    return top30;
  }

  Future<String> getInvitationCodeFromUid(String uid) async {
    String invitationCode = "";
    await _db.collection("m_users").doc(uid).get().then((value) {
      if (value.exists) {
        var data = value.data()!;
        invitationCode = data.containsKey("invitation_code")
            ? data["invitation_code"]
            : "";
      }
    });
    return invitationCode;
  }

  Future<String> updateInvitationCode(String uid, String invitationCode) async {
    String finalInvitationCode = "";
    try {
      String initialInvitationCode = await getInvitationCodeFromUid(uid);
      if (initialInvitationCode.isEmpty) {
        await _db.collection("m_users").doc(uid).update({
          "invitation_code": invitationCode,
        });
        finalInvitationCode = invitationCode;
      } else {
        finalInvitationCode = initialInvitationCode;
      }
    } catch (e) {
      if (kDebugMode) print("Could not get invitation code");
    }

    return finalInvitationCode;
  }

  Future<String> getUidFromInvitationCode(String invitationCode) async {
    String uid = "";
    await _db
        .collection("m_users")
        .where("invitation_code", isEqualTo: invitationCode)
        .limit(1)
        .get()
        .then((value) {
          var docs = value.docs;
          if (docs.isNotEmpty) {
            uid = docs[0].id;
          }
        });
    return uid;
  }

  Future<void> saveRedeemedCode() async {
    try {
      SmartDialog.showLoading(msg: 'Processing...'.tr);
      String invitationSenderUid = await getUidFromInvitationCode(
        redeemedInvitationCode.value,
      );
      if (invitationSenderUid == "") {
        SmartDialog.showNotify(
          msg: "Invitation code is not found".tr,
          notifyType: NotifyType.alert,
        );
      } else if (invitationSenderUid == _auth.currentUser!.uid) {
        SmartDialog.showNotify(
          msg: "Invitation code is not found".tr,
          notifyType: NotifyType.alert,
        );
      } else {
        bool isDuplicate = true;
        await _db
            .collection("invitation_received")
            // .where("invitation_sender_uid", isEqualTo: invitationSenderUid)
            .where("invitation_receiver_uid", isEqualTo: _auth.currentUser!.uid)
            // .where("invitation_code", isEqualTo: redeemedInvitationCode.value)
            .count()
            .get()
            .then((value) {
              isDuplicate = value.count != 0;
            });
        if (isDuplicate == true) {
          SmartDialog.showNotify(
            msg: "You have used the invitation code already".tr,
            notifyType: NotifyType.alert,
          );
        } else {
          await _db.collection("invitation_received").add({
            "invitation_sender_uid": invitationSenderUid,
            "invitation_receiver_uid": _auth.currentUser!.uid,
            "invitation_code": redeemedInvitationCode.value,
            "timestamp": DateTime.now(),
          });
          await transferERC20TokenFromUid(
            transferredAmount: 10,
            uid: _auth.currentUser!.uid,
          );
          await transferERC20TokenFromUid(
            transferredAmount: 10,
            uid: invitationSenderUid,
          );
          SmartDialog.showNotify(msg: "OK", notifyType: NotifyType.success);
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future<void> saveSpecialCode() async {
    SmartDialog.showLoading(msg: 'Processing...'.tr);
    try {
      bool isDuplicate = true;
      String specialRewardUid = "";
      int tokenNumber = 0;
      await _db
          .collection("special_reward_code")
          .where("code", isEqualTo: redeemedInvitationCode.value)
          .where("isLive", isEqualTo: true)
          .get()
          .then((value) {
            if (value.docs.isNotEmpty) {
              var doc = value.docs[0];
              specialRewardUid = doc.id;
              tokenNumber = doc.data()["tokenNumber"];
            }
          });
      if (specialRewardUid == "") {
        SmartDialog.showNotify(
          msg: "Invalid reward code".tr,
          notifyType: NotifyType.alert,
        );
        return;
      } else {
        await _db
            .collection("special_reward_code")
            .doc(specialRewardUid)
            .collection("special_reward_receivers")
            .where("receiverUid", isEqualTo: _auth.currentUser!.uid)
            .count()
            .get()
            .then((value) {
              isDuplicate = value.count != 0;
            });
      }
      if (isDuplicate == true) {
        SmartDialog.showNotify(
          msg: "You have used the invitation code already".tr,
          notifyType: NotifyType.alert,
        );
      } else {
        await _db
            .collection("special_reward_code")
            .doc(specialRewardUid)
            .collection("special_reward_receivers")
            .add({
              "receiverUid": _auth.currentUser!.uid,
              "invitation_code": redeemedInvitationCode.value,
              "timestamp": DateTime.now(),
            });
        await transferERC20TokenFromUid(
          transferredAmount: tokenNumber,
          uid: _auth.currentUser!.uid,
        );
        SmartDialog.showNotify(
          msg: "Congrats! Your tokens are on the way".tr,
          notifyType: NotifyType.success,
        );
      }
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      SmartDialog.dismiss();
    }
  }
}
