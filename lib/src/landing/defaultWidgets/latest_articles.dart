import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_care/constants/global_variables.dart';

class LatestArticles extends StatelessWidget {
  const LatestArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1,
        aspectRatio: 2.0,
        // initialPage: 1,
        height: 550,
      ),
      items: latestArticlesList.map<Widget>(
        (e) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width - 16,
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).primaryColorLight,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 40,
                            child: ListTile(
                              title: Text(
                                e['writer'],
                                style: const TextStyle(fontSize: 13),
                              ),
                              // subtitle: Text(e['date']),
                              leading: const FaIcon(FontAwesomeIcons.user),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 30,
                            height: 40,
                            child: ListTile(
                              title: Text(
                                e['date'],
                                style: const TextStyle(fontSize: 13),
                              ),
                              leading: const FaIcon(FontAwesomeIcons.calendarAlt),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                        child: Center(
                          child: ListTile(
                              title: Text(
                            e['title'],
                             style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                          )),
                        ),
                      ),
                      InkWell(
                        splashColor: Theme.of(context).hintColor,
                        onTap: () {},
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 250,
                          child: Ink.image(
                            image: AssetImage(e['img']),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Text(
                        e['shortDescription'],
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(double.maxFinite, 30), elevation: 5.0, backgroundColor: Theme.of(context).primaryColorLight),
                            onPressed: () {},
                            child: Text(context.tr('readMoreButton'))),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ).toList(),
    );
  }
}
