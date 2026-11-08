import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mawaroute_visitor/models/m_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

import '../api/google_firestore_services.dart';
import '../config/app_config.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find<AuthController>();

  final _auth = FirebaseAuth.instance;
  FirestoreService f = FirestoreService();

  late final TextEditingController email = TextEditingController();
  late final TextEditingController password = TextEditingController();
  static const _successSignOutUrl = '/auth';

  final Rx<TextEditingController> phoneNumber = TextEditingController().obs;
  final Rx<MUser> profile = emptyMUser.obs;
  final smsCode = ''.obs;

  final countryCode = '+81'.obs;
  final countryEmoji = '🇯🇵'.obs;

  String phoneAuthVerificationId = '';
  int? authResendToken;

  Future<Wallet> _createWallet(String password) async {
    var range = Random.secure();
    EthPrivateKey credentials = EthPrivateKey.createRandom(range);
    Wallet wallet = Wallet.createNew(credentials, password, range);
    return wallet;
  }

  Future<void> updateUserprofile() async {
    MUser? user = await f.getUserDetails();
    if (user != null) {
      profile.value = user;
    }
  }

  Future _saveWallet() async {
    MUser? user = await f.getUserDetails();
    if (user == null) {
      SmartDialog.showLoading(msg: 'Processing...'.tr);
      Wallet wallet = await _createWallet(_auth.currentUser!.uid);
      // Lower-case, 0x-prefixed hex (the format web3dart 2.x produced).
      final address = wallet.privateKey.address.with0x;
      String privateKey = bytesToHex(wallet.privateKey.privateKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        "mawaroute_private_key_${_auth.currentUser!.uid}",
        privateKey,
      );
      await prefs.setString(
        "mawaroute_public_key_${_auth.currentUser!.uid}",
        address,
      );
      final seedLength = Random().nextInt(27);
      //Todo current rate is 50 calls per second. if our user number explodes, we might need to host the api
      String imageUrl = await createDiceAvatar(
        _auth.currentUser!.uid.substring(0, seedLength),
      );
      user = MUser(
        displayName: "mwr_${_auth.currentUser!.uid.substring(0, 5)}",
        publicAddress: address,
        image: imageUrl,
        signInAt: DateTime.now(),
      );
      await f.addUser(user.toJson());
      await f.addUsersPrivateKeyToCredentials({"key": privateKey});
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'TransferMatic',
      );
      await callable.call(<String, dynamic>{'transferAddress': address});
      SmartDialog.dismiss();
      Get.offAllNamed('/');
    } else {
      await f.updateUserSignInTimeStamp();
      Get.offAllNamed('/');
    }
    profile.value = user;
  }

  Future<String> createDiceAvatar(String seed) async {
    String imageUrl = AppConfig.defaultProfileImageUrl;
    String diceBearUrl = 'https://api.dicebear.com/7.x/thumbs/png?seed=$seed';
    try {
      String now = DateTime.now().toIso8601String();
      final response = await http.get(Uri.parse(diceBearUrl));
      Reference ref = FirebaseStorage.instance.ref(
        "v1-media/profile/img-$now.png",
      );
      await ref.putData(response.bodyBytes);
      imageUrl = await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return imageUrl;
  }

  void onClear() {
    email.clear();
    password.clear();
  }

  // For Phone signing
  String transformNumber() {
    return '${countryCode.value}${formatJPPhoneNumber(countryCode.value)}';
  }

  String formatJPPhoneNumber(String countryCode) {
    if (countryCode == '+81') {
      return phoneNumber.value.text.startsWith('0')
          ? phoneNumber.value.text.substring(1)
          : phoneNumber.value.text;
    } else {
      return phoneNumber.value.text;
    }
  }

  Future<void> sendPhoneVerificationCode() async {
    SmartDialog.showLoading(msg: 'Processing...'.tr);
    await _auth.verifyPhoneNumber(
      phoneNumber: transformNumber(),
      verificationCompleted: (PhoneAuthCredential credential) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
      verificationFailed: (FirebaseAuthException e) {
        SmartDialog.showNotify(
          msg: '${'An error has occurred'.tr}\n${e.message}',
          notifyType: NotifyType.failure,
        );
        if (kDebugMode) print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Update the UI - wait for the user to enter the SMS code
        SmartDialog.dismiss();
        SmartDialog.showNotify(
          msg: 'Verification Code Sent'.tr,
          notifyType: NotifyType.success,
        );
        phoneAuthVerificationId = verificationId;
        authResendToken = resendToken;
        Get.toNamed('/verify-phone-number');
        // Create a PhoneAuthCredential with the code
      },
    );
  }

  Future<void> phoneSignIn() async {
    if (smsCode.isEmpty || phoneAuthVerificationId.isEmpty) {
      SmartDialog.showNotify(
        msg: 'Please enter the verification code'.tr,
        notifyType: NotifyType.failure,
      );
      return;
    }
    try {
      SmartDialog.showLoading(msg: 'Signing in...'.tr);
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: phoneAuthVerificationId,
        smsCode: smsCode.value,
      );
      UserCredential userCredential = await _auth
          .signInWithCredential(phoneAuthCredential)
          .catchError((err) {
            throw err;
          });
      if (userCredential.user != null) {
        await _saveWallet();
      }
    } on FirebaseAuthException catch (e) {
      SmartDialog.showNotify(
        msg: '${'An error has occurred'.tr}\n${e.message}',
        notifyType: NotifyType.failure,
      );
    } catch (e) {
      SmartDialog.showNotify(
        msg: 'An error has occurred'.tr,
        notifyType: NotifyType.failure,
      );
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future<void> signOut() async {
    try {
      SmartDialog.showToast(
        'Please wait until sign out process is completed'.tr,
      );
      await _auth.signOut();
      Get.offAllNamed(_successSignOutUrl);
      SmartDialog.showNotify(
        msg: 'Successfully Logged Out!'.tr,
        notifyType: NotifyType.success,
      );
      profile.value = emptyMUser;
    } on FirebaseAuthException catch (e) {
      SmartDialog.showNotify(
        msg: '${'An error has occurred'.tr}\n${e.message.toString()}',
        notifyType: NotifyType.failure,
      );
    } catch (e) {
      SmartDialog.showNotify(
        msg: 'An error has occurred'.tr,
        notifyType: NotifyType.failure,
      );
    } finally {
      SmartDialog.dismiss();
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
