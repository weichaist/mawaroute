import 'package:flutter/material.dart';
import 'package:mawaroute_business/theme/constants.dart';

class WebMenuItem extends StatefulWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;
  const WebMenuItem({
    super.key,
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  State<WebMenuItem> createState() => _WebMenuItemState();
}

class _WebMenuItemState extends State<WebMenuItem> {
  bool _isHover = false;
  Color _borderColor() {
    if (widget.isActive) {
      return kPrimaryColor;
    } else if (!widget.isActive && _isHover) {
      return kPrimaryLightColor;
    }
    return kBgColor;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      splashColor: kBgColor,
      highlightColor: kBgColor,
      hoverColor: kBgColor,
      borderRadius: BorderRadius.circular(12),
      onHover: (value) {
        setState(() {
          _isHover = value;
        });
      },
      child: AnimatedContainer(
        duration: kDefaultDuration,
        padding: const EdgeInsets.symmetric(
            vertical: 3.6, horizontal: 3.6 * 1.618 * 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderColor()),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
              color: widget.isActive ? kPrimaryColor : kTextColor,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 15),
        ),
      ),
    );
  }
}
