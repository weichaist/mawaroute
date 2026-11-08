import 'package:flutter/material.dart';

class SingleClickOutlinedButton extends StatefulWidget {
  final Widget child;
  final ButtonStyle? style;
  final Future<void> Function() onPressed;

  const SingleClickOutlinedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.style,
  });

  @override
  State<SingleClickOutlinedButton> createState() =>
      _SingleClickOutlinedButtonState();
}

class _SingleClickOutlinedButtonState extends State<SingleClickOutlinedButton> {
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
    return OutlinedButton(
      style: widget.style,
      onPressed: _onPressed,
      child: widget.child,
    );
  }
}
