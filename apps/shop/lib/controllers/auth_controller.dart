import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/api/firestore_services.dart';
import 'package:mawaroute_shop/models/place_model.dart';
import 'package:mawaroute_shop/models/shop_model.dart';

import '../models/google_map_model.dart';
import '../utils/enums.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find<AuthController>();
  final _auth = FirebaseAuth.instance;
  final api = FireStoreService();
  FirebaseFunctions cloudFunction = FirebaseFunctions.instance;
  static const _successSignInUrl = '/';
  static const _successSignOutUrl = '/_auth';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final placeUidController = TextEditingController();
  final place = emptyPlaceModel.obs;
  final shop = emptyShopModel.obs;

  final placeController = TextEditingController().obs;

  RxList<GoogleMap> places = <GoogleMap>[].obs;
  RxInt selectedIndex = (-1).obs;

  Future<List<GoogleMap>> _searchPlace(String text) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('SearchPlace');
    final resp = await callable.call(<String, dynamic>{'text': text});
    List<GoogleMap> maps = [];
    for (var item in resp.data) {
      GoogleMap map = GoogleMap.fromJson(Map<String, dynamic>.from(item));
      maps.add(map);
    }
    return maps;
  }

  Future callPlaceApi(dynamic place) async {
    try {
      EasyLoading.show(status: 'Searching...'.tr);
      List<GoogleMap> res = await _searchPlace(place);
      places.value = res;
      selectedIndex.value = -1;
    } catch (e) {
      EasyLoading.showError('Something went wrong!'.tr);
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> onBoard() async {
    ShopModel shop = ShopModel(
      name: '',
      placeName: '',
      placeUid: placeUidController.text,
      homepageLink: '',
      address: '',
      description: '',
      userDescription: '',
      creditBalance: 0,
      status: ShopStatusType.onBoarded.name,
      createdAt: DateTime.now(),
      lat: 0,
      lng: 0,
      geoHash: "0",
      tags: [],
      managerUid: _auth.currentUser!.uid,
      isLive: false,
    );
    await api.addShop(shopInfo: shop.toJson());
  }

  Future<void> signIn() async {
    if (!emailController.text.isEmail ||
        passwordController.text.isEmpty ||
        placeUidController.text.isEmpty) {
      EasyLoading.showError(
          'Please enter valid email, password and place ID'.tr);
      return;
    }
    try {
      EasyLoading.show(status: 'Signing in...'.tr);
      await _auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      bool userExists = await api.fetchPlaceShopByEmail(
          placeUid: placeUidController.text, email: _auth.currentUser!.email!);
      if (!userExists) {
        throw FirebaseAuthException(
            message: 'Please enter valid placeUid!'.tr, code: '404');
      }
      bool isRegistered =
          await api.isShopRegistered(managerUid: _auth.currentUser!.uid);
      if (isRegistered == true) {
        EasyLoading.showSuccess('Welcome back!'.tr);
      } else {
        await onBoard();
      }
      Get.offAllNamed(_successSignInUrl);
    } on FirebaseAuthException catch (e) {
      _auth.signOut();
      EasyLoading.showError(
          '${'Invalid credentials!'.tr}\n ${e.message.toString()}');
    } catch (e) {
      debugPrint("$e");
      _auth.signOut();
      EasyLoading.showError('Something went wrong!'.tr);
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> fetchShop() async {
    String managerUid = _auth.currentUser!.uid;
    shop.value = await api.fetchShop(managerUid: managerUid);
  }

  Future<void> fetchPlace() async {
    place.value = await api.fetchPlace(shop.value.placeUid);
  }

  Future<void> initMyAccount() async {
    await fetchCurrentUserProfile();
    await fetchShop();
    await fetchPlace();
  }

  Future updateHomepageLink({
    required String fieldValue,
  }) async {
    await updateShopInfo({'homepageLink': fieldValue});
    await fetchShop();
  }

  Future updatePurchaseTokenReward({
    required int fieldValue,
  }) async {
    try {
      EasyLoading.show(status: 'Saving...'.tr);
      await updateShopInfo({'purchaseTokenReward': fieldValue});
      await fetchShop();
    } catch (e) {
      debugPrint("$e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future updateShopInfoGps({
    required GoogleMap place,
  }) async {
    HttpsCallable descriptionToTags =
        cloudFunction.httpsCallable('OpenAIApiDescriptionToTags');
    List<String> tags = [];
    try {
      String geoHash = await getGeoHash(lat: place.lat, lng: place.lng);
      String description = await getMostViewedReviewsToDescription(
          placeId: place.placeId, placeName: place.name);
      final result = await descriptionToTags
          .call({"description": "$description\n${shop.value.userDescription}"});
      tags = result.data.map<String>((e) => e.toString()).toList();
      String status = shop.value.status;
      if (shop.value.downloadUrl != "") {
        status = ShopStatusType.published.name;
      }
      await updateShopInfo({
        'name': place.name,
        'address': place.formattedAddress,
        '_geoloc': {
          'lat': place.lat,
          'lng': place.lng,
        },
        'geoHash': geoHash,
        'description': description,
        'tags': tags,
        'status': status
      });
      await fetchShop();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future getGeoHash({
    required double lat,
    required double lng,
  }) async {
    HttpsCallable latLngToGeoHash = cloudFunction.httpsCallable("GeoHash");
    String geoHash = "";
    try {
      final result = await latLngToGeoHash.call({"lat": lat, "lng": lng});
      geoHash = result.data["hash"];
    } on FirebaseFunctionsException catch (e) {
      debugPrint("$e");
    } catch (e) {
      debugPrint("$e");
    }
    return geoHash;
  }

  Future getMostViewedReviewsToDescription({
    required String placeId,
    required String placeName,
  }) async {
    HttpsCallable getReviewsToDescription =
        cloudFunction.httpsCallable("GetReviewsToDescription");
    HttpsCallable descriptionFromName =
        cloudFunction.httpsCallable('OpenAIFindDescriptionFromName');

    String description = "";
    try {
      final result1 = await descriptionFromName.call({"shopName": placeName});
      description = result1.data;
      final result2 = await getReviewsToDescription.call({"placeId": placeId});
      description += result2.data;
    } on FirebaseFunctionsException catch (e) {
      debugPrint("$e");
    } catch (e) {
      debugPrint("$e");
    }
    return description;
  }

  Future updateUserDescription({required String description}) async {
    HttpsCallable descriptionToTags =
        cloudFunction.httpsCallable('OpenAIApiDescriptionToTags');
    List<String> tags = [];
    try {
      final result = await descriptionToTags
          .call({"description": "${shop.value.description}\n$description"});
      tags = result.data.map<String>((e) => e.toString()).toList();
      await updateShopInfo({
        'userDescription': description,
        'tags': tags,
      });
      await fetchShop();
    } on FirebaseFunctionsException catch (e) {
      debugPrint("$e");
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future updateShopSpotImage(
      {required String imageLink, required String downloadUrl}) async {
    String status = shop.value.status;
    if (shop.value.description != "") {
      status = ShopStatusType.published.name;
    }
    await updateShopInfo({
      "imageLink": imageLink,
      "downloadUrl": downloadUrl,
      "status": status,
    });
    await fetchShop();
  }

  Future updateShopInfo(Map<String, dynamic> shopInfo) async {
    String shopUid = shop.value.uid!;
    await api.updateShop(shopUid: shopUid, shopInfo: shopInfo);
  }

  Future<void> fetchCurrentUserProfile() async {
    if (_auth.currentUser != null) {
      place.value = await api.fetchPlace(_auth.currentUser!.uid);
    }
  }

  Future signOut() async {
    await _auth.signOut();
    place.value = emptyPlaceModel;
    shop.value = emptyShopModel;
    Get.offAllNamed(_successSignOutUrl);
  }

  @override
  void dispose() {
    placeController.value.dispose();
    super.dispose();
  }
}
