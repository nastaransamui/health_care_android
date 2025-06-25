import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';

class InformationScrollView extends StatelessWidget {
  const InformationScrollView({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.0,
        height: 110,
        enlargeCenterPage: true,
        scrollDirection: Axis.vertical,
        autoPlay: true,
      ),
      items: patinetDataScroll.map((i) {
        final name = context.tr(i['title']);
        return InkWell(
          splashColor: Theme.of(context).primaryColor,
          onTap: () {
            context.push(i['routeName']);
          },
          child: Card(
            color: theme.canvasColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: () {
                context.push(i['routeName']);
              },
              child: SizedBox(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: i['icon'],
                  title: Text(name),
                  trailing: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
