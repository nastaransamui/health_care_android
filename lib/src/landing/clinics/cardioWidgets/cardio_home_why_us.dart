import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/theme_config.dart';

class CardioHomeWhyUs extends StatefulWidget {
  final bool homeBannervisible;
  final String homeThemeName;
  final double cardioHomeWhyUsHeight;
  const CardioHomeWhyUs({
    super.key,
    required this.homeBannervisible,
    required this.homeThemeName,
    required this.cardioHomeWhyUsHeight,
  });

  @override
  State<CardioHomeWhyUs> createState() => _CardioHomeWhyUsState();
}

class _CardioHomeWhyUsState extends State<CardioHomeWhyUs> {
  @override
  Widget build(BuildContext context) {

    return AnimatedPositioned(
      right: 0,
      left: widget.homeBannervisible ? 0 : MediaQuery.of(context).size.width,
      top: 350,
      duration: const Duration(milliseconds: 1000),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              title: Text(
                context.tr('whyUs'),
                style: GoogleFonts.robotoCondensed(
                  fontSize: 35.0,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            CarouselSlider(
                options: CarouselOptions(
                  height: widget.cardioHomeWhyUsHeight,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: [
                  ...whyUsList.map<Widget>((i) {
                    return Builder(builder: (context) {
                      final svgIcon = i['svgIcon'];
                      final title = i['title'];
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 5.0,
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.all(0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 28.0),
                                child: ClipPath(
                                  clipper: HexagonClipper(),
                                  child: Container(
                                    color: hexToColor(primaryDarkColorCodeReturn(widget.homeThemeName)),
                                    alignment: Alignment.center,
                                    height: 150,
                                    width: 130,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: SvgPicture.network(
                                        svgIcon!,
                                        colorFilter: ColorFilter.mode(Theme.of(context).primaryColorLight, BlendMode.srcIn),
                                        height: 56,
                                        width: 56,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  context.tr(title!),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.robotoCondensed(fontSize: 20.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  }),
                ]),
          ],
        ),
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path
      ..moveTo(size.width / 2, 0) // moving to topCenter 1st, then draw the path
      ..lineTo(size.width, size.height * .25)
      ..lineTo(size.width, size.height * .75)
      ..lineTo(size.width * .5, size.height)
      ..lineTo(0, size.height * .75)
      ..lineTo(0, size.height * .25)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
