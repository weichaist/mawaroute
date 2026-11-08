import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaroute_shop/models/user_visit_model.dart';
import 'package:mawaroute_shop/utils/date_formatter.dart';

void main() {
  test('UserVisitModel reads a shop_visits document', () {
    // Same fields the CreateVisitFromCompletedCampaign function writes.
    final visitTime = DateTime.utc(2023, 9, 1, 12, 0);
    final json = <String, dynamic>{
      'visitorUid': 'visitor-1',
      'campaignUid': 'campaign-1',
      'taskUid': 'task-1',
      'placeUid': 'place-1',
      'shopUid': 'shop-1',
      'visitTime': Timestamp.fromDate(visitTime),
      'visitorName': 'guest',
      'visitorProfile': '',
      'visitorTags': ['coffee', 42],
      'capturedImageUploadedUrl': 'https://example.com/visit.jpg',
    };

    final visit = UserVisitModel.fromJson(json, 'visit-1');

    expect(visit.uid, 'visit-1');
    expect(visit.visitorUid, 'visitor-1');
    expect(visit.shopUid, 'shop-1');
    expect(visit.visitTime.toUtc(), visitTime);
    expect(visit.visitorTags, ['coffee', '42']);
  });

  test('dateString uses the yyyy/MM/dd hh:mm format', () {
    expect(dateString(DateTime(2023, 9, 1, 9, 5)), '2023/09/01 09:05');
  });
}
