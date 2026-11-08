import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<dynamic, dynamic>> paginatedResults({
  required Query query,
  DocumentSnapshot? snapshot,
  int limit = 50,
}) async {
  Map output = {"snapshot": snapshot, "results": []};
  if (snapshot != null) {
    query = query.startAfterDocument(snapshot);
  }
  await query.limit(limit).get().then((value) {
    output["results"] = value.docs;
    output["snapshot"] = value.docs.isNotEmpty ? value.docs.last : null;
  });

  return output;
}
