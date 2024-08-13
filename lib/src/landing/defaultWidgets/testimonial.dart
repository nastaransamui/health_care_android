import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';

class Testimonial extends StatelessWidget {
  const Testimonial({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> fancyCards = <Widget>[
      FancyCard(
        image: Image.asset(
          "assets/images/testimonial/client-03.jpg",
        ),
        title: context.tr('lorem'),
      ),
      FancyCard(
        image: Image.asset("assets/images/testimonial/client-04.jpg"),
        title: context.tr('lorem'),
      ),
      FancyCard(
        image: Image.asset("assets/images/testimonial/client-05.jpg"),
        title: context.tr('lorem'),
      ),
      FancyCard(
        image: Image.asset("assets/images/testimonial/client-07.jpg"),
        title: context.tr('lorem'),
      ),
    ];

    return StackedCardCarousel(
      initialOffset: 1,
      items: fancyCards,
    );
  }
}

class FancyCard extends StatelessWidget {
  const FancyCard({
    super.key,
    required this.image,
    required this.title,
  });

  final Image image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).primaryColorLight,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: image,
            ),
            Text(
              textAlign: TextAlign.center,
              title,
            ),
          ],
        ),
      ),
    );
  }
}
