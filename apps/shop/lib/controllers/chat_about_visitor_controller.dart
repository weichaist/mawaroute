import "dart:convert";

import "package:cloud_functions/cloud_functions.dart";
import "package:flutter/cupertino.dart";
import "package:get/get.dart";
import "package:http/http.dart" as http;
import "package:mawaroute_shop/api/firestore_services.dart";
import "package:mawaroute_shop/config/app_config.dart";

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});
}

class ChatAboutVisitorController extends GetxController {
  static ChatAboutVisitorController instance =
      Get.find<ChatAboutVisitorController>();
  final api = FireStoreService();
  Rx<TextEditingController> question = TextEditingController().obs;
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  List<ChatMessage> contextMessages = <ChatMessage>[];

  final visitorName = ''.obs;
  final visitorProfile = ''.obs;

  RxBool isLoading = false.obs;

  Future<void> init() async {
    List tags = Get.arguments["tags"];
    visitorName.value = Get.arguments["visitorName"];
    visitorProfile.value = Get.arguments["visitorProfile"];
    question.value.text = "";
    messages.clear();
    contextMessages = [
      ChatMessage(role: "system", content: "You are a helpful assistant."),
      ChatMessage(
          role: "user",
          content:
              "One of users can be described with following tags: ${tags.join(", ")}"),
      // ChatMessage(
      //     role: "user",
      //     content:
      //         "User has following tags: ${tags.join(", ")} \n and I will ask questions about this user in Japanese. Please answer in Japanese"),
    ];
  }

  Future<List<String>> getTranslationToEnglish(List<String> text) async {
    HttpsCallable translateToEnglish =
        FirebaseFunctions.instance.httpsCallable('TranslateToEnglish');
    final result = await translateToEnglish.call({"text": text});
    return result.data.map<String>((e) => e.toString()).toList();
  }

  Future<List<String>> getTranslationToJapanese(List<String> text) async {
    HttpsCallable translateToEnglish =
        FirebaseFunctions.instance.httpsCallable('TranslateToJapanese');
    final result = await translateToEnglish.call({"text": text});
    return result.data.map<String>((e) => e.toString()).toList();
  }

  Future<String> sendChatCompletionRequest() async {
    String openaiApiKey = AppConfig.openAiApiKey;
    //Todo: Url may change in the future
    Uri url = Uri.parse("https://api.openai.com/v1/chat/completions");
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $openaiApiKey",
    };

    List convertedMessages = [];
    for (var message in contextMessages) {
      convertedMessages.add({"role": message.role, "content": message.content});
    }
    String requestBody = jsonEncode(
        {"model": AppConfig.openAiModel, "messages": convertedMessages});

    dynamic response =
        await http.post(url, headers: headers, body: requestBody);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var completion = data["choices"][0]["message"]["content"];
      return completion;
    } else {
      throw Exception("Failed to send chat completion request.");
    }
  }

  Future getAnswer() async {
    try {
      List<String> englishQuestion =
          await getTranslationToEnglish([question.value.text]);
      contextMessages
          .add(ChatMessage(role: "user", content: englishQuestion[0]));
      messages.add(ChatMessage(role: "user", content: question.value.text));
      var answer = await sendChatCompletionRequest();
      List<String> japaneseAnswer = await getTranslationToJapanese([answer]);
      contextMessages.add(ChatMessage(role: "assistant", content: answer));
      messages.add(ChatMessage(role: "assistant", content: japaneseAnswer[0]));
      question.value.text = "";
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future getAnswerWithPreset() async {
    try {
      String englishQuestion = 'Can you give a concisely profile of this user?';
      contextMessages.add(ChatMessage(role: "user", content: englishQuestion));
      messages.add(ChatMessage(role: "user", content: 'この顧客の好みについて教えてください'));
      var answer = await sendChatCompletionRequest();
      List<String> japaneseAnswer = await getTranslationToJapanese([answer]);
      contextMessages.add(ChatMessage(role: "assistant", content: answer));
      messages.add(ChatMessage(role: "assistant", content: japaneseAnswer[0]));
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
