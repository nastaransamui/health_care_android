import 'package:flutter/material.dart';
import 'package:health_care/src/features/auth/header_lottie.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
     return Container(
    margin: const EdgeInsets.only(
      top: 8.0,
    ),
    height: 180,
    child: const HeaderLottie()
  );
  }
}