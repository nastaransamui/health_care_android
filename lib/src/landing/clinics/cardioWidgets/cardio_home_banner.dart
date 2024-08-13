

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CardioHomeBanner extends StatefulWidget {
  final bool homeBannervisible;
  final double cardioHomeBannerHeight;
  const CardioHomeBanner({
    super.key,
    required this.homeBannervisible,
    required this.cardioHomeBannerHeight,
  });

  @override
  State<CardioHomeBanner> createState() => _CardioHomeBannerState();
}

class _CardioHomeBannerState extends State<CardioHomeBanner> with TickerProviderStateMixin {
  late final AnimationController _heartController = AnimationController(
    vsync: this,
    lowerBound: 0.75,
    upperBound: 1,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);
  late final Animation<double> _heartAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(_heartController);

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      right: 0,
      left: widget.homeBannervisible ? 0 : MediaQuery.of(context).size.width,
      duration: const Duration(milliseconds: 1000),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: widget.cardioHomeBannerHeight,
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 5.0,
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.all(0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/images/clinics/cardioBanner.png',
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 10.0,
                  child: ScaleTransition(
                    scale: _heartAnimation,
                    child: SvgPicture.asset(
                      'assets/icon/heart-2.svg',
                      width: 30,
                      height: 30,
                      fit: BoxFit.fitHeight,
                      colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, BlendMode.srcIn),
                    ),
                  ),
                ), //
                Positioned(
                  top: 18.0,
                  right: 10.0,
                  child: ScaleTransition(
                    scale: _heartAnimation,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ],
                          stops: const [
                            0.0,
                            0.5,
                          ],
                        ).createShader(bounds);
                      },
                      child: Image.network(
                        'http://web-mjcode.ddns.net/assets/images/bg/heart-bg.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.fitHeight,
                        opacity: const AlwaysStoppedAnimation(.5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4.0,
                  left: 50.0,
                  child: Text(
                    context.tr('everyBeat'),
                    style: GoogleFonts.robotoCondensed(fontSize: 20.0),
                  ),
                ),
                Positioned(
                  top: 100.0,
                  left: 10.0,
                  right: 10,
                  child: Text(
                    context.tr('preventive'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoCondensed(fontSize: 30.0),
                  ),
                ),
                Positioned(
                  top: 250.0,
                  left: 10.0,
                  right: 10,
                  child: Text(
                    context.tr('cardiac'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoCondensed(fontSize: 10.0),
                  ),
                ),
                Positioned(
                    top: 290.0,
                    left: 10.0,
                    right: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(150, 40),
                              elevation: 5.0,
                              foregroundColor: Colors.black,
                              animationDuration: const Duration(milliseconds: 1000),
                              backgroundColor: Theme.of(context).primaryColorLight,
                              shadowColor: Theme.of(context).primaryColorLight,
                            ),
                            child: Text(context.tr('consult')),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 40),
                                elevation: 5.0,
                                foregroundColor: Colors.black,
                                animationDuration: const Duration(milliseconds: 1000),
                                backgroundColor: Theme.of(context).primaryColor,
                                shadowColor: Theme.of(context).primaryColor,
                              ),
                              child: Text(context.tr('plan'))),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
