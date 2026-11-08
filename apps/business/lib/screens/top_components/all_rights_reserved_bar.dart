import 'package:flutter/material.dart';
import 'package:mawaroute_business/theme/constants.dart';

class BottomAllRightsReserved extends StatelessWidget {
  const BottomAllRightsReserved({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      height: 69 / 1.618,
      child: Column(
        children: [
          const Divider(
            color: kPrimaryColor,
            height: 0,
          ),
          SizedBox(
            height: 69 / 1.618,
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxWidth),
                child: const Center(
                  child: Text(
                    '©2023 MaWaRoute. All Rights reserved',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
