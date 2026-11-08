import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/utilis/pagination.dart';

import '../models/mawaroute_news_model.dart';

class NotificationController extends GetxController {
  static NotificationController instance = Get.find<NotificationController>();

  final _db = FirebaseFirestore.instance;
  Rx<Pagination<MawarouteNewsModel>> mawarouteNews =
      Pagination<MawarouteNewsModel>(query: null, fromJson: null).obs;

  Future<void> init() async {
    mawarouteNews.value = Pagination<MawarouteNewsModel>(
      fromJson: (json, id) => MawarouteNewsModel.fromJson(json, id),
      query: _db
          .collection("mawaroute_news")
          .orderBy("timestamp", descending: true),
    );
    await listMawarouteNews();
  }

  Future listMawarouteNews() async {
    await mawarouteNews.value.fetch();
    mawarouteNews.refresh();
  }
}
