import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../api/google_firestore_services.dart';
import '../models/place_model.dart';
import '../utility.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find<AuthController>();

  final _auth = FirebaseAuth.instance;
  final FireStoreService api = FireStoreService();

  RxString email = ''.obs;
  RxString password = ''.obs;
  RxString displayName = ''.obs;
  static const _successSignInUrl = '/home';
  static const _successSignOutUrl = '/auth';

  void setDisplayName() {
    if (_auth.currentUser != null) {
      if (displayName.value != "") {
        displayName.value = _auth.currentUser?.displayName ?? "";
      }
      if (displayName.value == "") {
        displayName.value = "User Taro";
      }
    }
  }

  Future<void> signIn() async {
    if (email.isEmpty || password.isEmpty) {
      showError('Please Enter email and password.'.tr);
      return;
    }
    try {
      showLoading('Please wait until Sign in is completed.'.tr);
      await _auth.setPersistence(Persistence.SESSION);
      await _auth.signInWithEmailAndPassword(
          email: email.value, password: password.value);
      PlaceModel place = await api.fetchPlace();
      if (place.uid!.isEmpty) {
        await _auth.signOut();
        throw FirebaseAuthException(message: 'Not valid account!', code: '404');
      }
      setDisplayName();
      Get.toNamed(_successSignInUrl);
      showSuccess('Successfully Logged In!'.tr);
    } on FirebaseAuthException catch (e) {
      showError('${'Invalid credentials!'.tr} \n ${e.message.toString()}');
    } catch (e) {
      showError('Something went wrong!'.tr);
    } finally {
      showDismiss();
    }
  }

  Future<void> signOut() async {
    try {
      showLoading('Please wait until Sign out process is completed.'.tr);
      await _auth.setPersistence(Persistence.SESSION);
      await _auth.signOut();
      Get.offAllNamed(_successSignOutUrl);
      showSuccess('Successfully Logged Out!'.tr);
    } on FirebaseAuthException catch (e) {
      showError(
          '${'Could not complete Sign out process!'.tr} \n ${e.message.toString()}');
    } catch (e) {
      showError('Something went wrong!'.tr);
    } finally {
      showDismiss();
    }
  }
}
