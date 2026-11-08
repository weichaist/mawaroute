import 'package:flutter_test/flutter_test.dart';
import 'package:mawaroute_visitor/api/rec_chat_api.dart';
import 'package:mawaroute_visitor/models/rec_text_bubble_el.dart';
import 'package:mawaroute_visitor/utilis/formatter.dart';
import 'package:mawaroute_visitor/utilis/image_matching.dart';
import 'package:mawaroute_visitor/utilis/invitation_message.dart';

void main() {
  group('formatter', () {
    test('convertNumber shortens thousands and millions', () {
      expect(convertNumber(999), '999');
      expect(convertNumber(1500), '1.5k');
      expect(convertNumber(2300000), '2.3m');
    });

    test('convertTimeToInt turns HH:mm into an integer', () {
      expect(convertTimeToInt('09:30'), 930);
      expect(convertTimeToInt('23:05'), 2305);
    });

    test('getStorageLocationFromUrl keeps the v1-media path', () {
      expect(
        getStorageLocationFromUrl(
          'https://example.com/v0/b/bucket/o/v1-media/profile/img.png',
        ),
        'v1-media/profile/img.png',
      );
      expect(getStorageLocationFromUrl('https://example.com/other.png'), '');
    });
  });

  group('rec chat text helpers', () {
    test('formatInputString strips quotes and newlines', () {
      expect(formatInputString('"hello"\nworld'), 'helloworld');
    });

    test('extractPlaceId reads the place_id parameter', () {
      expect(
        extractPlaceId('https://maps.example.com/?q=place_id:abc123&x=1'),
        'abc123',
      );
    });
  });

  test('TextBubbleEl.fromWeaviate maps a recommendation', () {
    final el = TextBubbleEl.fromWeaviate({
      'title': 'Coffee stand',
      'link': 'https://example.com/coffee',
      'description': 'Hand-drip coffee',
      'price': 500,
      'geo': {'latitude': 34.39, 'longitude': 132.45},
      'imageUrl': null,
      '_additional': {'id': 'rec-1'},
    });
    expect(el.type, 'recItem');
    expect(el.recUid, 'rec-1');
    expect(el.geo!.latitude, 34.39);
    final json = el.toJson();
    expect(json['message'], 'Coffee stand');
    expect(json['recLink'], 'https://example.com/coffee');
    expect(json['messageOfAvatar'], true);
  });

  group('image matching score', () {
    test('identical labels without text score 0.8', () async {
      final annotation = {
        'labelAnnotations': [
          {'description': 'Building', 'score': 0.9},
          {'description': 'Sky', 'score': 0.8},
        ],
      };
      expect(
        await getSimilarityScore(annotation, annotation),
        closeTo(0.8, 1e-9),
      );
    });

    test('nothing in common scores 0', () async {
      expect(
        await getSimilarityScore(
          {
            'labelAnnotations': [
              {'description': 'Cat', 'score': 0.9},
            ],
          },
          {
            'labelAnnotations': [
              {'description': 'Car', 'score': 0.9},
            ],
          },
        ),
        0,
      );
    });
  });

  group('invitationMessage', () {
    test('includes the code and the guide link when configured', () {
      final text = invitationMessage('ABC123', guideUrl: 'https://example.com');
      expect(text, contains('ABC123'));
      expect(text, endsWith('https://example.com'));
    });

    test('omits the guide line without a link', () {
      final text = invitationMessage('ABC123', guideUrl: '');
      expect(text, endsWith('ABC123'));
    });
  });
}
