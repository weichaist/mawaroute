import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Pagination<T> {
  List<T> results = <T>[];
  DocumentSnapshot? snapshot;
  bool isLast = false;

  int limit = 0;
  Query? query;
  final T Function(Map<String, dynamic>, String)? fromJson;
  bool isLoading = false;

  Pagination({required this.query, required this.fromJson, this.limit = 15}) {
    clear();
  }

  Future<void> fetch() async {
    if (isLoading == true ||
        query == null ||
        fromJson == null ||
        isLast == true) {
      return;
    }
    List<T> tResults = [];
    try {
      isLoading = true;
      if (snapshot != null) {
        query = query!.startAfterDocument(snapshot!);
      }
      await query!.limit(limit).get().then((snap) {
        for (DocumentSnapshot doc in snap.docs) {
          tResults.add(fromJson!(doc.data() as Map<String, dynamic>, doc.id));
        }
        snapshot = snap.docs.isNotEmpty ? snap.docs.last : null;
      });
      tResults = tResults.map<T>((e) => e).toList();
      isLast = tResults.length < limit;
      results += tResults;
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      isLoading = false;
    }
  }

  void clear() {
    results.clear();
    snapshot = null;
    isLast = false;
    isLoading = false;
  }
}
