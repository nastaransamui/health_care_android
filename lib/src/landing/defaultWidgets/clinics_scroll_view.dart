
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/src/utils/skip_nulls.dart';
import 'package:health_care/theme_config.dart';
import 'package:provider/provider.dart';

class ClinicsScrollView extends StatefulWidget {
  const ClinicsScrollView({super.key});

  @override
  State<ClinicsScrollView> createState() => _ClinicsScrollViewState();
}

class _ClinicsScrollViewState extends State<ClinicsScrollView> {
  @override
  Widget build(BuildContext context) {
    final clinics = Provider.of<ClinicsProvider>(context).clinics;
    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: skipNullsClinics(clinics).map<Widget>((i) {
        return Builder(
          builder: (BuildContext context) {
            final imagee = i.image;
            final hasThemeImage = i.hasThemeImage;
            var homeThemeName =
                Provider.of<ThemeProvider>(context).homeThemeName;
            final primaryColorCode = primaryColorCodeReturn(homeThemeName);
            final imageSrc = hasThemeImage
                ? '${dotenv.env['webUrl']}${imagee.replaceAll('primaryMain', primaryColorCode)}'
                : '${dotenv.env['webUrl']}$imagee';
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).primaryColorLight, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 5.0,
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.all(0),
                  child: InkWell(
                    splashColor: Theme.of(context).primaryColor,
                    onTap: () {
                      context.push(i.href);
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                          child: ListTile(
                            title: Text(context.tr(i.href)),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // color: Colors.amber,
                            margin: const EdgeInsets.only(
                              top: 20,
                              bottom: 10,
                            ),
                            height: 200,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageSrc,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            );
          },
        );
      }).toList(),
    );
  }
}
