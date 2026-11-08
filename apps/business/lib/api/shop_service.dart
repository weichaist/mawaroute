import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mawaroute_business/enums.dart';

import '../models/shop_model.dart';

class ShopService {
  final _db = FirebaseFirestore.instance;

  Future<ShopModel> getShopByUid(String uid) async {
    ShopModel place = emptyShopModel;
    await _db.collection('shops').doc(uid).get().then((value) {
      place = ShopModel.fromJson(
        value.data() as Map<String, dynamic>,
        value.id,
      );
    });
    return place;
  }

  Future<int> numberOfShops({
    required String placeUid,
  }) async {
    int count = 0;
    await _db
        .collection('shops')
        .where('placeUid', isEqualTo: placeUid)
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> numberOfShopVisits({
    required String shopUid,
  }) async {
    int count = 0;
    await _db
        .collection('shops')
        .doc(shopUid)
        .collection('shop_visits')
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<int> numberOfShopPurchases({
    required String shopUid,
  }) async {
    int count = 0;
    await _db
        .collection('shops')
        .doc(shopUid)
        .collection('shop_purchases')
        .count()
        .get()
        .then((value) {
      count = value.count ?? 0;
    });
    return count;
  }

  Future<List<ShopModel>> listAllShops({required String placeUid}) async {
    List<ShopModel> list = [];
    await _db
        .collection('shops')
        .where('placeUid', isEqualTo: placeUid)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        list.add(ShopModel.fromJson(doc.data(), doc.id));
      }
    });
    return list;
  }

  Future<String> fetchShopQrCode({required String shopUid}) async {
    String code = '';
    await _db
        .collection('shops')
        .doc(shopUid)
        .collection('qr_code')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        code = value.docs.first.id;
      }
    });
    return code;
  }

  Future<bool> addShopQrCode({
    required String shopUid,
    required String variable,
  }) async {
    bool exist = false;
    await _db.collection('shops').doc(shopUid).collection('qr_code').add({
      'qr_code_type': QRType.st1.name,
      "variable": variable,
      'timestamp': DateTime.now(),
    });
    return exist;
  }
}
