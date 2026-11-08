import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaroute_business/models/mawaroute_news_model.dart';
import 'package:mawaroute_business/utility.dart';

void main() {
  group('utility', () {
    test('getFileSize formats bytes with binary units', () {
      expect(getFileSize(0), '0.0 B');
      expect(getFileSize(1024), '1.0 KB');
      expect(getFileSize(1536, decimals: 2), '1.50 KB');
      expect(getFileSize(5 * 1024 * 1024), '5.0 MB');
    });

    test('stringToInt and intToString handle empty values', () {
      expect(stringToInt(text: ''), isNull);
      expect(stringToInt(text: '42'), 42);
      expect(intToString(num: null), '');
      expect(intToString(num: 7), '7');
    });

    test('shouldUploadImage skips URLs and empty names', () {
      expect(shouldUploadImage('photo.png'), isTrue);
      expect(shouldUploadImage('https://example.com/photo.png'), isFalse);
      expect(shouldUploadImage(''), isFalse);
    });

    test('getParameterValue falls back to an empty string', () {
      expect(getParameterValue({'id': 'abc'}, 'id'), 'abc');
      expect(getParameterValue({'id': 'abc'}, 'missing'), '');
    });

    test('generateRandomString returns the requested length', () {
      expect(generateRandomString(12), hasLength(12));
    });
  });

  group('MawarouteNewsModel', () {
    test('round-trips through Firestore-shaped JSON', () {
      final timestamp = DateTime.utc(2023, 12, 1, 9, 30);
      final news = MawarouteNewsModel(
        body: 'Body',
        leadingIcon: 'info',
        link: 'https://example.com/news',
        title: 'Title',
        timestamp: timestamp,
      );

      final json = news.toJson();
      // Firestore hands timestamps back as Timestamp, not DateTime.
      json['timestamp'] = Timestamp.fromDate(json['timestamp'] as DateTime);
      final restored = MawarouteNewsModel.fromJson(json, 'news-1');

      expect(restored.uid, 'news-1');
      expect(restored.title, news.title);
      expect(restored.body, news.body);
      expect(restored.leadingIcon, news.leadingIcon);
      expect(restored.link, news.link);
      expect(restored.timestamp.toUtc(), timestamp);
    });
  });
}
