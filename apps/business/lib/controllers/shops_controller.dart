import 'dart:async';
import 'dart:convert';
import 'package:web/web.dart' as web;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../api/google_firestore_services.dart';
import '../api/shop_service.dart';
import '../enums.dart';
import '../models/place_model.dart';
import '../models/place_shop_user_model.dart';
import '../models/shop_model.dart';
import '../pagination.dart';
import '../utility.dart';

class ShopsScreenController extends GetxController {
  static ShopsScreenController instance = Get.find<ShopsScreenController>();
  FireStoreService api = FireStoreService();
  ShopService shopServiceApi = ShopService();
  final _db = FirebaseFirestore.instance;
  RxString placeUid = ''.obs;
  // For shops
  Rx<Pagination<ShopModel>> shops =
      Pagination<ShopModel>(fromJson: null, query: null).obs;

  // For paid shops
  Rx<Pagination<ShopModel>> paidShops =
      Pagination<ShopModel>(fromJson: null, query: null).obs;

  // For users
  Rx<Pagination<PlaceShopUserModel>> users =
      Pagination<PlaceShopUserModel>(fromJson: null, query: null).obs;
  RxString shopEmail = "".obs;
  // "onboarded" or "invitation_sent" or "paid"
  RxString selectedTab = "onboarded".obs;

  // Shop info
  final RxInt audienceSize = 1200.obs;
  final RxInt credits = 1000.obs;
  final RxInt shopVisitsCountByDay = 0.obs;
  final RxInt shopPurchasesCountByDay = 0.obs;
  final RxInt shopVisitsCountByMonth = 0.obs;
  final RxInt shopPurchasesCountByMonth = 0.obs;
  final RxInt totalShopVisitsCount = 0.obs;
  final RxInt shopPurchasesCountTotal = 0.obs;

  final isLoading = false.obs;
  final qrSize = 320.0;
  final RxBool doesShopQrCodeExist = false.obs;

  final qrCodeData = ''.obs;

  Future<void> init() async {
    placeUid.value = '';
    shopEmail.value = "";
    selectedTab.value = "onboarded";
    await fetchPlace();
    clearShops();
    clearShopUsers();
    clearPaidShops();
    await fetchData();
  }

  Future fetchData() async {
    if (placeUid.value != '') {
      if (selectedTab.value == "onboarded") {
        clearShops();
        await listShops();
      } else if (selectedTab.value == "invitation_sent") {
        clearShopUsers();
        await listShopUsers();
      } else {
        clearPaidShops();
        await listPaidShops();
      }
    }
  }

  void clearShopUsers() {
    users.value = Pagination<PlaceShopUserModel>(
      fromJson: (json, id) => PlaceShopUserModel.fromJson(json, id),
      query: _db
          .collection('places')
          .doc(placeUid.value)
          .collection('place_shops')
          .orderBy('timestamp', descending: true),
    );
  }

  void clearShops() {
    shops.value = Pagination<ShopModel>(
      fromJson: (json, id) => ShopModel.fromJson(json, id),
      query: _db
          .collection('shops')
          .where('placeUid', isEqualTo: placeUid.value)
          .orderBy('createdAt', descending: true),
    );
  }

  void clearPaidShops() {
    paidShops.value = Pagination<ShopModel>(
      fromJson: (json, id) => ShopModel.fromJson(json, id),
      query: _db
          .collection('shops')
          .where('placeUid', isEqualTo: placeUid.value)
          .where('creditBalance', isGreaterThan: 0)
          .orderBy('creditBalance', descending: true),
    );
  }

