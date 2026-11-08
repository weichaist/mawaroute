import 'package:get/get.dart';

class TranslationMessages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ja_JP': {
      //auth screen
      'Create Account': 'アカウント作成',
      'Mawaroute Account': 'マワルトアカウント',
      'Please select your country code': '国コードを選択してください',
      'Continue': '次へ',
      'Login with phone number': '携帯電話番号でログイン',
      'Enter the verification code': '認証コードを入力',
      'Login': 'ログイン',
      'Resend the code': 'コードの再送信',
      'Verification Code Sent': '認証コードが送信されました',
      'Please enter the verification code': '認証コードを入力してください',
      'Signing in...': 'ログイン中...',
      'Successfully Logged Out!': 'ログアウトに成功しました',
      'Please wait until Sign out process is completed': 'サインアウトが完了するまでお待ちください',
      'An error has occurred': 'エラーが発生しました',
      'Please wait until sign out process is completed':
          'サインアウトの処理が完了するまでお待ちください',
      //home screen
      'Check out the place in Map App': 'マップで場所を確認',
      'Error, please check your internet connection': 'エラー！ンターネット接続を確認してください',
      'Nearby Places': '近場',
      "Let's start to earn from visiting a nearby place":
          "身近なところからまわる２Earnしましょう！",
      'MaWaRu': 'まわる',
      'M2E': 'まわる2Earn',
      'Wallet': 'ウォレット',
      '✨ Special Plans': '✨ 特別プラン',
      'We are constantly improving the user experience. Update the app and enjoy the latest and greatest!':
          '私たちは常にユーザーエクスペリエンスを向上させています。アプリをアップデートして、最新・最高の状態でお楽しみください!',
      'Update': 'アップデート',
      "Discover your next favorite spots with our AI-driven recommendations!":
          'AIによるおすすめで次のお気に入りのスポットを見つけましょう！',
      "🤩 Earn tokens as you visit, and enjoy cashback at shops and restaurants 🤩":
          "🤩 訪れるだけでトークンを獲得し、ショップやレストランでのお買い物でキャッシュバックをお楽しみいただけます 🤩",
      '😌 Earning your first token is easy!': '😌 最初の1枚トークンをゲットするのは超簡単！',
      'What are you up to today?': '今日はどこをまわる？',
      '👇 Pick a keyword to get recommendations!': '👇 AIのオススメプランで・・・',
      'Customizing a new campaign for you...': 'おすすめプランを作成中...',
      'Follow AI recommended route': 'おすすめルートをまわる',
      'Recommended items for you': 'おすすめアイテムを見る',
      'Visit recommended items to earn': '商品をみて、貯めよう',
      'Visit recommended shops to earn': 'お店をまわって、貯めよう',
      //place details screen
      'Campaigns': 'キャンペーン',
      'Plans': 'プラン',
      'Plan': 'プラン',
      'Rewards': '特典',
      'Start': 'スタート',
      'Participate': '参加',
      'Explore our recommended spots tailored just for you & earn tokens along the way!':
          'あなたの好みに合わせたおすすめスポットを訪れながら、GGMTトークンを獲得しよう！',
      'Shopping': '買い物',
      'Food & Drink': '食事',
      'Just Walk Around': 'ぶらぶら歩く',
      'At the moment, we are unable to suggest any recommended stores for you.':
          'おすすめのお店をご提案することはできません',
      'Load more': 'もっと見る',
      'Max': '限定',
      'GGMT': 'GGMTトークン',
      'The reward is now closed': '特典期間が終了しました',
      'days': '日',
      'Visit': 'まわる',
      'View': '見る',
      'Invalid email address': 'メールアドレスは無効です',
      'Congratulations! You have got this reward': 'おめでとう！あなたはこの特典をゲットしました',
      '#Token required': '必要なトークン数',
      //campaign screen
      'MAWARU TO EARN 🤑': 'まわると貯まる 🤑',
      'Navigate to start point': 'プランの近くに移動',
      'Activities': '参加者情報',
      'Ranking': 'ランキング',
      'Requirements': 'スタート条件',
      'Campaign is live 🤩': 'プランスタート 🤩',
      'Campaign start in': 'プランスタートまで',
      'The campaign has successfully ended 🙇🏻‍♂️': 'プランは終了しました 🙇🏻‍♂',
      'You have granted camera and location access 📸📍':
          'カメラと位置情報へのアクセスを許可しました 📸📍',
      'You have not yet granted camera and location access. Click to grant access.':
          'カメラと位置情報へのアクセスが許可されていません。クリックするとアクセスを変更できます。',
      "You're yet to join the campaign. Feel free to start anytime. 😎":
          'まだプランをまわってないので、いつでも始めてOKです 😎',
      'You have completed this campaign 👏🏻️': 'このプランをクリアしました 👏🏻️',
      'Start to Earn': 'Earn スタート',
      'Details': '詳細',
      'How to Clear': 'クリアまでの流れをもう一度見たい方はこちら👉',
      '1. Check the mawaru to earn area is not too far for you.':
          'まわる to earnのエリアが行動範囲内か確認しよう！',
      '2. Make sure all the checkboxes are green, then click the start to earn button above.':
          'すべてのチェックボックスが緑色の表示になっていることを確認してから、上部にある開始ボタンをクリックしよう！',
      '3. Go & find out the spot in the picture within the mawaru to earn area and take the same shot. Congrats! You have completed one task.':
          'まわる to earnのエリア内にあらかじめ登録されている写真スポットを探して巡り、見つけたら同じ写真を撮ろう！',
      '4. Once you complete all tasks, you will be rewarded GGMT (mawaroute token)':
          'タスクをクリアすると、GGMT（ぐるぐるまわるトークン）の報酬が貯まる',
      '5. Make sure to exchange rewards with your tokens.':
          'ゲットしたGGMTをといろな特典と交換しよう！',
      "Started - good luck!": 'スタート～頑張ってください',
      "Cleared - great job!": 'クリアー～素晴らしい!',
      'Participating in the campaign.': 'プランに参加中...',
      'Could not participate now 😳': 'ただいま参加できません 😳',
      //user campaign screen
      'Number of GGMT to earn 🤩': 'ゲットできるトークン数 🤩',
      'Campaign': 'キャンペーン',
      'Time has passed since the start of the campaign': 'プラン開始からの経過時間',
      'Location permission or camera permission is denied':
          '位置情報の許可またはカメラの許可が拒否されました',
      //reward screen
      'Thank you!': 'ありがとうございます!',
      'Successfully registered': '登録が完了しました',
      'Register': '登録する',
      'Get this reward': '特典をゲットする',
      'About this reward': '特典について',
      'Period': '特典期間',
      'Start Time': '開始時間',
      'End Time': '終了時間',
      'Participants': '登録者',
      'Cannot find your private key': 'Private keyが見つかりませんでした',
      'This reward has expired': '特典期間が終了しました',
      'You can only get rewards during the eligibility period':
          '特典をゲットするのは、特典期間中のみとなります',
      'Congratulations!': 'おめでとう！',
      'Add to Favorites': 'お気に入りに追加する',
      'Added to Favorites': 'お気に入りに追加済み',
      'Favorited By': 'お気に入り登録者',
      'To claim your reward, please provide your email address and click Submit':
          '特典をゲットするには、メールアドレスを入力し、送信をクリックしてください。',
      'Processing...': '処理中...',
      'Oops, an error has occurred during loading your wallet...':
          'ウォレットの読み込み中にエラーが発生しました',
      'Limited to': '限定枚数',
      'Usage history': '利用履歴',
      'Apply': '使う',
      'To apply this coupon, please show this screen to shop staff.':
          '本クーポンを適用するには、この画面を店員に提示してください。',
      'Slide to apply': 'スライドで使う',
      //M2E screen
      'Are you sure you want to leave this screen? 🤔': 'この画面を離れてもよろしいですか？ 🤔',
      'Quick completion equals extra bonuses!': '早く完成させるとボーナスがもらえる!',
      'Look for these spots within the M2E area and take a picture to match the picture on the left side!':
          'M2Eのエリア内でスポットを探し出し,　左側の写真にそっくりに撮ってください！',
      'You have cleared this campaign!': 'このプランをクリアしました!',
      'Leave': '離れる',
      'Cancel': 'キャンセル',
      'Score: ': '点数',
      'Visit these spots and take a picture to match the picture on the left side! You will be reward tokens once you clear all tasks!':
          'スポットを訪ね,　左側の写真にそっくりに撮ってね！すべてのスポットをvisitしたら、トークンをゲット！',
      'M2E Area': 'まわる2Earnエリア',
      'Final Score: ': '最終点数: ',
      //capture task image screen
      'SUBMIT': '送信',
      'Score': '点数',
      'Congrats!!! You have found the spot!': 'おめでとうございます!!! スポットをクリアしました！',
      'Oops... Your score is below 50% similarity 🥲 , please Try again':
          'おっと、スコアが50%以下だったようです 🥲 もう一度試してください',
      'Oops... Your score is below 60% similarity 🥲 , please Try again':
          'おっと、スコアが60%以下だったようです 🥲 もう一度試してください',
      'You are so far away': 'あなたはとても遠くにいます',
      'Transferring GGMT...': 'GGMTを獲得中...',
      'GGMT transferred!': 'ゲットしました！',
      'Calculating similarity...': '類似度を計算中...',
      'Try again': '撮り直し',
      'You cannot visit this shop outside of the business hours':
          '営業時間外にはvisitできません。',
      //wallet screen
      'Wallet address copied': 'ウォレットのアドレスがコピーされました',
      'Oops, something went wrong...': 'おっと、エラーが発生しました...',
      'Live': 'プレー中',
      'Cleared': 'クリア済み',
      'Registered': '応募済み',
      'Earned': '獲得済み',
      'Settings': '設定',
      'Get more MATIC for GGMT transfer': 'トークンと特典を交換するには、MATIC数が必要だよ。',
      'Please select Mumbai network and MATIC token on Polygon Faucet':
          'MumbaiネットワークとMATICトークンを選択してください',
      'Error of loading your private key': 'Private Keyの読み込みに失敗した',
      'Private key copied': 'Private Keyがコピーされました',
      'Copy my private key': 'Private Keyを安全の場所に保存する',
      'Remember to store your key in a secure location':
          '鍵は安全な場所に保管することを忘れないでください',
      'Permissions': 'アクセス権限',
      'Sign out of the \nmawaroute app now?': '今すぐmawarouteからサインアウトしますか？',
      'Logout': 'ログアウト',
      'Transfer': '特典と交換する',
      'Checking MATIC Balance...': 'MATIC数を確認中...',
      'Sufficient MATIC balance is required to transfer GGMT':
          'トークンと特典を交換するには、MATIC数が必要だよ',
      'Get': 'ゲット',
      'Please enter transfer amount': '送金額を入力してください',
      'Insufficient Balance': '残高不足',
      'Balance': '残高',
      'Transferred': 'トークンをゲットしました',
      'Transfer failed': 'エラーが発生しました',
      'Check MATIC Balance': '最新のMATIC数を確認',
      'Balance has been updated': 'MATIC数が更新されました',
      'Could not transfer GGMT token.': 'GGMTの送金に失敗しました',
      'Get MATIC first, then transfer GGMT': 'まずMATICを入手し、GGMTを送金してください。',
      'Delete your mawaroute account': 'mawarouteアカウントの削除',
      'Attention! Once your account is deleted, you cannot recover your data. Please long press the Delete button to continue.':
          '注意! 一度アカウントを削除すると、データを復元することはできません。続行するには削除ボタンを長押ししてください。',
      'Delete': '削除する',
      'We are processing your account deletion request':
          'アカウント削除のリクエストを処理しています',
      'End of list': 'リストの最後',
      '😌 Get your first reward with GGMT tokens': '😌 GGMTトークンで最初の特典をゲットしよう',
      'Address ': 'アドレス ',
      'Favorites': 'お気に入り',
      'Routes': 'ルート',
      'More': 'もっと見る',
      'Items': '商品',
      //profile editing screen
      'Edit Profile': 'プロフィール編集',
      'Username': 'ユーザー名',
      'Save': '保存する',
      //permission screen
      'Camera is required to participate in campaigns': 'プランをスタートにはカメラが必要です',
      'Photos access is required to change your profile picture':
          'プロフィール写真の変更には、Photosへのアクセス権が必要です',
      'Location is required to verify your participation of campaigns':
          '位置情報は、プランをスタートする時の場所を確認するために必要です',
      'Get notified for exciting news and updates': 'ニュースやアップデートのお知らせを受け取ります',
      'Permission Granted': 'アクセス許可済み',
      'Please allow access in the system settings': 'システム設定でアクセスを許可してください',
      //user_campaign_model
      'AI generated campaign': 'AI generated campaign',
      //customize user recommendation screen
      'Create Route': 'このルートでまわる',
      'Add more spots': 'スポットを追加',
      'Customize Your Recommendations': 'まわるスポットを決めよう！',
      'Refine with keyword 🔍': 'キーワードで検索 🔍',
      'Not Interested': '他のスポットに変更',
      'Enter your preferred keywords to fine-tune recommendations':
          'キーワードを入力し、おすすめスポットをフィルタリングする',
      'spots': 'スポット',
      'Done': '完了',
      'We cannot find recommendations for you here at the moment':
          'こちらではあなたへのおすすめスポットを見つけることができません',
      'Back': '戻る',
      'Plan should have at least one recommended spot':
          'プランには1つ以上のオススメスポットが必要です',
      'Location Access is Denied': '位置情報へのアクセスが拒否されました',
      'Reason of recommendation (Beta)': 'あなたへのおすすめ (Beta)',
      'You have reached the end of our recommendation list': '推薦リストは以上です',
      'times\nleft': '回\n残り',
      "Sorry, you've reached today's play limit. Please come back tomorrow to continue playing.":
          '申し訳ありませんが、本日のプレイ上限に達しました。明日再度プレイするために戻ってきてください。',
      '#Token to earn': '獲得トークン数',
      //Notification Screen
      '📰 News & Updates': '📰 通知',
      //send invitation screen
      'Invite friend to earn bonus tokens': '友達紹介ボーナストークン',
      '🎁 Both you and your friend\nearn 10 tokens 🙋':
          '🎁 あなたにも友達にも\n10トークンをプレゼント 🙋',
      'Invite your friends to join. Both you and your friend earn 10 GGMT tokens 🎁':
          '友達を招待し、あなたにも友達にも10 GGMTトークンをプレゼント 🎁',
      'Send to your friend': '友達に送る',
      'Your Invitation Code': '友達紹介コード',
      'Copy': 'コピー',
      'Friends joined with your code': 'あなたのコードで参加した友達',
      'Invitation code is copied': '招待コードがコピーされました',
      "Invitation code is not found": '招待コードが見つかりません',
      'You have used the invitation code already': 'すでに招待コードを使用しました',
      'Redeem Your Code': 'もらったコードを登録',
      'Enter invitation code from your friends': '友達からの招待コードを入力してください',
      'Submit': '送信',
      'URL is not valid': 'URLが無効です',
      'Recommendations are added to the plan': 'プランに新しいおすすめが追加されました',
      'All rewards have been claimed; stay tuned for more in the future!':
          'この特典は終了しました。今後もご期待ください！',
      'All rewards have been redeemed': '限定枚数に達しました',
      'You cannot not visit this shop outside the business hours':
          '営業時間外のご来店はできません',
      'We are processing your request. We will get back to you soon.':
          'リクエストを処理中です。少々お待ちください。',
      'Loading': '読み込み中',
      "Invalid reward code": "無効なコードです",
      "Congrats! Your tokens are on the way": 'おめでとう！GGMTトークンが送られました',
      'Start from': 'スタート可能日時：',
      'Token number for this plan:': 'ゲットできるトークン数：',
      'Token number required: ': '交換に必要なトークン数：',
      'Reward Eligibility Period': '特典をゲットできる期間',
      'Exchange GGMT for reward': '特典と交換',
      'Your Matic Balance: ': 'あなたのMATIC数：',
      'Sufficient MATIC balance is required to transfer GGMT.\nPress the get button to get more if your MATIC balance is low':
          'トークンと特典を交換するには、MATIC数が必要だよ。\nMATIC数が少なくなったら、ゲットボタンをおしてね！',
      'If you want to learn more about MATIC 👉🏻': 'MATICについてもっと知りたい方は👉🏻',
      'AI recommended route': 'AIのおすすめルート',
      '👇what are you up to today?': '👇なにをする？',
      'Your recommendations are shown on the map👇': '今回まわるスポットはこの辺り👇',
      'Goal': 'クリア条件',
      'To get the tokens, visit all the spots on the plan':
          'トークンをゲットするには、プランのすべてのスポットを回ってね',
      'Take a picture so that the similarity between the set image and the taken picture is more than 50%':
          '設定された画像と撮影した画像の類似度が50%以上になるように写真をとろう',
      'Your GGMT Balance': 'ゲットしたトークン数',
      'Number of tokens required to redeem this reward': '特典の交換に必要なトークン数',
      'Oops, something went wrong': 'おと、エラーが発生しましたよ',
      //QR scan screen
      'Error of initializing the module': 'QRスキャン初期化エラー',
      'Camera permission denied': 'カメラの許可が拒否されました',
      'Error': 'エラー',
      'Scanning...': 'QRを読み取り中...',
      //home reward screen
      'After you visit, a QR scan button will show up. Scan QR code after your purchase to get more tokens':
          'スポットの写真を撮ると、QRボタンが出てくるよ！商品購入時はQRの提示で追加トークンゲット！',
      'Get limited rewards': '限定特典をゲット',
      'Get coupon rewards': '店舗クーポン特典をゲット',
      'Earn GGMT tokens and exchange them for cash!\nEvery 10 GGMT could provide a cash back ranging from ¥100 to ¥1000!':
          'GGMTを現金に交換しましょう！\n買い物後、10 GGMTトークンで¥100から1¥1000のキャッシュバックをゲット',
      'Applied': '使用済み',
      'Max #': '最大枚数',
      'Invalid QR code': 'QRコードが無効です',
      'Cashback History': 'キャッシュバック履歴',
      'Shop visits are required to get cashback':
          '店舗に訪れて、店舗写真を撮影し、キャッシュバックを受け取ろう',
      'Failed to get cashback': 'キャッシュバックの獲得に失敗した',
      'Unsent': '未発送',
      'Sent': '発送済み',
      '💰Cashback': '💰キャッシュバック',
      'Purchase Cashback': 'キャッシュバック・購入後',
      'Visit Cashback': 'キャッシュバック・ビジット後',
      'Available cashback today': '本日最大キャッシュバック数',
      'After purchasing, scan mawaroute qr code to get cashback':
          '買い物後、mawarouteのQRコードをスキャンして、キャッシュバックを受け取ろう',
      //recommend product screen
      "Take picture of the recommended product's price card to earn tokens":
          'おすすめ商品のプライスカードを撮影してトークンをゲットしよう',
      '🔍 Search': '🔍 検索',
      'Temporarily Save': '一時保存',
      'Finish': '終わる',
      'Shop Info': 'お店について',
      'Route should have at least one recommended product':
          'ルートは1つのおすすめ商品以上が必要です',
      //ChatWithAICharacterScreen
      'Why you might like it': 'あなたにおすすめの理由',
      'More similar recommendations': '類似したおすすめを見る',
      'Find similar results': '類似した結果を見る',
      'History': 'チャット履歴',
      'New Chat': '新しいチャット',
      'Please select your language': '言語を選んでください',
      'Avatar Language Setting': 'アバター言語設定',
      'All': 'すべて',
      'Popular': '大人気',
      'Latest': '最新公開',
      'Sightseeing': '観光',
      'Typing...': '入力中...',
      "If you'd like to unlock more capabilities, please contact us at":
          'アカウントへのアップグレードをご希望の方は、下記のメールアドレスまでご連絡ください',
      'Please note that these limitations are in place to ensure a quality experience for all users.':
          '全てのユーザー様に快適なご利用をお楽しみいただくための制約となりますので、ご理解の程、よろしくお願い申し上げます。',
      'Maximum number of chats you can initiate per day': '1日にチャットを開始できる上限数',
      'Maximum number of messages allows in each chat': '各チャットは、メッセージがを送れる上限数',
      'Maximum number of reasons for recommendation in each chat':
          'チャット1回につき、あなたにおすすめの理由を作成できる上限数',
      'Your Account Limitations': 'アカウントの制限について',
      'Usage Limits': '利用上限',
      'Find similar items': '類似アイテムを見る',
      " does not support\nvision recommendation": 'はビジョンレコメンド\nが使えません',
      //home v3
      "Expertise": '得意分野',
      "Chat": 'チャット',
      '/recommend_mode': '/レコメンドモード',
      '/chat_mode': '/チャットモード',
      'Enter Message': 'メッセージ入力',
      'Experiencing technical issues. Please try again later.':
          'エラーが発生しました。少し時間をおいて再度お試しください',
      'Error. Please try again later.': 'エラーが発生しました。少し時間をおいて再度お試しください',
      'Have you thought about exploring these keywords?': '一緒にもっと探しませんか？',
      'Internal Error. Please try again later': '内部エラー。後で再試行してください',
      //chat history screen
      'Select': '選択する',
      "It's quite now...": '今はとても静かだ...',
      'Language Setting': '言語設定',
      "Deleting chats": 'チャットを削除中',
      'Show More': 'もっと見る',
      //translate screen
      "Translate": '翻訳',
    },
  };
}
