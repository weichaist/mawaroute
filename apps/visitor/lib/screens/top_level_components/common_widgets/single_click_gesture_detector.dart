import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

class SingleClickGestureDetector extends StatefulWidget {
  final Widget child;
  final ButtonStyle? style;
  final Future<void> Function() onPressed;

  const SingleClickGestureDetector({
    super.key,
    required this.child,
    required this.onPressed,
    this.style,
  });

  @override
  State<SingleClickGestureDetector> createState() =>
      _SingleClickGestureDetectorState();
}

class _SingleClickGestureDetectorState
    extends State<SingleClickGestureDetector> {
  bool isPressed = false;

  void _onPressed() async {
    if (!isPressed) {
      setState(() {
        isPressed = true;
      });
      await widget.onPressed();
      if (mounted) {
        setState(() {
          isPressed = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (isPressed)
            const CupertinoActivityIndicator(color: kPrimaryColor).frosted(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(12.0),
            ),
        ],
      ),
    );
  }
}
