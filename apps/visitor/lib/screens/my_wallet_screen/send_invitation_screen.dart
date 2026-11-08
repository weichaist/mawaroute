import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/models/m_user.dart';
import 'package:mawaroute_visitor/theme/constants.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/send_invitation_controller.dart';
import '../../utilis/invitation_message.dart';
import '../../theme/size_config.dart';
import '../top_level_components/common_widgets/single_click_outlined_button.dart';

class SendInvitationScreen extends StatelessWidget {
  const SendInvitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SendInvitationController c = SendInvitationController.instance;
    c.init();
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: AutoSizeText(
                'Invite friend to earn bonus tokens'.tr,
                maxLines: 1,
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await buildInvitationDialog(c);
                  },
                  child: Text('Redeem Your Code'.tr),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      '🎁 Both you and your friend\nearn 10 tokens 🙋'.tr,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                    title: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: kDefaultPadding,
                        ),
                      ),
                      onPressed: () {
                        String codeMessage = invitationMessage(
                          c.userInvitationCode.value,
                        );
                        if (c.userInvitationCode.value.isNotEmpty) {
                          SharePlus.instance.share(
                            ShareParams(text: codeMessage),
                          );
                        }
                      },
                      child: Text(
                        'Send to your friend'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      title: Text('Your Invitation Code'.tr),
                      subtitle: SelectableText(
                        c.userInvitationCode.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kPrimaryColor,
                        ),
                      ),
                      trailing: SingleClickOutlinedButton(
                        child: Text('Copy'.tr),
                        onPressed: () async {
                          String codeMessage = invitationMessage(
                            c.userInvitationCode.value,
                          );
                          await Clipboard.setData(
                            ClipboardData(text: codeMessage),
                          ).then(
                            (value) => SmartDialog.showToast(
                              'Invitation code is copied'.tr,
                              alignment: Alignment.topCenter,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(color: Colors.transparent),
                  ListTile(title: Text('Friends joined with your code'.tr)),
                ],
              ),
            ),
            Obx(
              () => SliverList(
                delegate: SliverChildListDelegate([
                  ...List.generate(c.top30Friends.length, (index) {
                    MUser friend = c.top30Friends[index];
                    return ListTile(
                      leading: !friend.image.contains(".svg?")
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(friend.image),
                            )
                          : const CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/images/guru_guru_coin.png',
                              ),
                            ),
                      title: Text(friend.displayName),
                      subtitle: const Text('10 GGMT'),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: CupertinoColors.activeGreen,
                      ),
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> buildInvitationDialog(SendInvitationController controller) {
    return SmartDialog.show(
      animationType: SmartAnimationType.fade,
      alignment: Alignment.topCenter,
      builder: (_) => SafeArea(
        child: Container(
          width: getScreenWidth() - kDefaultPadding * 1.168 * 2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: Colors.transparent),
              ListTile(
                title: AutoSizeText(
                  'Enter invitation code from your friends'.tr,
                  maxLines: 1,
                ),
              ),
              ListTile(
                title: TextField(
                  onChanged: (value) {
                    controller.redeemedInvitationCode.value = value;
                  },
                ),
              ),
              ListTile(
                title: Row(
                  children: [
                    TextButton(
                      child: Text('Cancel'.tr),
                      onPressed: () {
                        SmartDialog.dismiss();
                      },
                    ),
                    TextButton(
                      child: Text('Submit'.tr),
                      onPressed: () async {
                        SmartDialog.dismiss();
                        if (controller.redeemedInvitationCode.value.length ==
                            8) {
                          await controller.saveRedeemedCode();
                        } else if (controller
                                .redeemedInvitationCode
                                .value
                                .length ==
                            7) {
                          await controller.saveSpecialCode();
                        } else {
                          SmartDialog.showNotify(
                            msg: "Invitation code is not found".tr,
                            notifyType: NotifyType.alert,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
