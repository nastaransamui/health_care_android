
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/src/utils/gradient_text.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/theme_config.dart';
import 'package:onboarding_animation/onboarding_animation.dart';

class CardioHomeOurServices extends StatefulWidget {
  final bool homeBannervisible;
  final String homeThemeName;
  final double cardioHomeOurServicesHeight;
  const CardioHomeOurServices({
    super.key,
    required this.homeBannervisible,
    required this.homeThemeName,
    required this.cardioHomeOurServicesHeight,
  });

  @override
  State<CardioHomeOurServices> createState() => _CardioHomeOurServicesState();
}

class _CardioHomeOurServicesState extends State<CardioHomeOurServices> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      left: 0,
      top: 800,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: widget.cardioHomeOurServicesHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).primaryColorLight,
                width: 2.0,
              ),
              left: BorderSide(
                color: Theme.of(context).primaryColorLight,
                width: 2.0,
              ),
              bottom: BorderSide(
                color: Theme.of(context).primaryColorLight,
                width: 2.0,
              ),
              right: BorderSide(
                color: Theme.of(context).primaryColorLight,
                width: 2.0,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                title: Text(
                  context.tr('ourServices'),
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 50.0,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
              SizedBox(
                height: 430,
                width: MediaQuery.of(context).size.width,
                child: OnBoardingAnimation(
                  indicatorType: IndicatorType.swapDots,
                  controller: PageController(initialPage: 1),
                  pages: [
                    ...ourServicesList.map((i) {
                      return _getCardsCantainer(i['mainImage']!, context.tr(i['content']!), i['doctorImage']!, i['doctorName']!);
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCardsCantainer(
    String mainImage,
    String content,
    String doctorImage,
    String doctorName,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {},
          child: SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      mainImage,
                      fit: BoxFit.contain,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: const FaIcon(FontAwesomeIcons.solidHeart)),
                    ),
                  ],
                )),
          ),
        ),
        GradientText(
          content,
          style: GoogleFonts.robotoCondensed(fontSize: 30.0),
          gradient: LinearGradient(colors: [
            hexToColor(secondaryDarkColorCodeReturn(widget.homeThemeName)),
            Theme.of(context).primaryColorLight,
          ]),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(doctorImage),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('specialist')),
                      GradientText(
                        doctorName,
                        style: const TextStyle(fontSize: 16),
                        gradient: LinearGradient(colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColorLight,
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    // minimumSize: const Size(130, 40),
                    elevation: 5.0,
                    foregroundColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 1000),
                    backgroundColor: Theme.of(context).primaryColorLight,
                    shadowColor: Theme.of(context).primaryColorLight,
                  ),
                  child: Text(context.tr('consult')),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