  Future fetchPlace() async {
    try {
      PlaceModel place = await api.fetchPlace();
      placeUid.value = place.uid!;
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future listShops() async {
    await shops.value.fetch();
    shops.refresh();
  }

  Future listPaidShops() async {
    await paidShops.value.fetch();
    paidShops.refresh();
  }

  Future listShopUsers() async {
    await users.value.fetch();
    users.refresh();
  }

  Future sendShopEmail({required String email}) async {
    FirebaseFunctions functions = FirebaseFunctions.instance;
    HttpsCallable callable = functions.httpsCallable('SendShopEmail');
    try {
      showLoading('Sending...'.tr);
      await callable.call(<String, dynamic>{
        'email': email,
        'placeId': placeUid.value,
      });
    } catch (e) {
      if (kDebugMode) print(e);
      showError('$e');
    } finally {
      showDismiss();
    }
  }

  Future fetchShopVisitsCountByDay({required String shopUid}) async {
    try {
      shopVisitsCountByDay.value =
          await api.shopVisitsCountByDay(shopUid: shopUid);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future fetchShopVisitsCountByMonth({required String shopUid}) async {
    try {
      shopVisitsCountByMonth.value =
          await api.shopVisitsCountByMonth(shopUid: shopUid);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future fetchShopVisitsCountTotal({required String shopUid}) async {
    try {
      totalShopVisitsCount.value =
          await api.shopVisitsCountTotal(shopUid: shopUid);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future fetchShopPurchasesCountByDay({required String shopUid}) async {
    try {
      shopPurchasesCountByDay.value =
          await api.shopPurchasesCountByDay(shopUid: shopUid);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future fetchShopPurchasesCountByMonth({required String shopUid}) async {
    try {
      shopPurchasesCountByMonth.value =
          await api.shopPurchasesCountByMonth(shopUid: shopUid);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future fetchShopPurchasesCountTotal({required String shopUid}) async {
    try {
      shopPurchasesCountTotal.value =
          await api.shopPurchasesCountTotal(shopUid: shopUid);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future fetchShopCountData({required String shopUid}) async {
    if (shopUid != '') {
      shopVisitsCountByDay.value = 0;
      shopPurchasesCountByDay.value = 0;
      shopVisitsCountByMonth.value = 0;
      shopPurchasesCountByMonth.value = 0;
      totalShopVisitsCount.value = 0;
      shopPurchasesCountTotal.value = 0;
      await fetchShopVisitsCountByDay(shopUid: shopUid);
      await fetchShopPurchasesCountByDay(shopUid: shopUid);
      await fetchShopVisitsCountByMonth(shopUid: shopUid);
      await fetchShopPurchasesCountByMonth(shopUid: shopUid);
      await fetchShopVisitsCountTotal(shopUid: shopUid);
      await fetchShopPurchasesCountTotal(shopUid: shopUid);
      await fetchShopQrCode(shopUid: shopUid);
    }
  }

  Future<Uint8List> addPaddingToImage(
    Uint8List qrCodeImage,
    double qrCodeWidth,
    double qrCodeHeight,
    double desiredPadding,
  ) async {
    final width = qrCodeWidth + (desiredPadding * 2);
    final height = qrCodeHeight + (desiredPadding * 2);

    final ui.Codec codec = await ui.instantiateImageCodec(qrCodeImage);
    final ui.Image image = (await codec.getNextFrame()).image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    canvas.drawImage(image, Offset(desiredPadding, desiredPadding), paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());

    final ByteData? byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future downloadQrCode({required String shopName}) async {
    final qrImageData = await QrPainter(
      data: qrCodeData.value,
      version: QrVersions.auto,
      gapless: false,
    ).toImageData(qrSize, format: ui.ImageByteFormat.png);
    final pngBytes = qrImageData!.buffer.asUint8List();
    const desiredPadding = 16.0;
    final qrCodeWithPadding = await addPaddingToImage(
      pngBytes,
      qrSize,
      qrSize,
      desiredPadding,
    );
    web.HTMLAnchorElement()
      ..href =
          'data:application/octet-stream;base64,${base64.encode(qrCodeWithPadding)}'
      ..setAttribute("download", "qr_$shopName.png")
      ..click();
  }

  Future<void> fetchShopQrCode({required String shopUid}) async {
    bool exist = false;
    String code = '';
    try {
      code = await shopServiceApi.fetchShopQrCode(shopUid: shopUid);
      if (code.isNotEmpty) {
        exist = true;
        qrCodeData.value = QRType.st1.name + reverseString(code);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
    doesShopQrCodeExist.value = exist;
  }

  Future<void> addShopQrCode({required String shopUid}) async {
    String variable = generateRandomString(6);
    try {
      await shopServiceApi.addShopQrCode(
        shopUid: shopUid,
        variable: variable,
      );
      await fetchShopQrCode(shopUid: shopUid);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}
