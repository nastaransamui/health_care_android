
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/scheduler.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final List<Color> colors;

  const GradientButton({super.key, required this.child, required this.onPressed, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(60),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.07,
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
