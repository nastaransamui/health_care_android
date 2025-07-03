import 'package:flutter/material.dart';

class AvailableBadge extends StatelessWidget {
  const AvailableBadge({
    super.key,
    required this.bgColor,
    required this.textColor,
    required this.text,
  });
  final Color bgColor;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 3), // like `margin-bottom: 3px`
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // approx .65em / .35em
          decoration: BoxDecoration(
            color: bgColor, // bg-danger-light
            borderRadius: BorderRadius.circular(4), // .25rem
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12, // ~ .75em
              fontWeight: FontWeight.w700,
              height: 1.0, // line-height: 1
            ),
          ),
        ),
      ),
    );
  }
}
