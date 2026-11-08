import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mawaroute_shop/models/reward_receiver_model.dart';
import 'package:mawaroute_shop/models/shop_image_model.dart';
import 'package:mawaroute_shop/models/shop_model.dart';
import 'package:mawaroute_shop/models/user_visit_model.dart';
import 'package:mawaroute_shop/utils/enums.dart';

import '../models/place_model.dart';
import '_paginated_results.dart';

class FireStoreService {
  final _db = FirebaseFirestore.instance;

  Future<PlaceModel> fetchPlace(String uid) async {
    PlaceModel place = emptyPlaceModel;
    await _db.collection('places').doc(uid).get().then((value) {
      if (value.exists) {
        place = PlaceModel.fromJson(
          value.data() as Map<String, dynamic>,
          value.id,
        );
      }
    });
    return place;
  }

  Future<bool> isShopRegistered({required String managerUid}) async {
    bool exist = false;
    await _db
        .collection('shops')
        .where('managerUid', isEqualTo: managerUid)
        .get()
        .then((value) {
      exist = value.size > 0;
    });
    return exist;
  }

  Future<ShopModel> fetchShop({required String managerUid}) async {
    ShopModel shop = emptyShopModel;
    await _db
        .collection('shops')
        .where('managerUid', isEqualTo: managerUid)
        .get()
        .then((value) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = value.docs;
      if (docs.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>> value = docs.first;
        shop = ShopModel.fromJson(value.data(), value.id);
      }
    });
    return shop;
  }

  Future<bool> fetchPlaceShopByEmail({
    required String placeUid,
    required String email,
  }) async {
    bool exist = false;
    await _db
        .collection('places')
        .doc(placeUid)
        .collection('place_shops')
        .where('email', isEqualTo: email)
        .get()
        .then((value) => {exist = value.docs.isNotEmpty});
    return exist;
  }

  Future addShop({required Map<String, dynamic> shopInfo}) async {
    await _db.collection('shops').add(shopInfo);
  }

  Future updateShop({
    required String shopUid,
    required Map<String, dynamic> shopInfo,
  }) async {
    await _db.collection('shops').doc(shopUid).update(shopInfo);
  }

  Future addShopImages({
    required String shopUid,
    required List<Map<String, dynamic>> shopImages,
  }) async {
    WriteBatch batch = _db.batch();
    for (var shopImage in shopImages) {
      DocumentReference docRef =
          _db.collection('shops').doc(shopUid).collection("shop_images").doc();
      batch.set(docRef, shopImage);
    }
    await batch.commit();
  }

  Future deleteShopImages({
    required String shopUid,
    required List<String> imagesUid,
  }) async {
    for (String imageUid in imagesUid) {
      await _db
          .collection("shops")
          .doc(shopUid)
          .collection("shop_images")
          .doc(imageUid)
          .delete();
    }
  }

  Future<Map<dynamic, dynamic>> fetchShopImages(
      {int limit = 24, DocumentSnapshot? snapshot, required shopUid}) async {
    Query query = _db
        .collection("shops")
        .doc(shopUid)
        .collection("shop_images")
        .orderBy('createdAt', descending: true);

    Map output = await paginatedResults(
      query: query,
      snapshot: snapshot,
      limit: limit,
    );
    output["results"] = output["results"]
        .map<ShopImageModel>((element) => ShopImageModel.fromJson(
            element.data() as Map<String, dynamic>, element.id))
        .toList();
    return output;
  }

  Future<Map<dynamic, dynamic>> fetchShopVisits({
    int limit = 24,
    DocumentSnapshot? snapshot,
    required shopUid,
    required String timeframe,
  }) async {
    final now = DateTime.now();
    final start = timeframe == Timeframe.today.name
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, 1);
    final end = timeframe == Timeframe.today.name
        ? start.add(const Duration(days: 1))
        : DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    Query query = _db
        .collection("shops")
        .doc(shopUid)
        .collection("shop_visits")
        .where('visitTime', isGreaterThanOrEqualTo: start)
        .where('visitTime', isLessThan: end)
        .orderBy('visitTime', descending: true);

    Map output = await paginatedResults(
      query: query,
      snapshot: snapshot,
      limit: limit,
    );
    output["results"] = output["results"]
        .map<UserVisitModel>((element) => UserVisitModel.fromJson(
            element.data() as Map<String, dynamic>, element.id))
        .toList();
    return output;
  }

  Future<int> fetchShopVisitCountByDay({required String shopUid}) async {
    int count = 0;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    await _db
        .collection("shops")
        .doc(shopUid)
        .collection("shop_visits")
        .where('visitTime', isGreaterThanOrEqualTo: startOfToday)
        .where('visitTime', isLessThan: startOfTomorrow)
        .count()
        .get()
        .then((value) => {count = value.count ?? 0});

    return count;
  }

  Future<int> fetchShopVisitsCountByMonth({required String shopUid}) async {
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

  Future<int> fetchShopPurchasesCountByDay({required String shopUid}) async {
    int count = 0;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    await _db
        .collection("shops")
        .doc(shopUid)
        .collection("shop_purchases")
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .where('timestamp', isLessThan: startOfTomorrow)
        .count()
        .get()
        .then((value) => {count = value.count ?? 0});
    return count;
  }

  Future<int> fetchShopPurchasesCountByMonth({required String shopUid}) async {
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

  Future<List<String>> fetchCouponRewards({required String shopUid}) async {
    DateTime now = DateTime.now();
    List<String> list = [];
    await _db
        .collection('rewards')
        .where('couponShopUid', isEqualTo: shopUid)
        .where('endTime', isGreaterThan: now)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        DateTime startTime = doc['startTime'].toDate();
        if (startTime.isBefore(now)) {
          list.add(doc.id);
        }
      }
    });
    return list;
  }

  Future<List<RewardReceiverModel>> fetchCouponUsages(
      {required String rewardUid}) async {
    List<RewardReceiverModel> list = [];
    await _db
        .collectionGroup('reward_receivers')
        .where('rewardUid', isEqualTo: rewardUid)
        .where('applied', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        list.add(RewardReceiverModel.fromJson(doc.data(), doc.id));
      }
    });
    return list;
  }
}
