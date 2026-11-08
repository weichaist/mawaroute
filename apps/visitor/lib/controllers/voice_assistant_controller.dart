import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../config/app_config.dart';
import '../models/translate_text_model.dart';

class VoiceAssistantController extends GetxController {
  static VoiceAssistantController instance =
      Get.find<VoiceAssistantController>();

  final record = AudioRecorder();
  final player = AudioPlayer();

  Timer? timer;
  bool isLoading = false;
  RxBool isPrimaryLanguageRecording = false.obs;
  RxBool isTargetLanguageRecording = false.obs;

  int recordCounter = 0;
  RxString recordTimeString = '00:00'.obs;

  File? tempFile;

  final primaryLanguage = '日本語'.obs;
  final primaryLanguageFlag = "🇯🇵".obs;

  final targetLanguage = 'English'.obs;
  final targetLanguageFlag = "🇺🇸".obs;

  RxString streamText = ''.obs;

  RxList<TranslateTextModel> translatedTextList = <TranslateTextModel>[].obs;

  Future<void> recordPrimaryLanguage() async {
    if (isTargetLanguageRecording.isTrue) return;
    isPrimaryLanguageRecording.value = true;
    await startToRecordAudio();
  }

  Future<void> stopRecordingPrimaryLanguage() async {
    if (tempFile == null) throw Exception('Temporary file is null');
    streamText.value = '';
    isPrimaryLanguageRecording.value = false;
    stopCount();
    await record.stop();
    final text = await transcriptWithOpenAI(tempFile!);
    streamTranscriptWithTranslation(
      transcript: text,
      language: targetLanguage.value,
    );
    await tempFile!.delete();
  }

  Future<void> recordTargetLanguage() async {
    if (isPrimaryLanguageRecording.isTrue) return;
    isTargetLanguageRecording.value = true;
    await startToRecordAudio();
  }

  Future<void> stopRecordingTargetLanguage() async {
    if (tempFile == null) throw Exception('Temporary file is null');
    streamText.value = '';
    isTargetLanguageRecording.value = false;
    stopCount();
    await record.stop();
    final text = await transcriptWithOpenAI(tempFile!);
    streamTranscriptWithTranslation(
      transcript: text,
      language: primaryLanguage.value,
    );
    await tempFile!.delete();
  }

  Future<Null> startToRecordAudio() async {
    if (!await record.hasPermission()) {
      return null;
    }
    final tempDir = await getTemporaryDirectory();
    tempFile = await File('${tempDir.path}/${DateTime.now()}.flac').create();
    if (tempFile == null) throw Exception('Failed to create temporary file');
    await record.start(
      const RecordConfig(
        encoder: AudioEncoder.flac,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      ),
      path: tempFile!.path,
    );
    countUp();
  }

  void formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    recordTimeString.value =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<String> transcriptWithOpenAI(File file) async {
    String transcript = '';
    final transcription = await OpenAI.instance.audio.createTranscription(
      file: await loadOpenAIFile(file.path),
      model: "whisper-1",
      responseFormat: OpenAIAudioResponseFormat.json,
    );
    if (transcription is OpenAITranscriptionModel) {
      transcript = transcription.text;
    }
    return transcript;
  }

  Future<void> createTextToSpeech(String text) async {
    if (isLoading) return;
    isLoading = true;
    final tempSpeechDir = await getTemporaryDirectory();
    final speechBytes = await OpenAI.instance.audio.createSpeechBytes(
      model: "tts-1-hd",
      input: text,
      voice: OpenAIAudioVoice.alloy,
      responseFormat: OpenAIAudioSpeechResponseFormat.flac,
    );
    final speechFile = File(
      '${tempSpeechDir.path}/tts-${DateTime.now().millisecondsSinceEpoch}.flac',
    );
    await speechFile.writeAsBytes(speechBytes);
    await player.play(DeviceFileSource(speechFile.path));
    await speechFile.delete();
    isLoading = false;
  }

  Future<void> streamTranscriptWithTranslation({
    required String transcript,
    required String language,
  }) async {
    Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
        .createStream(
          model: AppConfig.openAiChatModel,
          temperature: 1,
          maxTokens: 300,
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text("""
                You are a helpful assistant.
                Your task is to correct any spelling discrepancies in the transcribed text
                and then in a separate paragraph, translate the text in $language.
                Do not explain what you are doing.
                Please answer in two paragraphs:
                corrected transcribed text,
                translated text
              """),
              ],
            ),
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  transcript,
                ),
              ],
            ),
          ],
        );
    chatStream.listen((streamChatCompletion) {
      final content = streamChatCompletion.choices.first.delta.content;
      if (content != null) {
        final text = content.first?.text;
        if (text != "[" && text != "]" && text != ",") {
          streamText.value += (text ?? '');
        }
      }
    });
  }

  void countUp() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordCounter++;
      formatTime(recordCounter);
    });
  }

  void stopCount() {
    timer?.cancel();
    recordCounter = 0;
    recordTimeString.value = '00:00';
  }

  void clear() {
    isLoading = false;
    isPrimaryLanguageRecording.value = false;
    isTargetLanguageRecording.value = false;

    recordCounter = 0;
    recordTimeString.value = '00:00';

    streamText.value = '';
    translatedTextList.clear();

    tempFile = null;

    primaryLanguage.value = '日本語';
    primaryLanguageFlag.value = "🇯🇵";
    targetLanguage.value = 'English';
    targetLanguageFlag.value = "🇺🇸";
  }

  @override
  dispose() {
    timer?.cancel();
    record.dispose();
    player.dispose();
    super.dispose();
  }
}
