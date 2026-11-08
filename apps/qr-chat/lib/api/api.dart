import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/m_avatar.dart';

final _db = FirebaseFirestore.instance;
Future<MAvatarModel> fetchMAvatar(String avatarUid) async {
  try {
    var documentSnapshot = await _db
        .collection('m_avatars')
        .doc(avatarUid)
        .get();
    if (documentSnapshot.exists) {
      return MAvatarModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
        documentSnapshot.id,
      );
    } else {
      return emptyMAvatarModel;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    rethrow;
  }
}

enum RecChatElementType { loading, text, streamText, recItem, recReason }

Future<void> launchPlaceUrl(String uri) async {
  final Uri url = Uri.parse(uri);
  try {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  } catch (err) {
    SmartDialog.showNotify(
      msg: 'URL is not valid'.tr,
      notifyType: NotifyType.alert,
    );
    return;
  }
}

String formatInputString(String input) {
  String result = input.replaceAll('"', '');
  return result.replaceAll(RegExp(r'\r\n|\r|\n'), '');
}

String extractAllButLastParagraph(String fullText) {
  RegExp newlineRegExp = RegExp(r'\r\n|\r|\n');
  Iterable<RegExpMatch> matches = newlineRegExp.allMatches(fullText);

  if (matches.length > 1) {
    // If more than one paragraph, extract up to the start of the last paragraph
    int endIndexBeforeLast = matches.elementAt(matches.length - 2).end;
    return formatInputString(fullText.substring(0, endIndexBeforeLast));
  }
  // Return the whole text if there's only one paragraph or no newline characters
  return formatInputString(fullText);
}

List<String> filterValidUrls(List<String> urls) {
  // This function takes a list of URLs and returns a new list with only valid URLs.
  return urls.where((url) {
    try {
      // Try to parse the URL.
      Uri.parse(url);
      // If parsing is successful, URL is valid.
      return true;
    } catch (e) {
      // If parsing throws an error, URL is invalid.
      return false;
    }
  }).toList();
}
