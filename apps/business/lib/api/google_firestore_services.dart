import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mawaroute_business/enums.dart';
import 'package:mawaroute_business/models/campaign_model.dart';

import '../models/campaign_task_model.dart';
import '../models/place_model.dart';
import '../models/reward_model.dart';

class FireStoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<DocumentReference> addCampaign({
    required Map<String, dynamic> campaignObject,
  }) async {
    return await _db.collection('campaigns').add(campaignObject);
  }

  Future<void> updateCampaign(
      {required String uid,
      required Map<String, dynamic> campaignObject}) async {
    campaignObject["editedAt"] = DateTime.now();
    await _db.collection('campaigns').doc(uid).update(campaignObject);
  }

  Future<void> updateCampaignTasks({
    required String uid,
    required List<Map<String, dynamic>> campaignTasksObject,
  }) async {
    await _db
        .collection('campaigns')
        .doc(uid)
        .collection('campaign_tasks')
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });

    for (dynamic campaignTaskObject in campaignTasksObject) {
      await _db
          .collection('campaigns')
          .doc(uid)
          .collection('campaign_tasks')
          .add(campaignTaskObject);
    }
  }

  Future<CampaignModel> fetchCampaignByUid({required String uid}) async {
    CampaignModel campaign = emptyCampaignModel;
    await _db.collection('campaigns').doc(uid).get().then((value) {
      campaign = CampaignModel.fromJson(
          value.data() as Map<String, dynamic>, value.id);
    });
    return campaign;
  }

  Future<int> fetchCampaignByPlaceUid({required String placeUid}) async {
    int count = 0;
    await _db
        .collection('campaigns')
        .where('placeUid', isEqualTo: placeUid)
        .where('status', isEqualTo: CampaignStatus.active.name)
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<List<CampaignTaskModel>> fetchMyCampaignTasks(
      {required String uid}) async {
    List<CampaignTaskModel> list = [];
    await _db
        .collection('campaigns')
        .doc(uid)
        .collection("campaign_tasks")
        .orderBy('index')
        .get()
        .then((value) {
      for (var element in value.docs) {
        list.add(CampaignTaskModel.fromJson(element.data()));
      }
    });
    return list;
  }

  Future<List<CampaignModel>> fetchMyCampaigns({required String status}) async {
    List<CampaignModel> list = [];
    await _db
        .collection('campaigns')
        .where('creatorUid', isEqualTo: _auth.currentUser?.uid)
        .where('status', isEqualTo: status)
        .limit(12)
        .get()
        .then((value) {
      for (var element in value.docs) {
        list.add(CampaignModel.fromJson(element.data(), element.id));
      }
    });
    return list;
  }

  Future<List<CampaignModel>> fetchActiveCampaigns() async {
    List<CampaignModel> list = [];
    await _db
        .collection('campaigns')
        .where('status', isEqualTo: CampaignStatus.active.name)
        .limit(8)
        .get()
        .then((value) {
      for (var element in value.docs) {
        list.add(CampaignModel.fromJson(element.data(), element.id));
      }
    });
    return list;
  }

  Future<List<CampaignModel>> fetchCompletedCampaigns() async {
    List<CampaignModel> list = [];
    await _db
        .collection('campaigns')
        .where('status', isEqualTo: CampaignStatus.completed.name)
        .limit(8)
        .get()
        .then((value) {
      for (var element in value.docs) {
        list.add(CampaignModel.fromJson(element.data(), element.id));
      }
    });
    return list;
  }

  Future<void> addPlace(Map<String, dynamic> object) async {
    await _db
        .collection('places')
        .doc(_auth.currentUser?.uid)
        .set(object, SetOptions(merge: true));
  }

  Future makePlacePublic() async {
    await _db
        .collection('places')
        .doc(_auth.currentUser?.uid)
        .update({'isPublic': true});
  }

  Future<PlaceModel> fetchPlace() async {
    PlaceModel place = emptyPlaceModel;
    await _db
        .collection('places')
        .doc(_auth.currentUser?.uid)
        .get()
        .then((value) {
      if (value.exists) {
        place = PlaceModel.fromJson(
          value.data() as Map<String, dynamic>,
          value.id,
        );
      }
    });
    return place;
  }

  Future<void> addReward({
    required Map<String, dynamic> rewardObject,
  }) async {
    await _db.collection('rewards').add(rewardObject);
  }

  Future<void> updateReward({
    required String uid,
    required Map<String, dynamic> rewardObject,
  }) async {
    await _db.collection('rewards').doc(uid).update(rewardObject);
  }

  Future<List<RewardModel>> fetchRewards({required String status}) async {
    List<RewardModel> list = [];
    await _db
        .collection('rewards')
        .where('placeUid', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: status)
        .limit(30)
        .get()
        .then((value) {
      for (var element in value.docs) {
        list.add(RewardModel.fromJson(
          element.data(),
          element.id,
        ));
      }
    });
    return list;
  }

  Future<RewardModel?> fetchRewardByUid({required String uid}) async {
    RewardModel? reward;
    await _db.collection('rewards').doc(uid).get().then((value) {
      if (value.exists) {
        reward = RewardModel.fromJson(
          value.data() as Map<String, dynamic>,
          value.id,
        );
      }
    });
    return reward;
  }

  Future addCampaignTaskImages(
      {required List<Map<String, dynamic>> taskImageObjects}) async {
    WriteBatch batch = _db.batch();
    for (var doc in taskImageObjects) {
      DocumentReference docRef = _db.collection("campaign_task_images").doc();
      batch.set(docRef, doc);
    }
    await batch.commit();
  }

  Future<int> shopVisitsCountByDay({required String shopUid}) async {
    int count = 0;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    await _db
        .collection('shops')
        .doc(shopUid)
        .collection("shop_visits")
        .where('visitTime', isGreaterThanOrEqualTo: startOfDay)
        .where('visitTime', isLessThanOrEqualTo: endOfDay)
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> shopVisitsCountByMonth({required String shopUid}) async {
    int count = 0;
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    await _db
        .collection('shops')
        .doc(shopUid)
        .collection("shop_visits")
        .where('visitTime', isGreaterThanOrEqualTo: startOfMonth)
        .where('visitTime', isLessThanOrEqualTo: endOfMonth)
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> shopVisitsCountTotal({required String shopUid}) async {
    int count = 0;

    await _db
        .collection('shops')
        .doc(shopUid)
        .collection("shop_visits")
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> shopPurchasesCountByDay({required String shopUid}) async {
    int count = 0;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    await _db
        .collection('shops')
        .doc(shopUid)
        .collection("shop_purchases")
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> shopPurchasesCountByMonth({required String shopUid}) async {
    int count = 0;
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    await _db
        .collection('shops')
        .doc(shopUid)
        .collection("shop_purchases")
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .where('timestamp', isLessThanOrEqualTo: endOfMonth)
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> shopPurchasesCountTotal({required String shopUid}) async {
    int count = 0;
    await _db
        .collection('shops')
        .doc(shopUid)
        .collection("shop_purchases")
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> rewardFavouritesCount({required String shopUid}) async {
    int count = 0;
    await _db
        .collection('rewards')
        .doc(shopUid)
        .collection("reward_participants")
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> rewardReceiversCount({required String shopUid}) async {
    int count = 0;
    await _db
        .collection('rewards')
        .doc(shopUid)
        .collection("reward_receivers")
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<Map> getProfileFromPublicAddress({
    required List<String> addresses,
  }) async {
    Map dt = {};
    if (addresses.isNotEmpty) {
      await _db
          .collection('m_users')
          .where("public_address", whereIn: addresses)
          .get()
          .then((value) {
        for (var doc in value.docs) {
          var data = doc.data();
          dt[data["public_address"]] = {
            'image': data["image"],
            'username': data["display_name"],
          };
        }
      });
    }
    return dt;
  }
}
