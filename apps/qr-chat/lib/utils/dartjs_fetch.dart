import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/chat_completion_message_model.dart';

/// `fetchStream` is defined in `web/custom_scripts.js`. It POSTs to [url] and
/// calls [callback] with each decoded chunk, or with `[ERROR]` on failure.
@JS('fetchStream')
external void _fetchStream(
  JSString url,
  JSString method,
  JSAny? headers,
  JSString body,
  JSFunction callback,
);

/// Streams the content tokens of a chat completion from
/// [AppConfig.chatStreamUrl].
Stream jsChatStream(List<ChatCompletionMessageModel> messages) {
  final headers = <String, String>{
    'accept': 'text/event-stream',
    'Content-Type': 'application/json',
  }.jsify();
  final body = jsonEncode({'messages': messages});
  final streamController = StreamController<String>();
  _fetchStream(
    AppConfig.chatStreamUrl.toJS,
    'POST'.toJS,
    headers,
    body.toJS,
    ((JSString chunk) {
      final data = chunk.toDart;
      if (data == '[ERROR]') {
        streamController.addError('Error');
      } else {
        parseResponse(data, streamController);
      }
    }).toJS,
  );
  return streamController.stream;
}

void parseResponse(String jsonString, StreamController sc) {
  List<String> lines = jsonString.trim().split('data:');
  for (var line in lines) {
    if (line.trim().isEmpty) {
      continue;
    }
    if (line.trim() == '[DONE]') {
      sc.close();
      break;
    }
    try {
      Map<String, dynamic> jsonResponse = jsonDecode(line);
      String content = jsonResponse['choices'][0]['delta']['content'] ?? '';
      sc.add(content);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing line: $line\nError: $e');
      }
    }
  }
}
