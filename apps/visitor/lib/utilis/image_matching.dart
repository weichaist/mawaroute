import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzywuzzy;

import '../models/image_label.dart';

Future<Map<String, dynamic>> cloudAPIExtractTextDataFromImage({
  required String uri,
}) async {
  try {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      "AnnotateImageV2",
    );
    final resp = await callable.call(<String, dynamic>{"uri": uri});
    return resp.data;
  } catch (e) {
    if (kDebugMode) print(e);
    rethrow;
  }
}

Future<double> getSimilarityScore(
  Map targetAnnotation,
  Map userFileAnnotation,
) async {
  double similarityScore = 0.0;
  final targetFileTextData = targetAnnotation["fullTextAnnotation"];
  final userFileTextData = userFileAnnotation["fullTextAnnotation"];
  final resTargetFileLabels = targetAnnotation["labelAnnotations"] ?? [];
  final resUserFileLabels = userFileAnnotation["labelAnnotations"] ?? [];
  final resTargetFileObjects =
      targetAnnotation["localizedObjectAnnotations"] ?? [];
  final resUserFileObjects =
      userFileAnnotation["localizedObjectAnnotations"] ?? [];

  List<ImageLabel> targetFileLabels = [];
  List<ImageLabel> userFileLabels = [];
  List<ImageLabel> targetFileObjects = [];
  List<ImageLabel> userFileObjects = [];
  for (var targetFileLabel in resTargetFileLabels) {
    targetFileLabels.add(ImageLabel.fromJson(targetFileLabel));
  }
  for (var userFileLabel in resUserFileLabels) {
    userFileLabels.add(ImageLabel.fromJson(userFileLabel));
  }

  for (var resTargetFileObject in resTargetFileObjects) {
    targetFileObjects.add(
      ImageLabel(description: resTargetFileObject["name"], score: 0),
    );
  }

  for (var resUserFileObject in resUserFileObjects) {
    userFileObjects.add(
      ImageLabel(description: resUserFileObject["name"], score: 0),
    );
  }
  double labelScore = _calculateScoreWithLabels(
    userFileLabels,
    targetFileLabels,
  );
  double objectScore = _calculateScoreWithLabels(
    userFileObjects,
    targetFileObjects,
  );
  if (targetFileTextData == null || userFileTextData == null) {
    similarityScore = 0.8 * labelScore + 0.2 * objectScore;
  } else {
    double textScore = _calculateScoreWithTextRecognition(
      targetFileTextData,
      userFileTextData,
    );
    similarityScore = min(
      0.6 * textScore + 0.48 * labelScore + 0.12 * objectScore,
      1,
    );
  }
  return similarityScore;
}

double _calculateScoreWithLabels(
  List<ImageLabel> userLabels,
  List<ImageLabel> targetLabels,
) {
  int numberOfMatches = _countMatchingElements(userLabels, targetLabels);
  return targetLabels.isNotEmpty
      ? (min(numberOfMatches, targetLabels.length) / targetLabels.length)
      : 0;
}

int _countMatchingElements(List<ImageLabel> list1, List<ImageLabel> list2) {
  int count = 0;
  for (var element1 in list1) {
    for (var element2 in list2) {
      if (element1.description == element2.description) {
        count++;
      }
    }
  }
  return count;
}

double _calculateScoreWithTextRecognition(
  String userImageTextData,
  String targetImageTextData,
) {
  final weightedScore = fuzzywuzzy.weightedRatio(
    userImageTextData,
    targetImageTextData,
  );
  final partialScore = fuzzywuzzy.partialRatio(
    userImageTextData,
    targetImageTextData,
  );
  double stringSimilarity = 0.0;
  if (weightedScore < 51) {
    stringSimilarity = (weightedScore * 0.5 + partialScore * 0.5) / 2.4 / 100;
  } else {
    if (partialScore < 50) {
      stringSimilarity = (weightedScore * 0.24 + partialScore * 0.75) / 100;
    } else {
      stringSimilarity = (weightedScore * 0.48 + partialScore * 0.84) / 100;
    }
  }
  return stringSimilarity;
}
