import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mawaroute_qr_chat/api/api.dart';
import 'package:mawaroute_qr_chat/models/chat_completion_message_model.dart';
import 'package:mawaroute_qr_chat/models/link_preview_model.dart';
import 'package:mawaroute_qr_chat/models/text_bubble_el.dart';

void main() {
  test('chat messages encode as OpenAI chat messages', () {
    final body = jsonEncode({
      'messages': [ChatCompletionMessageModel(content: 'hi', role: 'user')],
    });
    expect(body, '{"messages":[{"role":"user","content":"hi"}]}');
  });

  test('TextBubbleEl.fromCloudFunction maps a FetchWeaviateRecItems item', () {
    final el = TextBubbleEl.fromCloudFunction({
      'id': 'rec-1',
      'title': 'Matcha set',
      'description': 'Seasonal sweets',
      'link': 'https://example.com/matcha',
      'price': 800,
    });
    expect(el.type, RecChatElementType.recItem.name);
    expect(el.messageOfAvatar, isTrue);
    expect(el.recUid, 'rec-1');
    expect(el.toJson()['recLink'], 'https://example.com/matcha');
    expect(el.toJson()['price'], 800);
  });

  test('LinkPreviewModel resolves relative image URLs', () {
    final preview = LinkPreviewModel.fromJson({
      'title': 'Shop',
      'image': '/img/og.png',
    }, 'https://example.com');
    expect(preview.image, 'https://example.com/img/og.png');
    expect(preview.description, '');
  });

  group('text helpers', () {
    test('formatInputString strips quotes and newlines', () {
      expect(formatInputString('"a"\nb'), 'ab');
    });

    // Keeps the text up to the second-to-last line break (the closing question
    // after a blank line in a typical reply).
    test('extractAllButLastParagraph drops the closing paragraph', () {
      expect(
        extractAllButLastParagraph('Intro\nItem one\n\nAnything else?'),
        'IntroItem one',
      );
      expect(extractAllButLastParagraph('single line'), 'single line');
    });

    test('filterValidUrls drops unparsable URLs', () {
      expect(filterValidUrls(['https://example.com', 'http://[::1']), [
        'https://example.com',
      ]);
    });
  });
}
