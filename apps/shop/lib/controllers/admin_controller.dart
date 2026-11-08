import "dart:io";

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mawaroute_shop/api/firestore_services.dart';
import 'package:mawaroute_shop/models/shop_model.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../models/google_map_model.dart';
import '../models/shop_image_model.dart';
import '../utils/compress_image_file.dart';
import '../utils/enums.dart';

class AdminController extends GetxController {
  static AdminController instance = Get.find<AdminController>();
  final api = FireStoreService();
  FirebaseFunctions cloudFunction = FirebaseFunctions.instance;
  final selectedImages = <AssetEntity>[].obs;

  final placeController = TextEditingController().obs;
  final emailController = TextEditingController().obs;

  RxList<GoogleMap> places = <GoogleMap>[].obs;
  GoogleMap? selectedPlace;
  RxInt selectedIndex = (-1).obs;

  void init() {
    clear();
  }

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

  Future createShop() async {
    if (emailController.value.text.isEmpty ||
        placeController.value.text.isEmpty ||
        selectedImages.isEmpty) {
      EasyLoading.showToast("Please fill up all the field.");
      return;
    }
    try {
      HttpsCallable callable = cloudFunction.httpsCallable('SendShopEmail');
      EasyLoading.show(status: 'Creating...'.tr);
      HttpsCallableResult<dynamic> resp = await callable.call(<String, dynamic>{
        'email': emailController.value.text,
        'placeId': placeController.value.text,
      });

      bool userExists = await api.fetchPlaceShopByEmail(
          placeUid: placeController.value.text,
          email: emailController.value.text);
      if (!userExists) {
        throw FirebaseAuthException(
            message: 'Please enter valid placeUid!'.tr, code: '404');
      }
      String managerUid = resp.data;
      bool isRegistered = await api.isShopRegistered(managerUid: managerUid);
      if (isRegistered == true) {
        EasyLoading.showSuccess('Welcome back!'.tr);
      } else {
        String shopUid = await upload(managerUid);
        await updateShopInfoGps(place: selectedPlace!, shopUid: shopUid);
        clear();
        EasyLoading.showSuccess("Successfully created the shop");
      }
    } catch (e) {
      debugPrint("$e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<String> upload(String managerUid) async {
    String shopUid = "";
    try {
      ShopModel shopModel = ShopModel(
        name: '',
        placeName: '',
        placeUid: placeController.value.text,
        homepageLink: '',
        downloadUrl: '',
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
        managerUid: managerUid,
        isLive: false,
      );
      DocumentReference<Map<String, dynamic>> newShop = await FirebaseFirestore
          .instance
          .collection('shops')
          .add(shopModel.toJson());
      shopUid = newShop.id;
      List<Map<String, dynamic>> shopImages = [];
      File? image = await selectedImages[0].file;
      File compressedImage = await compressImageFile(image!);
      final ref = FirebaseStorage.instance.ref(
          "v1-media/shop_campaign_tasks/$shopUid/${DateTime.now().toString()}.jpg");
      await ref.putFile(compressedImage).timeout(const Duration(seconds: 10));
      String downloadUrl = await ref.getDownloadURL();
      String imageLink = ref.fullPath;

      shopImages.add(
        ShopImageModel(
          imageLink: imageLink,
          downloadUrl: downloadUrl,
          shopUid: shopUid,
          index: 0,
          createdAt: DateTime.now(),
        ).toJson(),
      );
      await api.addShopImages(shopUid: shopUid, shopImages: shopImages);

      String status = ShopStatusType.onBoarded.name;
      await FirebaseFirestore.instance.collection('shops').doc(shopUid).update({
        "imageLink": imageLink,
        "downloadUrl": downloadUrl,
        "status": status,
      });
    } catch (e) {
      debugPrint("$e");
    }
    return shopUid;
  }

  Future updateShopInfoGps({
    required GoogleMap place,
    required String shopUid,
  }) async {
    HttpsCallable descriptionToTags =
        cloudFunction.httpsCallable('OpenAIApiDescriptionToTags');
    List<String> tags = [];
    String userDescription = "";
    try {
      String geoHash = await getGeoHash(lat: place.lat, lng: place.lng);
      String description = await getMostViewedReviewsToDescription(
          placeId: place.placeId, placeName: place.name);
      List<String> translatedText =
          await getTranslation(["$description\n$userDescription"]);
      String translatedDescription = translatedText[0];
      final result =
          await descriptionToTags.call({"description": translatedDescription});
      tags = result.data.map<String>((e) => e.toString()).toList();
      String status = ShopStatusType.onBoarded.name;
      List<String> translatedTags = await getTranslation(tags);
      await updateShopInfo({
        'name': place.name,
        'address': place.formattedAddress,
        '_geoloc': {
          'lat': place.lat,
          'lng': place.lng,
        },
        'geoHash': geoHash,
        'description': description,
        'translatedDescription': translatedDescription,
        'tags': tags,
        'translatedTags': translatedTags,
        'status': status
      }, shopUid);
    } catch (e, stackTrace) {
      debugPrint('Exception occurred: $e');
      debugPrint('StackTrace: $stackTrace');

      final lines = stackTrace.toString().split('\n');
      if (lines.isNotEmpty) {
        final line = lines[0];
        final lineNumber = line.substring(line.lastIndexOf(':') + 1);
        debugPrint('Line number: $lineNumber');
      }
    }
  }

  Future updateShopInfo(Map<String, dynamic> shopInfo, shopUid) async {
    await api.updateShop(shopUid: shopUid, shopInfo: shopInfo);
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

  Future<List<String>> getTranslation(List<String> text) async {
    HttpsCallable translateToEnglish =
        cloudFunction.httpsCallable('TranslateToEnglish');
    final result = await translateToEnglish.call({"text": text});
    return result.data.map<String>((e) => e.toString()).toList();
  }

  void clear() {
    emailController.value.text = "";
    placeController.value.text = "";
    selectedIndex.value = -1;
    selectedPlace = null;
    selectedImages.value = [];
  }

  @override
  void dispose() {
    emailController.value.dispose();
    placeController.value.dispose();
    super.dispose();
  }
}
