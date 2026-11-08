import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../controllers/auth_controller.dart';
import '../../theme/constants.dart';
import '../top_level_components/common_widgets/single_click_outlined_button.dart';

class VerifyPhoneNumberScreen extends StatelessWidget {
  const VerifyPhoneNumberScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: VerifyPhoneNumberScreenBody());
  }
}

class VerifyPhoneNumberScreenBody extends StatelessWidget {
  const VerifyPhoneNumberScreenBody({super.key});
  @override
  Widget build(BuildContext context) {
    AuthController authController = AuthController.instance;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar.medium(title: Text('Enter the verification code'.tr)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 48, top: 18),
                  child: Text(
                    authController.transformNumber(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: MaterialPinField(
                    length: 6,
                    obscureText: false,
                    theme: MaterialPinTheme(
                      entryAnimation: MaterialPinAnimation.fade,
                      animationDuration: const Duration(milliseconds: 300),
                      fillColor: Colors.transparent,
                      focusedFillColor: Colors.transparent,
                      filledFillColor: Colors.transparent,
                      borderColor: kPrimaryColor.withValues(alpha: 0.3),
                      focusedBorderColor: kPrimaryColor,
                      filledBorderColor: kPrimaryColor,
                    ),
                    onChanged: (val) {
                      authController.smsCode.value = val;
                    },
                    keyboardType: TextInputType.number,
                  ),
                ),
                const ListTile(dense: true),
                ListTile(
                  title: const Text(''),
                  subtitle: ElevatedButton.icon(
                    onPressed: () async {
                      if (authController.smsCode.value.isNotEmpty) {
                        await authController.phoneSignIn();
                      }
                    },
                    icon: const Icon(Icons.lock_outline),
                    label: Text('Login'.tr),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: kDefaultPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SingleClickOutlinedButton(
                        onPressed: () async {
                          await authController.sendPhoneVerificationCode();
                        },
                        child: Text('Resend the code'.tr),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
