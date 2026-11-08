import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mawaroute_visitor/controllers/auth_controller.dart';
import 'package:mawaroute_visitor/enums.dart';

import '../api/rec_chat_api.dart';
import '../config/app_config.dart';
import '../models/chat.dart';
import '../models/m_avatar_model.dart';
import '../models/rec_text_bubble_el.dart';
import '../screens/chat_rec_screen/rec_graphql.dart';
import '../utilis/formatter.dart';

class RecChatController extends GetxController {
  static RecChatController instance = Get.find<RecChatController>();

  AuthController authController = AuthController.instance;
  final _api = RecChatApi();

  final primaryScrollController = ScrollController();
  final inputController = TextEditingController();

  final languageSetting = '日本語'.obs;
  final languageFlag = "🇯🇵".obs;

  RxBool isStreaming = false.obs;
  RxBool isNewChat = false.obs;

  final chatsForDisplay = <TextBubbleEl>[].obs;

  String avatarUid = "";
  final mAvatar = emptyMAvatarModel.obs;

  String chatUid = "";
  final chatModel = emptyChatModel.obs;

  StreamSubscription? chatSubscription;
  final streamText = ''.obs;
  List<OpenAIChatCompletionChoiceMessageModel> cachedChatMemory = [];

  List<String> existingRecItems = [];

  RxMap<String, String> reasonForRecs = <String, String>{}.obs;

  String recQuery = '';
  String userInputHistory = '';

  String userPersona = '';
  bool isPremiumAcc = false;

  RxInt todayChatCount = 0.obs;

  Position? position;

  RxString imageFilePath = "".obs;

  Future<void> init() async {
    clear();
    try {
      avatarUid = Get.parameters["avatarUid"]!;
      chatUid = getArgument("chatUid");
      addLoadingEl();
      await authController.updateUserprofile();
      mAvatar.value = await _api.fetchMAvatar(avatarUid);
      position = await _api.getCurrentLocation();
      removeLoadingEl();
      if (chatUid.isEmpty) {
        //new chat
        isNewChat.value = true;
        addChatStartQueries();
      } else {
        //load exist chat
        isNewChat.value = false;
        await fetchChatsFromFirestore(chatUid: chatUid);
      }
    } catch (e) {
      if (kDebugMode) print(e);
      SmartDialog.showNotify(
        msg: 'Error, please check your internet connection\n$e}'.tr,
        notifyType: NotifyType.failure,
      );
    }
  }

  void addLoadingEl() {
    chatsForDisplay.add(
      TextBubbleEl(
        type: RecChatElementType.loading.name,
        messageOfAvatar: true,
        message: 'Typing...',
      ),
    );
  }

  void removeLoadingEl() {
    int index = chatsForDisplay.indexWhere((el) => el.type == 'loading');
    if (index >= 0) {
      chatsForDisplay.removeAt(index);
    }
  }

  Future<void> addChatStartQueries() async {
    addLoadingEl();
    streamRecChat();
    removeLoadingEl();
  }

