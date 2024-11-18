

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardioHomeApointment extends StatelessWidget {
  final double cardioHomeApointmentHeight;
  const CardioHomeApointment({super.key, required this.cardioHomeApointmentHeight});

  @override
  Widget build(BuildContext context) {
            var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    return Positioned(
      top: useMobileLayout ? MediaQuery.of(context).size.height < 700 ? 3360 : 3250 : 3750,
      left: 8,
      right: 8,
      child: SizedBox(
        height: cardioHomeApointmentHeight,
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 18,
          color: Theme.of(context).primaryColor,
          margin: const EdgeInsets.all(0),
          child: Stack(
            children: [
              Positioned(
                top: cardioHomeApointmentHeight / 3,
                left: MediaQuery.of(context).size.width / 3,
                child: Opacity(
                  opacity: 0.2,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Theme.of(context).primaryColorLight],
                        stops: const [
                          0.0,
                        ],
                      ).createShader(bounds);
                    },
                    child: Image.network(
                      'https://health-care.duckdns.org/assets/images/bg/heart-plus.webp',
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Opacity(
                  opacity: 0.2,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Theme.of(context).primaryColorLight],
                        stops: const [
                          0.0,
                        ],
                      ).createShader(bounds);
                    },
                    child: Image.network(
                      'https://health-care.duckdns.org/assets/images/bg/hand.webp',
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                top: 8,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    textAlign: TextAlign.center,
                    context.tr('bookToday'),
                    style: GoogleFonts.robotoCondensed(fontSize: 30),
                  ),
                ),
              ),
              Positioned.fill(
                top: -50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      textAlign: TextAlign.justify,
                      context.tr('lorem'),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 40,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 12,
                        backgroundColor: Theme.of(context).primaryColorLight,
                      ),
                      onPressed: () {},
                      child: Text(context.tr("startAconsult")),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 2),
                        elevation: 12,
                        surfaceTintColor: Theme.of(context).canvasColor,
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).canvasColor,
                      ),
                      onPressed: () {},
                      child: Text(context.tr("clickOurPlan")),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
