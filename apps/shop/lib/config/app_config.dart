/// Values passed at build time with `--dart-define-from-file=config/<name>.json`.
class AppConfig {
  AppConfig._();

  /// OpenAI key used by the "chat about this visitor" screen, which calls the
  /// OpenAI API straight from the device. Anything compiled into the app can
  /// be extracted from it, so use a restricted key (see README).
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');

  /// Chat model for the same screen.
  static const openAiModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4.1-mini',
  );
}
