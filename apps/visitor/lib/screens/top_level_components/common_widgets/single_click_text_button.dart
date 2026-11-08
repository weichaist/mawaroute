import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mawaroute_visitor/theme/constants.dart';

class SingleClickTextButton extends StatefulWidget {
  final Widget child;
  final ButtonStyle? style;
  final Future<void> Function() onPressed;

  const SingleClickTextButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.style,
  });

  @override
  State<SingleClickTextButton> createState() => _SingleClickTextButtonState();
}

class _SingleClickTextButtonState extends State<SingleClickTextButton> {
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
    return Stack(
      alignment: Alignment.center,
      children: [
        TextButton(
          style: widget.style,
          onPressed: _onPressed,
          child: widget.child,
        ),
        if (isPressed)
          const CupertinoActivityIndicator(color: kPrimaryColor).frosted(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(9.0),
          ),
      ],
    );
  }
}
