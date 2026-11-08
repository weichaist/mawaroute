import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mawaroute_qr_chat/utils/dartjs_fetch.dart';

import '../api/api.dart';
import '../config/app_config.dart';
import '../models/chat_completion_message_model.dart';
import '../models/link_preview_model.dart';
import '../models/m_avatar.dart';
import '../models/text_bubble_el.dart';
import '../utils/test_prompts.dart';
import '../utils/utility.dart';

class WebChatController extends GetxController {
  static WebChatController instance = Get.find<WebChatController>();

  String avatarUid = "";

  RxList<TextBubbleEl> chatsForDisplay = <TextBubbleEl>[].obs;

  final mAvatar = emptyMAvatarModel.obs;

  final isLoading = false.obs;
  RxBool isStreaming = false.obs;
  bool screenLoaded = false;

  final inputController = TextEditingController();
  final scrollController = ScrollController();

  final languageSetting = '日本語'.obs;

  List<ChatCompletionMessageModel> cachedChatMemory = [];

  RxMap<String, String> reasonForRecs = <String, String>{}.obs;
  RxMap<String, LinkPreviewModel> linkPreviews =
      <String, LinkPreviewModel>{}.obs;

  RxString streamText = ''.obs;

  StreamSubscription? chatSubscription;

  String chatUid = "";

  String userIntent = "";
  String userInputHistory = "";
  String backgroundKnowledge = "";
  List<String> backgroundKnowledgeUrls = [];

  Future<void> init() async {
    if (screenLoaded) return;
    if (isLoading.isTrue) return;
    try {
      avatarUid = Get.parameters['uid'] ?? "";
      screenLoaded = true;
      addLoadingEl();
      mAvatar.value = await fetchMAvatar(avatarUid);
      if (mAvatar.value.name.isEmpty) {
        showError(
          "Sorry, we couldn't find the avatar you're searching for. Please check the url!"
              .tr,
        );
        removeLoadingEl();
        return;
      }
      removeLoadingEl();
      await introChat();
    } catch (e) {
      if (kDebugMode) print(e);
      showError('${'Error, please check your internet connection'.tr}\n$e');
    }
  }

  @override
  onInit() {
    super.onInit();
    clear();
  }

  Future<void> introChat() async {
    if (inputController.text.isNotEmpty) return;
    await streamJSRecChat(
      messages: [
        ChatCompletionMessageModel(
          content:
              "${mAvatar.value.avatarDefinition}\n${mAvatar.value.greetingPrompt}} Please answer in ${languageSetting.value}",
          role: 'system',
        ),
        ChatCompletionMessageModel(
          content: 'visitor name: guest, current time: ${DateTime.now()}',
          role: 'user',
        ),
      ],
    );
  }

  Future<void> processWebChat() async {
    if (inputController.text.isEmpty || mAvatar.value.name.isEmpty) return;
    if (isLoading.isTrue || isStreaming.isTrue) {
      showToast('Please wait for the response before sending another chat'.tr);
      return;
    }
    String input = inputController.text;
    userInputHistory += '\n$input';
    inputController.clear();
    chatsForDisplay.add(
      TextBubbleEl(
        type: RecChatElementType.text.name,
        message: input,
        messageOfAvatar: false,
      ),
    );
    scrollToBottom(150);
    if (cachedChatMemory.isEmpty) {
      chatMemoryControl(
        chatEntry: ChatCompletionMessageModel(
          content:
              "${mAvatar.value.avatarDefinition}\n${mAvatar.value.recPrompt}} Please answer in ${languageSetting.value}",
          role: 'system',
        ),
      );
    }
    await fetchBackgroundKnowledge(input: input);
    chatMemoryControl(
      chatEntry: ChatCompletionMessageModel(
        content:
            """
          customer name: guest, current time: ${DateTime.now()}\n
          customer inquiry: $input\n
          background knowledge: $backgroundKnowledge
          """,
        role: 'user',
      ),
    );
    await streamJSRecChat(messages: cachedChatMemory);
  }

  void chatMemoryControl({required ChatCompletionMessageModel chatEntry}) {
    cachedChatMemory.add(chatEntry);
    if (cachedChatMemory.length > 15) {
      cachedChatMemory.removeAt(1); // Remove the first item
    }
  }

