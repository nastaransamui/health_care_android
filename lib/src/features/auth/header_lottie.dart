

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HeaderLottie extends StatelessWidget {
  const HeaderLottie({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      "assets/images/authHeader1.json",
      animate: true,
      delegates: LottieDelegates(
        values: [
          ValueDelegate.colorFilter(
            ['Shape 4', '**'],
            value: ColorFilter.mode(
              Theme.of(context).primaryColorLight,
              BlendMode.src,
            ),
          ),
          ValueDelegate.colorFilter(
            ["Shape 3", '**'],
            value: ColorFilter.mode(
              Theme.of(context).primaryColorLight,
              BlendMode.src,
            ),
          ),
          ValueDelegate.colorFilter(
            ["Shape 2", '**'],
            value: ColorFilter.mode(
              Theme.of(context).primaryColorLight,
              BlendMode.src,
            ),
          ),
          ValueDelegate.colorFilter(
            ["Shape 1", '**'],
            value: ColorFilter.mode(
              Theme.of(context).primaryColorLight,
              BlendMode.src,
            ),
          ),
          ValueDelegate.colorFilter(
            ["Layer 1", '**'],
            value: ColorFilter.mode(
              Theme.of(context).primaryColor,
              BlendMode.src,
            ),
          ),
        ],
      ),
    );
  }
}