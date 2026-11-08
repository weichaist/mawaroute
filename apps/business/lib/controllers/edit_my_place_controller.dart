import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/google_firestore_services.dart';
import '../api/shop_service.dart';
import '../models/google_map_model.dart';
import '../models/place_model.dart';
import '../utility.dart';

class EditMyPlaceController extends GetxController {
  static EditMyPlaceController instance = Get.find<EditMyPlaceController>();
  late final imageFile = PlatformFile(name: '', size: 0).obs;
  late final userProfileImageFile = PlatformFile(name: '', size: 0).obs;
  Rx<PlaceModel> place = emptyPlaceModel.obs;
  Rx<TextEditingController> name = TextEditingController().obs;
  Rx<TextEditingController> address = TextEditingController().obs;
  Rx<TextEditingController> lng = TextEditingController().obs;
  Rx<TextEditingController> lat = TextEditingController().obs;
  // For google map
  RxList<GoogleMap> places = <GoogleMap>[].obs;
  RxInt selectedIndex = (-1).obs;

  FireStoreService api = FireStoreService();
  ShopService shopApi = ShopService();
  FirebaseFunctions cloudFunction = FirebaseFunctions.instance;

  Future<void> init() async {
    clear();
    place.value = await api.fetchPlace();
    if (place.value.uid!.isNotEmpty) {
      if (place.value.downloadUrl != "") {
        imageFile.value = PlatformFile(name: place.value.downloadUrl, size: 1);
      }
      if (place.value.profileUrl != "") {
        userProfileImageFile.value =
            PlatformFile(name: place.value.profileUrl, size: 1);
      }
      name.value.text = place.value.name;
      address.value.text = place.value.address;
      lat.value.text = place.value.lat.toString();
      lng.value.text = place.value.lng.toString();
    }
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
      places.value = [];
      showLoading("Searching".tr);
      List<GoogleMap> res = await _searchPlace(place);
      places.value = res;
      selectedIndex.value = -1;
    } catch (e) {
      showError("エラーが発生しました");
    } finally {
      showDismiss();
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
      if (kDebugMode) print(e);
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return geoHash;
  }

  Future onCreate() async {
    if ((imageFile.value.size == 0) |
        (userProfileImageFile.value.size == 0) |
        name.value.text.isEmpty |
        address.value.text.isEmpty |
        lat.value.text.isEmpty |
        lng.value.text.isEmpty) {
      showError('Add image file and other info.'.tr);
      return;
    }
    if (isFile500KPlus(userProfileImageFile.value) ||
        isFile500KPlus(imageFile.value)) {
      showError('Image files size can not be more than 500K'.tr);
      return;
    }
    showLoading('Saving place info'.tr);
    List<String> links = [place.value.imageLink, place.value.downloadUrl];
    if (!imageFile.value.name.contains('https:')) {
      links = await uploadFile(file: imageFile.value);
      if (links.length != 2) {
        showDismiss();
        showError('Could not upload file.'.tr);
        return;
      }
    }
    List<String> profileLinks = ['', place.value.profileUrl];
    if (!userProfileImageFile.value.name.contains('https:')) {
      profileLinks = await uploadFile(file: userProfileImageFile.value);
      if (profileLinks.length != 2) {
        showDismiss();
        showError('Could not upload file.'.tr);
        return;
      }
    }
    try {
      double latTemp = double.parse(lat.value.text);
      double lngTemp = double.parse(lng.value.text);
      String geoHash = await getGeoHash(lat: latTemp, lng: lngTemp);
      PlaceModel placeModel = PlaceModel(
        name: name.value.text,
        address: address.value.text,
        lat: latTemp,
        lng: lngTemp,
        geoHash: geoHash,
        imageLink: links[0],
        downloadUrl: links[1],
        profileUrl: profileLinks[1],
      );
      await api.addPlace(placeModel.toJson());
      showDismiss();
      showSuccess('Successfully saved place.'.tr);
    } catch (e) {
      if (kDebugMode) print(e);
      showError('Failed to save place!.'.tr);
    }
  }

  void changeImage(PlatformFile? file) async {
    imageFile.value = file!;
    imageFile.update((value) {
      value = file;
    });
  }

  void changeUserProfileImage(PlatformFile? file) async {
    userProfileImageFile.value = file!;
    userProfileImageFile.update((value) {
      value = file;
    });
  }

  void clear() {
    name.value.clear();
    address.value.clear();
    lat.value.clear();
    lng.value.clear();
    imageFile.value = PlatformFile(name: '', size: 0);
    userProfileImageFile.value = PlatformFile(name: '', size: 0);
  }

  Future<List<String>> uploadFile({required PlatformFile file}) async {
    String url = '';
    String downloadUrl = '';
    try {
      final ref = FirebaseStorage.instance
          .ref('v1-media/places/${DateTime.now().toString()}.jpg');
      await ref.putData(file.bytes as Uint8List);
      downloadUrl = await ref.getDownloadURL();
      url = ref.fullPath;
      return [url, downloadUrl];
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    name.value.dispose();
    address.value.dispose();
    lat.value.dispose();
    lng.value.dispose();
    super.dispose();
  }
}