  void streamRecChat() {
    String startPrompt = mAvatar.value.chatStarterPrompt;
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
        .createStream(
          model: AppConfig.openAiChatModel,
          temperature: 1,
          maxTokens: 300,
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  "$startPrompt \n Please answer in $languageSetting",
                ),
              ],
            ),
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          name:${authController.profile.value.displayName}.\n
          location:${position != null ? '${position!.latitude},${position!.longitude}' : ''},.\n
          datetime: ${DateTime.now().toIso8601String()}.\n
          """),
              ],
            ),
            ...cachedChatMemory,
          ],
        );
    isStreaming.value = true;
    chatSubscription = chatStream.listen((streamChatCompletion) {
      final content = streamChatCompletion.choices.first.delta.content;
      if (content != null) {
        streamText.value += content.first?.text ?? '';
      }
    });
    chatSubscription!.onDone(() async {
      await onStreamDone(type: RecChatElementType.text.name);
    });
    chatsForDisplay.add(
      TextBubbleEl(
        type: RecChatElementType.streamText.name,
        message: '_',
        messageOfAvatar: true,
      ),
    );
  }

  void streamRecReason({required String recUid, required String recText}) {
    if (reasonForRecs[recUid] != null || isStreaming.isTrue) return;
    String recPrompt = mAvatar.value.recPrompt;
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
        .createStream(
          model: AppConfig.openAiChatModel,
          temperature: 1,
          maxTokens: 300,
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  "$recPrompt \n Please answer in $languageSetting",
                ),
              ],
            ),
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          name:${authController.profile.value.displayName}.\n
          datetime: ${DateTime.now().toIso8601String()}.\n
          needs: $userInputHistory.\n
          recommendation:$recText.\n
          """),
              ],
            ),
          ],
        );
    isStreaming.value = true;
    reasonForRecs[recUid] = '';
    chatSubscription = chatStream.listen((streamChatCompletion) {
      final content = streamChatCompletion.choices.first.delta.content;
      if (content != null) {
        reasonForRecs[recUid] =
            reasonForRecs[recUid]! + (content.first?.text ?? '');
      }
    });
    chatSubscription!.onDone(() async {
      await onStreamDone(
        type: RecChatElementType.recReason.name,
        recUid: recUid,
      );
    });
  }

  Future<void> onStreamDone({required String type, String? recUid}) async {
    //ui change
    removeStreamTextBubble();
    isStreaming.value = false;
    if (type == 'text') {
      TextBubbleEl chat = TextBubbleEl(
        type: RecChatElementType.text.name,
        message: streamText.value,
        messageOfAvatar: true,
      );
      if (chatUid.isNotEmpty) {
        await _api.saveChatToFirestore(chatUid: chatUid, obj: chat.toJson());
      }
      chatsForDisplay.add(chat);
      //add chat to memory
      chatMemoryControl(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              streamText.value,
            ),
          ],
        ),
      );
      // load recs
      recQuery = _api.extractAllButLastParagraph(streamText.value);
      await addRecItemsBubble();
      streamText.value = '';
    } else {
      TextBubbleEl chat = TextBubbleEl(
        type: RecChatElementType.recReason.name,
        message: reasonForRecs[recUid]!,
        messageOfAvatar: true,
        recUid: recUid,
      );
      if (chatUid.isNotEmpty) {
        await _api.saveChatToFirestore(chatUid: chatUid, obj: chat.toJson());
      }
    }
    //clear variable
  }

  void chatMemoryControl(OpenAIChatCompletionChoiceMessageModel newMessage) {
    cachedChatMemory.add(newMessage);
    if (cachedChatMemory.length > 12) {
      cachedChatMemory.removeAt(0); // Remove the first item
    }
  }

  void removeStreamTextBubble() {
    int index = chatsForDisplay.indexWhere((el) => el.type == 'streamText');
    if (index >= 0) {
      chatsForDisplay.removeAt(index);
    }
  }

  Future<void> addRecItemsBubble() async {
    try {
      if (recQuery.isEmpty) return;
      addLoadingEl();
      List<TextBubbleEl> res = await fetchWeaviateRecItems(recQuery);
      chatsForDisplay.addAll(res);
      if (chatUid.isNotEmpty) {
        for (var recItem in res) {
          await _api.saveChatToFirestore(
            chatUid: chatUid,
            obj: recItem.toJson(),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
      SmartDialog.showNotify(
        msg: "Experiencing technical issues. Please try again later.".tr,
        notifyType: NotifyType.error,
      );
    } finally {
      removeLoadingEl();
    }
  }

  Future<void> findSimilarItems(String itemConcept) async {
    try {
      String input = formatInputString(itemConcept);
      scrollToBottom(90);
      addLoadingEl();
      List<TextBubbleEl> res = await fetchWeaviateRecItems(input);
      chatsForDisplay.addAll(res);
      if (chatUid.isNotEmpty) {
        for (var recItem in res) {
          await _api.saveChatToFirestore(
            chatUid: chatUid,
            obj: recItem.toJson(),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
      SmartDialog.showNotify(
        msg: "Experiencing technical issues. Please try again later.".tr,
        notifyType: NotifyType.error,
      );
    } finally {
      removeLoadingEl();
    }
  }

  Future<List<TextBubbleEl>> fetchWeaviateRecItems(String concepts) async {
    List<TextBubbleEl> res = [];
    QueryResult response = await _api.getWeaviateRecs(
      query: recWeaviateQuery(
        avatarUid: avatarUid,
        concept: concepts,
        shownRecUids: extractExistingRecUids(),
      ),
    );
    if (response.data != null) {
      for (var rec in response.data!["Get"]["AvatarRec"]) {
        if (rec["link"] != null) {
          res.add(TextBubbleEl.fromWeaviate(rec));
        }
      }
    }
    return res;
  }

  Future<void> addInputBubble() async {
    if (inputController.text.isNotEmpty) {
      String input = formatInputString(inputController.text);
      saveUserInput(input);
      chatsForDisplay.add(
        TextBubbleEl(
          type: RecChatElementType.text.name,
          message: input,
          messageOfAvatar: false,
        ),
      );
      //clear ui
      scrollToBottom(90);
      inputController.clear();
      String backgroundKnowledge = "";
      QueryResult response = await _api.getWeaviateRecs(
        query: recWeaviateQuery(
          avatarUid: avatarUid,
          concept: input,
          shownRecUids: extractExistingRecUids(),
        ),
      );
      if (response.data != null) {
        for (var rec in response.data!["Get"]["AvatarRec"]) {
          backgroundKnowledge += "${rec['title']}, ${rec['description']} \n";
        }
      }
      chatMemoryControl(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text("""
             question: $input.
             \n
             background knowledge:$backgroundKnowledge.
             \n
          """),
          ],
        ),
      );
      streamRecChat();
      await initSavingChat(input);
      TextBubbleEl chat = TextBubbleEl(
        type: RecChatElementType.text.name,
        message: input,
        messageOfAvatar: false,
      );
      if (chatUid.isNotEmpty) {
        await _api.saveChatToFirestore(chatUid: chatUid, obj: chat.toJson());
      }
    }
  }

  Future<void> addImageInputBubble() async {
    scrollToBottom(90);
    String input = formatInputString(inputController.text);
    saveUserInput(input);
    String imagePlaceHolder = imageFilePath.value;
    imageFilePath.value = '';
    inputController.clear();
    addLoadingEl();
    String imageUrl = await _api.uploadImage(imagePlaceHolder);
    if (imageUrl.isEmpty) return;
    removeLoadingEl();
    TextBubbleEl chat = TextBubbleEl(
      type: RecChatElementType.imageText.name,
      message: input,
      imageUrl: imageUrl,
      messageOfAvatar: false,
    );
    chatsForDisplay.add(chat);
    if (input.isNotEmpty) {
      chatMemoryControl(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text("""
             question: $input.
          """),
          ],
        ),
      );
    }
    streamImageDescription(question: input, imageUrl: imageUrl);
    await initSavingChat(input);
    if (chatUid.isNotEmpty) {
      await _api.saveChatToFirestore(chatUid: chatUid, obj: chat.toJson());
    }
  }

  void streamImageDescription({
    required String question,
    required String imageUrl,
  }) {
    if (isStreaming.isTrue) return;
    Stream<OpenAIStreamChatCompletionModel>
    chatStream = OpenAI.instance.chat.createStream(
      model: AppConfig.openAiChatModel,
      temperature: 1,
      maxTokens: 300,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "${mAvatar.value.visionPrompt} \n Please answer in $languageSetting",
            ),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(question),
            OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
              imageUrl,
            ),
          ],
        ),
      ],
    );
    isStreaming.value = true;
    chatSubscription = chatStream.listen((streamChatCompletion) {
      final content = streamChatCompletion.choices.first.delta.content;
      if (content != null) {
        streamText.value += content.first?.text ?? '';
      }
    });
    chatSubscription!.onDone(() async {
      removeStreamTextBubble();
      isStreaming.value = false;
      TextBubbleEl chat = TextBubbleEl(
        type: RecChatElementType.text.name,
        message: streamText.value,
        messageOfAvatar: true,
      );
      chatMemoryControl(
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              streamText.value,
            ),
          ],
        ),
      );
      chatsForDisplay.add(chat);
      recQuery = streamText.value;
      await addRecItemsBubble();
      streamText.value = "";
    });
    chatsForDisplay.add(
      TextBubbleEl(
        type: RecChatElementType.streamText.name,
        message: '_',
        messageOfAvatar: true,
      ),
    );
  }

  Future<void> initSavingChat(String input) async {
    if (chatUid.isEmpty) {
      chatUid = await _api.initNewChatToFirestore(
        avatarModel: mAvatar.value,
        query: input,
      );
      List<String> recentAvatarList = await _api.fetchRecentChatsFirestore();
      recentAvatarList.insert(0, mAvatar.value.id!);
      recentAvatarList = _api.removeDuplicates(recentAvatarList);
      await _api.updateRecentChats(recentAvatarList);
    }
  }

  void saveUserInput(String input) {
    userInputHistory += input;
  }

  void clear() {
    // Resetting language settings
    // languageSetting.value = '日本語';
    // languageFlag.value = "🇯🇵";

    // Resetting loading and chat status
    isStreaming.value = false;
    isNewChat.value = false;

    // Clearing chats display
    chatsForDisplay.clear();

    // Resetting avatar and chat models
    avatarUid = "";
    mAvatar.value = emptyMAvatarModel;

    chatUid = "";
    chatModel.value = emptyChatModel;

    // Cancelling and nullifying the chat subscription
    chatSubscription?.cancel();
    chatSubscription = null;

    // Clearing stream text and cached chat memory
    streamText.value = '';
    cachedChatMemory.clear();

    // Clearing existing recommendations and reasons for recommendations
    existingRecItems.clear();
    reasonForRecs.clear();

    //clear currentQuery
    recQuery = '';
    userInputHistory = '';

    // Resetting user persona, premium account status, and chat count
    userPersona = '';
    isPremiumAcc = false;
    todayChatCount.value = 0;

    position = null;
    imageFilePath.value = "";
  }

  Future<void> cancelSubscription() async {
    if (chatSubscription != null) {
      SmartDialog.showLoading(msg: 'Disconnecting...'.tr);
      chatSubscription!.pause();
      await chatSubscription!.cancel();
      if (streamText.value.isNotEmpty) {
        chatsForDisplay.add(
          TextBubbleEl(
            message: streamText.value,
            type: RecChatElementType.text.name,
            messageOfAvatar: true,
          ),
        );
        removeStreamTextBubble();
        streamText.value = '';
      }
      chatSubscription = null;
      isStreaming.value = false;
      SmartDialog.dismiss();
    }
  }

  void scrollToBottom(int extend) {
    primaryScrollController.animateTo(
      primaryScrollController.position.maxScrollExtent + extend,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  List<String> extractExistingRecUids() {
    return chatsForDisplay
        .where(
          (item) => item.type == RecChatElementType.recItem.name,
        ) // Filter items where type is 'rec'
        .map((item) => item.recUid!) // Map to recUid
        .toList();
  }

  String findLastRecUid() {
    return chatsForDisplay
            .where((item) => item.type == RecChatElementType.recItem.name)
            .last
            .recUid ??
        '';
  }

  Future fetchChatsFromFirestore({required String chatUid}) async {
    List<TextBubbleEl> list = [];
    try {
      CollectionReference ref = FirebaseFirestore.instance
          .collection("user_rec_chats")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("chats")
          .doc(chatUid)
          .collection("chat_elements");
      await ref.orderBy("timestamp", descending: false).get().then((value) {
        value.docs.asMap().forEach((index, doc) {
          dynamic data = doc.data();
          if (data["type"] == RecChatElementType.text.name) {
            list.add(TextBubbleEl.fromJson(data, doc.id));
          } else if (data["type"] == RecChatElementType.recItem.name) {
            list.add(TextBubbleEl.fromJson(data, doc.id));
          } else if (data["type"] == RecChatElementType.recReason.name) {
            reasonForRecs[data['recUid']] = data['message'];
          } else if (data["type"] == RecChatElementType.imageText.name) {
            list.add(TextBubbleEl.fromJson(data, doc.id));
          }
        });
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }
    chatsForDisplay.value = list;
  }

  @override
  void dispose() {
    super.dispose();
    primaryScrollController.dispose();
    inputController.dispose();
    chatSubscription?.cancel();
  }
}