  Future<void> fetchBackgroundKnowledge({required String input}) async {
    if (isLoading.isTrue) return;
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        "FetchWeaviateRecItems",
      );
      final resp = await callable.call(<String, dynamic>{
        "avatarUid": avatarUid,
        "question": input,
        "existingUids": [],
      });
      backgroundKnowledge = resp.data
          .map((el) => "${el["title"]}\n${el["description"]}")
          .toList()
          .join('\n');
      List<TextBubbleEl> recItems = resp.data
          .map<TextBubbleEl>((el) => TextBubbleEl.fromCloudFunction(el))
          .toList();
      chatsForDisplay.addAll(recItems);
      backgroundKnowledgeUrls = recItems
          .map<String>((e) => e.recLink ?? '')
          .toList();
    } catch (e) {
      if (kDebugMode) print(e);
      showError(
        "Sorry, you cannot connect to our server at the moment. Please try later"
            .tr,
      );
    } finally {
      removeLoadingEl();
    }
  }

  Future<void> fetchWeaviateRecItem({required String concepts}) async {
    if (isLoading.isTrue) return;
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        "FetchWeaviateRecItems",
      );
      final resp = await callable.call(<String, dynamic>{
        "avatarUid": avatarUid,
        "question": concepts,
        "existingUids": extractExistingRecUids(),
      });
      List<TextBubbleEl> recItems = resp.data
          .map<TextBubbleEl>((el) => TextBubbleEl.fromCloudFunction(el))
          .toList();
      chatsForDisplay.addAll(recItems);
      List<String> urls = recItems.map<String>((e) => e.recLink ?? '').toList();
      await fetchLinkPreviews(urls);
    } catch (e) {
      if (kDebugMode) print(e);
      showError(
        "Sorry, you cannot connect to our server at the moment. Please try later"
            .tr,
      );
    }
  }

  Future<void> fetchLinkPreviews(List<String> urls) async {
    try {
      final validUrls = filterValidUrls(urls);
      if (validUrls.isEmpty) return;
      HttpsCallable linkPreviewFunction = FirebaseFunctions.instance
          .httpsCallable("getLinkListPreview");
      final previews = await linkPreviewFunction.call(<String, dynamic>{
        "urls": validUrls,
      });
      for (var item in previews.data) {
        String url = item["url"];
        Uri uri = Uri.parse(url);
        String baseUrl = '${uri.scheme}://${uri.host}';
        linkPreviews[url] = LinkPreviewModel.fromJson(item, baseUrl);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchSimilarWeaviateRecItem({required String concepts}) async {
    if (isLoading.isTrue) return;
    try {
      addLoadingEl();
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        "FetchWeaviateRecItems",
      );
      final resp = await callable.call(<String, dynamic>{
        "avatarUid": avatarUid,
        "question": concepts,
        "existingUids": extractExistingRecUids(),
      });
      List<TextBubbleEl> recItems = resp.data
          .map<TextBubbleEl>((el) => TextBubbleEl.fromCloudFunction(el))
          .toList();
      chatsForDisplay.addAll(recItems);
    } catch (e) {
      if (kDebugMode) print(e);
      showError(
        "Sorry, you cannot connect to our server at the moment. Please try later"
            .tr,
      );
    } finally {
      removeLoadingEl();
    }
  }

  void scrollToBottom(int extend) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + extend,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void clear() {
    avatarUid = "";
    chatsForDisplay.clear();
    mAvatar.value = emptyMAvatarModel;
    isLoading.value = false;
    isStreaming.value = false;
    screenLoaded = false;

    languageSetting.value = '日本語';
    cachedChatMemory.clear();
    reasonForRecs.clear();
    linkPreviews.clear();
    streamText.value = "";
    chatSubscription == null;
    chatUid = "";
    userIntent = "";
    userInputHistory = "";
    backgroundKnowledge = "";
    backgroundKnowledgeUrls.clear();
  }

  Future<void> clearForLanguageChange() async {
    chatsForDisplay.clear();
    isLoading.value = false;
    isStreaming.value = false;
    cachedChatMemory.clear();
    reasonForRecs.clear();
    linkPreviews.clear();
    streamText.value = "";
    chatSubscription == null;
    userIntent = "";
    userInputHistory = "";
    backgroundKnowledge = "";
    backgroundKnowledgeUrls.clear();
    await introChat();
  }

  Future<void> streamJSRecChat({
    required List<ChatCompletionMessageModel> messages,
  }) async {
    Stream chatStream = jsChatStream(messages);
    isStreaming.value = true;
    try {
      chatSubscription = chatStream.listen((token) {
        streamText.value += token;
      });
      chatSubscription!.onDone(() async {
        String res = streamText.value;
        streamText.value = "";
        removeStreamTextBubble();
        isStreaming.value = false;
        TextBubbleEl chat = TextBubbleEl(
          type: RecChatElementType.text.name,
          message: res,
          messageOfAvatar: true,
        );
        chatsForDisplay.add(chat);
        if (cachedChatMemory.isEmpty) {
          await fetchWeaviateRecItem(concepts: extractAllButLastParagraph(res));
        } else {
          userIntent = await extractUserIntentWithChatGPT();
        }
      });
      chatsForDisplay.add(
        TextBubbleEl(
          type: RecChatElementType.streamText.name,
          message: '_',
          messageOfAvatar: true,
        ),
      );
      await fetchLinkPreviews(backgroundKnowledgeUrls);
    } catch (e) {
      if (kDebugMode) print(e);
      showError(
        "Sorry, you cannot connect to our server at the moment. Please try later"
            .tr,
      );
    }
  }

  Future<String> extractUserIntentWithChatGPT() async {
    String res = "";
    final url = Uri.parse(AppConfig.chatUrl);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            ChatCompletionMessageModel(
              content: intentCaptureGPT(),
              role: 'system',
            ),
            ChatCompletionMessageModel(
              content:
                  """
              user questions: $userInputHistory,
              """,
              role: 'user',
            ),
          ],
        }),
      );
      final responseData = jsonDecode(response.body);
      res = responseData['choices'][0]['message']['content'];
    } catch (e) {
      if (kDebugMode) print(e);
      showError(
        "Sorry, you cannot connect to our server at the moment. Please try later"
            .tr,
      );
    }
    return res;
  }

  Future<void> streamRecReason({
    required String recUid,
    required String recText,
  }) async {
    if (reasonForRecs[recUid] != null) return;
    if (isStreaming.isTrue) {
      showToast('Please wait for the response before sending another chat'.tr);
      return;
    }
    String languagePrompt = 'Please answer in ${languageSetting.value}';
    isStreaming.value = true;
    Stream chatStream = jsChatStream([
      ChatCompletionMessageModel(
        content: "${mAvatar.value.rfrPrompt}\n$languagePrompt",
        role: 'system',
      ),
      ChatCompletionMessageModel(
        content:
            """
        needs: $userIntent\n
        recommendation: $recText.
        """,
        role: 'user',
      ),
    ]);
    try {
      reasonForRecs[recUid] = '';
      chatStream
          .listen((token) {
            reasonForRecs[recUid] = reasonForRecs[recUid]! + token;
          })
          .onDone(() {
            isStreaming.value = false;
            if (chatUid.isNotEmpty) {
              //todo save to database
            }
          });
    } catch (e) {
      if (kDebugMode) print(e);
      showError(
        "Sorry, you cannot connect to our server at the moment. Please try later"
            .tr,
      );
    }
  }

  List<String> extractExistingRecUids() {
    return chatsForDisplay
        .where(
          (item) => item.type == RecChatElementType.recItem.name,
        ) // Filter items where type is 'rec'
        .map((item) => item.recUid!) // Map to recUid
        .toList();
  }

  void addLoadingEl() {
    isLoading.value = true;
    chatsForDisplay.add(
      TextBubbleEl(
        type: RecChatElementType.loading.name,
        messageOfAvatar: true,
        message: 'Typing...'.tr,
      ),
    );
  }

  void removeLoadingEl() {
    isLoading.value = false;
    int index = chatsForDisplay.indexWhere(
      (el) => el.type == RecChatElementType.loading.name,
    );
    if (index >= 0) {
      chatsForDisplay.removeAt(index);
    }
  }

  void removeStreamTextBubble() {
    int index = chatsForDisplay.indexWhere((el) => el.type == 'streamText');
    if (index >= 0) {
      chatsForDisplay.removeAt(index);
    }
  }

  String findLastRecUid() {
    return chatsForDisplay
            .where((item) => item.type == RecChatElementType.recItem.name)
            .last
            .recUid ??
        '';
  }

  @override
  void dispose() {
    super.dispose();
    inputController.dispose();
    scrollController.dispose();
  }
}
