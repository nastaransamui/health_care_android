import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VitalImage extends StatelessWidget {
  const VitalImage({
    super.key,
    required this.image,
    required this.icon,
    required this.brightness,
  });

  final dynamic image;
  final dynamic icon;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return image!.isEmpty
        ? Lottie.asset(
            icon!,
            animate: true,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.colorFilter(
                  ['Line', '**'],
                  value: ColorFilter.mode(
                    Theme.of(context).primaryColorLight,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Layer 6 Outlines", '**'],
                  value: ColorFilter.mode(
                    brightness == Brightness.dark ? Colors.white : Colors.black,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Layer 5 Outlines", '**'],
                  value: ColorFilter.mode(
                    brightness == Brightness.dark ? Colors.white : Colors.black,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Layer 4 Outlines", '**'],
                  value: ColorFilter.mode(
                    brightness == Brightness.dark ? Colors.white : Colors.black,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Layer 3 Outlines", '**'],
                  value: ColorFilter.mode(
                    brightness == Brightness.dark ? Colors.white : Colors.black,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["therometer outline", '**'],
                  value: ColorFilter.mode(
                    brightness == Brightness.dark ? Colors.white : Colors.black,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Layer 2 Outlines", '**'],
                  value: ColorFilter.mode(
                    brightness == Brightness.dark ? Colors.white : Colors.black,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Sun", '**'],
                  value: ColorFilter.mode(
                    Theme.of(context).primaryColorLight,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Place 1", '**'],
                  value: ColorFilter.mode(
                    Theme.of(context).primaryColorLight,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Place 2", '**'],
                  value: ColorFilter.mode(
                    Theme.of(context).primaryColorLight,
                    BlendMode.src,
                  ),
                ),
                ValueDelegate.colorFilter(
                  ["Main", '**'],
                  value: ColorFilter.mode(
                    Theme.of(context).primaryColor,
                    BlendMode.src,
                  ),
                )
              ],
            ),
          )
        : Image.asset(image!);
  }
}
