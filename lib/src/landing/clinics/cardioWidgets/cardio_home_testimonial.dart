import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/src/utils/gradient_text.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';

class CardioHomeTestimonial extends StatefulWidget {
  final double cardioHomeTestimonialHeight;
  final double componentsHeight;
  const CardioHomeTestimonial({
    super.key,
    required this.cardioHomeTestimonialHeight,
    required this.componentsHeight,
  });

  @override
  State<CardioHomeTestimonial> createState() => _CardioHomeTestimonialState();
}

class _CardioHomeTestimonialState extends State<CardioHomeTestimonial> {
  final PageController _testimonialPageController = PageController();
  @override
  Widget build(BuildContext context) {
    final List<Widget> fancyCards = <Widget>[
      testimonialCard(
        "http://web-mjcode.ddns.net/assets/images/clients/client-07.jpg",
        "Martin Philips",
        4.5,
        context.tr('cardioTestimentOne'),
        context.tr('lorem'),
      ),
      testimonialCard(
        "http://web-mjcode.ddns.net/assets/images/clients/client-08.jpg",
        "Christina Louis",
        4,
        context.tr('cardioTestimentTwo'),
        context.tr('lorem'),
      ),
      testimonialCard(
        "http://web-mjcode.ddns.net/assets/images/clients/client-09.jpg",
        "James Anderson",
        5,
        context.tr('cardioTestimentThree'),
        context.tr('lorem'),
      ),
    ];
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    return Positioned(
      right: 0,
      left: 0,
      top: useMobileLayout ? (MediaQuery.of(context).size.height < 700) ?  3000 : 2900 : 3430,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              title: Text(
                context.tr('cardioTestimonial'),
                style: GoogleFonts.robotoCondensed(
                  fontSize: 30.0,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            SizedBox(
              height: widget.cardioHomeTestimonialHeight,
              width: MediaQuery.of(context).size.width,
              child: StackedCardCarousel(
                initialOffset: 0,
                pageController: _testimonialPageController,
                items: fancyCards,
                spaceBetweenItems: 200,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget testimonialCard(String image, String name, double stars, String title, String content) {
    return Card(
      elevation: 14.0,
      child: SingleChildScrollView(
          child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  maxRadius: 30,
                  backgroundImage: NetworkImage(image),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: GradientText(
                      name,
                      style: const TextStyle(fontSize: 16),
                      gradient: LinearGradient(colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColorLight,
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: RatingStars(
                      value: stars,
                      starBuilder: (index, color) => Icon(
                        Icons.star,
                        color: color,
                      ),
                      starCount: 5,
                      starSize: 20,
                      maxValue: 5,
                      starSpacing: 2,
                      maxValueVisibility: false,
                      valueLabelVisibility: false,
                      animationDuration: const Duration(milliseconds: 1000),
                      starColor: Colors.yellow,
                    ),
                  ),
                ],
              )
            ],
          ),
          Text(
            title,
            style: TextStyle(fontSize: 22, color: Theme.of(context).primaryColor),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              content,
              textAlign: TextAlign.center,
            ),
          )
        ],
      )),
    );
  }
}
