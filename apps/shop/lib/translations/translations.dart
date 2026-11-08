import 'package:get/get.dart';

class TranslationMessages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ja_JP': {
          //bottom navigation
          'Home': 'ホーム',
          'Spot': 'ターゲット写真',
          'Library': 'ギャラリー',
          'Account': '店舗情報',
          //auth screen
          'Continue': '次へ',
          "Place ID": "場所ID",
          'Login with email and password': 'メールアドレスとパスワードでログイン',
          'MaWaRoute Account': 'MaWaRouteアカウント',
          'Please enter valid placeUid!': '場所IDを入力してください',
          'Please enter valid email, password and place ID':
              'メールアドレスとパスワードを入力してください',
          'Invalid credentials!': '無効な認証情報です!',
          'Signing in...': 'ログイン中...',
          'Welcome back!': 'ようこそ',
          'Something went wrong!': 'エラーが発生しました',
          //dashboard screen
          'Boosting foot traffic now': '来店者数を増やす',
          'Setting up business hours will automatically switch on at the designated times.':
              '営業時間を設定することで、指定した時間に自動的にスイッチが入ります。',
          'Setup business hour': '営業時間を設定する',
          'Audience Size': '対象者数',
          'Number of MaWaRoute users are nearby': '近くにいるMaWaRouteのユーザー数',
          '# Visits Today': '# 本日のvisit数',
          'Visitor Insight': '訪問者インサイト',
          '# Token Balance': '# トークン残高',
          'Around': '約',
          'Purchase Credits': 'クレジットを購入する',
          'You cannot turn off this feature now': '実証実験期間オフにすることができません',
          'You account is not setup correctly': 'アカウントが正しく設定されていないようです',
          '# Purchases Today': '# 本日の購入数',
          '# Questionnaires Today': '# 本日のアンケート数',
          '# Visits This Month': '# 本月のvisit数',
          '# Purchases This Month': '# 本月の購入数',
          //spot screen
          'Spot image for まわる to earn campaigns':
              'まわる to earnキャンペーンのターゲット写真を設定する',
          'Select from library': 'ギャラリーから選ぶ',
          //visitor insights screen
          'Visitor Insights 👀': '訪問者インサイト 👀',
          'About the customer': '顧客インサイト',
          //my account screen
          'Configuring...': '設定中...',
          'Save': '保存する',
          'Select your shop to continue': '店舗を選択して次へ進む',
          'Search': '検索する',
          'Confirm sign out?': 'ログアウトしますか？',
          'Sign out': 'ログアウトする',
          'Cancel': 'キャンセル',
          'About the Shop': '店舗について',
          'ULR for marketing': 'ホームページ',
          'Address': '店舗住所',
          'Name': '店舗名',
          'Search for your shop': '店舗を検索する',
          //select to upload screen
          'Upload shop image': '店舗の写真をアップロードする',
          'Image metadata (latitude, longitude) can be uploaded at the same time for your convenience.':
              '画像のメタデータ（緯度、経度）も同時にアップロードすることができ、便利にキャンペーンが作成できます。',
          'Image without geo info cannot be uploaded': 'ジオ情報のない画像はアップロードできません',
          'SELECT': 'アップロードする画像を選択する',
          'Searching...': '検索中...',
          //time table screen
          'Set Time Table': '営業時間を設定する',
          'Update': '更新する',
          'Start Time': '開店時間',
          'End Time': '閉店時間',
          'Monday': '月曜日',
          'Tuesday': '火曜日',
          'Wednesday': '水曜日',
          'Thursday': '木曜日',
          'Friday': '金曜日',
          'Saturday': '土曜日',
          'Sunday': '日曜日',
          'Please enter both open and close time': '営業日の開店と閉店時間を入力してください',
          'Enter Time': '',
          'Hour': '',
          'Minute': '',
          'Invalid Time': '無効な時間',
          //edit single text field screen
          'Edit Marketing URL': '店舗ホームページを編集する',
          'Not valid URL': '有効なURLを入力してください',
          'Edit Shop Description': '店舗紹介文を入力してください',
          //QR Scan Screen
          'Camera Permission Denied': 'カメラアクセスが拒否されました',
          'Processing...': '処理中...',
          'Looking for QR Code...': 'QRコードを探し中...',
          'Successfully completed!': '正常に完了しました！',
          'Beta Features': 'ベータ機能',
          'Token number for purchasing': '購入報酬トークン数',
          'Reward extra tokens to users who make purchases':
              '購入したユーザーに追加トークンを報酬として与える',
          "Error, could not finish the process": 'エラーが発生しました。もう一回やり直してください',
          'Invalid QR code': '無効なQRコード',
          "This qr code already has been used before.": 'このQRコードは使用済みです',
          //visitor list screen
          'More': 'もっと見る',
          'Saving...': '保存中...',
          //coupon history screen
          'Coupon History': 'クーポンの使用履歴',
          'Coupon is applied': 'クーポンが使用されました'
        },
      };
}
