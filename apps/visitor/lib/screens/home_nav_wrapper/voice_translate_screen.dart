import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/voice_assistant_controller.dart';
import '../../theme/constants.dart';
import 'components/build_language_selection_dialog.dart';

class VoiceAssistantScreen extends StatelessWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = VoiceAssistantController.instance;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/sound-wave.jpg'),
            fit: BoxFit.cover, // This will fill the container
          ),
        ),
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                c.clear();
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    title: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await buildLanguageSelectionDialog(context, (
                                lang,
                              ) {
                                c.primaryLanguage.value = lang['language_name'];
                                c.primaryLanguageFlag.value = lang['flag'];
                              });
                            },
                            child: Text(
                              c.primaryLanguageFlag.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            CupertinoIcons.arrow_right_arrow_left_circle,
                            color: Colors.white,
                            size: 27,
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await buildLanguageSelectionDialog(context, (
                                    lang,
                                  ) {
                                    c.targetLanguage.value =
                                        lang['language_name'];
                                    c.targetLanguageFlag.value = lang['flag'];
                                  });
                                },
                                child: Text(
                                  c.targetLanguageFlag.value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 9,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black],
                        ),
                      ),
                      child: Obx(
                        () => ListTile(
                          title: GestureDetector(
                            onTap: () {
                              c.createTextToSpeech(
                                c.streamText.value.split('\n').first,
                              );
                            },
                            child: Text(
                              c.streamText.value.split('\n').first,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          subtitle: c.streamText.value.split('\n').length > 1
                              ? GestureDetector(
                                  onTap: () {
                                    c.createTextToSpeech(
                                      c.streamText.value.split('\n').last,
                                    );
                                  },
                                  child: Text(
                                    c.streamText.value.split('\n').last,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemBuilder: (context, index) {
                      return Obx(
                        () => ListTile(
                          title: Text(
                            c.translatedTextList[index].originalText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            c.translatedTextList[index].translatedText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: c.translatedTextList.length,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () =>
                      c.isPrimaryLanguageRecording.isTrue ||
                          c.isTargetLanguageRecording.isTrue
                      ? SafeArea(
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, kPrimaryColor],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Lottie.asset(
                                    'assets/lottie_files/voice_assistant.json',
                                  ),
                                  Obx(
                                    () => Text(
                                      c.recordTimeString.value,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
                Container(
                  height: 99,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 9,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        c.isPrimaryLanguageRecording.isFalse
                            ? VoicePrimaryIconButton(
                                icon: const Icon(
                                  CupertinoIcons.mic,
                                  color: Colors.white,
                                  size: 42,
                                ),
                                onTap: () async {
                                  await c.recordPrimaryLanguage();
                                },
                              )
                            : VoicePrimaryIconButton(
                                icon: const Icon(
                                  CupertinoIcons.stop_fill,
                                  color: Colors.red,
                                  size: 42,
                                ),
                                onTap: () async {
                                  await c.stopRecordingPrimaryLanguage();
                                },
                              ),
                        c.isTargetLanguageRecording.isFalse
                            ? VoicePrimaryIconButton(
                                icon: const Icon(
                                  CupertinoIcons.mic,
                                  color: Colors.white,
                                  size: 42,
                                ),
                                onTap: () async {
                                  await c.recordTargetLanguage();
                                },
                              )
                            : VoicePrimaryIconButton(
                                icon: const Icon(
                                  CupertinoIcons.stop_fill,
                                  color: Colors.red,
                                  size: 42,
                                ),
                                onTap: () async {
                                  await c.stopRecordingTargetLanguage();
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VoicePrimaryIconButton extends StatelessWidget {
  const VoicePrimaryIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });
  final Widget icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child:
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(aspectRatio: 1, child: icon),
          ).frosted(
            blur: 10,
            frostColor: kPrimaryColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
          ),
    );
  }
}
