
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class CardioHomeSteps extends StatefulWidget {
  final double cardioHomeStepsHeight;
  final double componentsHeight;
  const CardioHomeSteps({
    super.key,
    required this.cardioHomeStepsHeight,
    required this.componentsHeight,
  });

  @override
  State<CardioHomeSteps> createState() => _CardioHomeStepsState();
}

class _CardioHomeStepsState extends State<CardioHomeSteps> {
  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    LottieDelegates lottieDeligates = LottieDelegates(values: [
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
    ]);
        var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    return Positioned(
      right: 0,
      left: 0,
      top: useMobileLayout ?2470 + 50 : 3000,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              title: Text(
                context.tr('steps'),
                style: GoogleFonts.robotoCondensed(
                  fontSize: 30.0,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                context.tr('stepsContent'),
                textAlign: TextAlign.justify,
                
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: widget.cardioHomeStepsHeight / 2,
              alignment: Alignment.topCenter,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: widget.cardioHomeStepsHeight / 2,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: [
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.2,
                          child: Center(
                            child: Lottie.asset(
                              'assets/images/heartRate.json',
                              animate: true,
                              fit: BoxFit.fill,
                              delegates: lottieDeligates,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColorLight,
                                        fontSize: 24,
                                      ),
                                      text: context.tr('stepChoose')),
                                  TextSpan(
                                    text: context.tr('lorem'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.2,
                          child: Center(
                            child: Lottie.asset(
                              'assets/images/heartRate.json',
                              animate: true,
                              fit: BoxFit.fill,
                              delegates: lottieDeligates,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColorLight,
                                        fontSize: 24,
                                      ),
                                      text: context.tr('stepAppointment')),
                                  TextSpan(
                                    text: context.tr('lorem'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.2,
                          child: Center(
                            child: Lottie.asset(
                              'assets/images/heartRate.json',
                              animate: true,
                              fit: BoxFit.fill,
                              delegates: lottieDeligates,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColorLight,
                                        fontSize: 24,
                                      ),
                                      text: context.tr('stepConsult')),
                                  TextSpan(
                                    text: context.tr('lorem'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).primaryColorLight,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.2,
                          child: Center(
                            child: Lottie.asset(
                              'assets/images/heartRate.json',
                              animate: true,
                              fit: BoxFit.fill,
                              delegates: lottieDeligates,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColorLight,
                                        fontSize: 24,
                                      ),
                                      text: context.tr('stepRecommendation')),
                                  TextSpan(
                                    text: context.tr('lorem'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
