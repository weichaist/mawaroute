import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InviteFriendsListTile extends StatelessWidget {
  const InviteFriendsListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const Divider(color: Colors.transparent),
          Card(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/cool_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListTile(
                onTap: () {
                  Get.toNamed("/send-invitation");
                },
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ExtendedImage.asset(
                      'assets/images/guru_guru_coin.png',
                      height: 36,
                    ),
                  ],
                ),
                title: AutoSizeText(
                  'Invite your friends to join. Both you and your friend earn 10 GGMT tokens 🎁'
                      .tr,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.transparent),
          const Divider(color: Colors.transparent),
        ],
      ),
    );
  }
}
