import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawaroute_business/utility.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../models/mawaroute_news_model.dart';
import '../pagination.dart';

class NewsController extends GetxController {
  static NewsController instance = Get.find<NewsController>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rx<Pagination<MawarouteNewsModel>> news =
      Pagination<MawarouteNewsModel>(fromJson: null, query: null).obs;

  String newsUid = "";
  MawarouteNewsModel newsToEdit = emptyNews;
  final FormGroup newsForm = FormGroup({
    'title': FormControl<String>(validators: [
      Validators.required,
      Validators.maxLength(30),
    ]),
    'body': FormControl<String>(validators: [
      Validators.required,
      Validators.maxLength(90),
    ]),
    'link': FormControl<String>(validators: [
      Validators.required,
      Validators.maxLength(255),
    ]),
    'leadingIcon': FormControl<String>(validators: [
      Validators.required,
      Validators.maxLength(1),
    ]),
  });
  RxBool isLoading = false.obs;
  RxBool isEdit = false.obs;

  Future<void> init() async {
    news.value = Pagination<MawarouteNewsModel>(
      fromJson: (json, id) => MawarouteNewsModel.fromJson(json, id),
      query: _db
          .collection("mawaroute_news")
          .orderBy('timestamp', descending: true),
    );
    await fetchNews();
  }

  Future<void> initUpdate() async {
    clear();
    try {
      newsUid = getParameterValue(Get.parameters, "newsId");
      if (newsUid != "") {
        isEdit.value = true;
        await fetchNewsByUid(uid: newsUid);
        newsForm.patchValue({
          'title': newsToEdit.title,
          'body': newsToEdit.body,
          'link': newsToEdit.link,
          'leadingIcon': newsToEdit.leadingIcon,
        });
      } else {
        isEdit.value = false;
      }
    } catch (e) {
      showToast("Invalid News".tr);
    }
  }

  Future<void> fetchNews() async {
    await news.value.fetch();
    news.refresh();
  }

  Future<void> fetchNewsByUid({required String uid}) async {
    newsToEdit = emptyNews;
    try {
      showLoading("Loading...".tr);
      await _db.collection("mawaroute_news").doc(uid).get().then((snap) => {
            if (snap.exists)
              {
                newsToEdit = MawarouteNewsModel.fromJson(
                  snap.data()!,
                  snap.id,
                )
              }
          });
    } catch (e) {
      showError("Could not fetch news".tr);
    } finally {
      showDismiss();
    }
  }

  void clear() {
    newsForm.reset();
    isEdit.value = false;
  }

  Future<void> onSave() async {
    try {
      if (!newsForm.valid) throw CustomException("All fields are required".tr);
      if (!newsForm.dirty) throw CustomException("No changes made".tr);
      showLoading("Saving...".tr);
      MawarouteNewsModel news = MawarouteNewsModel(
        body: newsForm.control("body").value,
        leadingIcon: newsForm.control("leadingIcon").value,
        link: newsForm.control("link").value,
        title: newsForm.control("title").value,
        timestamp: DateTime.now(),
      );
      Map<String, dynamic> obj = news.toJson();
      if (isEdit.isTrue) {
        obj.remove("timestamp");
        await _db.collection("mawaroute_news").doc(newsUid).update(obj);
      } else {
        await _db.collection("mawaroute_news").add(obj);
        clear();
      }
    } on CustomException catch (e) {
      showError(e.message);
    } catch (e) {
      showError("Could not create news".tr);
    } finally {
      showDismiss();
    }
  }

  Future<void> deleteNews() async {
    try {
      showLoading("Deleting...".tr);
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'DeleteNews',
      );
      final res = await callable.call(<String, dynamic>{
        'newsId': newsUid,
      });
      if (res.data == "200") {
        showSuccess("News deleted successfully".tr);
        Get.toNamed("/news");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showError("Could not delete news".tr);
    } finally {
      showDismiss();
    }
  }
}
