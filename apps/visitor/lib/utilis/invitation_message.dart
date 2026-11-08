import '../config/app_config.dart';

/// Text shared with a friend together with the invitation code.
String invitationMessage(
  String code, {
  String guideUrl = AppConfig.inviteGuideUrl,
}) {
  final guide = guideUrl.isEmpty ? '' : '\nくわしい使い方はこちら。\n$guideUrl';
  return 'あなたが使うと私もおトク！\n「mawaroute マワルト」アプリ使ってみてください。\n下記のコードを登録して合計20GGMTがもらえます。\n$code$guide';
}
