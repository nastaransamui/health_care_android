import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:provider/provider.dart';

class SpecialitiesScrollView extends StatefulWidget {
  const SpecialitiesScrollView({super.key});

  @override
  State<SpecialitiesScrollView> createState() => _SpecialitiesScrollViewState();
}

class _SpecialitiesScrollViewState extends State<SpecialitiesScrollView> {
  @override
  Widget build(BuildContext context) {
    final specialities = Provider.of<SpecialitiesProvider>(context).specialities;
    var brightness = Theme.of(context).brightness;
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: 1,
      itemBuilder: (context, index) {
        return CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            scrollDirection: Axis.vertical,
            autoPlay: true,
          ),
          items: specialities.map<Widget>((i) {
            final name = context.tr(i.specialities);
            final imageSrc = i.image;
            final imageIsSvg = imageSrc.endsWith('.svg');
            final numberOfDoctors = i.usersId.length;
            return Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 5.0,
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Theme.of(context).primaryColor,
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageIsSvg
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                                  child: SvgPicture.network(
                                    imageSrc,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.fitHeight,
                                  ),
                                )
                              : SizedBox(
                                  width: 100.0,
                                  height: 100.0,
                                  child: CachedNetworkImage(
                                    imageUrl: imageSrc,
                                    fadeInDuration: const Duration(milliseconds: 0),
                                    fadeOutDuration: const Duration(milliseconds: 0),
                                    errorWidget: (ccontext, url, error) {
                                      return Image.asset(
                                        'assets/images/default-avatar.png',
                                      );
                                    },
                                  ),
                                ),
                          // Image.network(
                          //     imageSrc,
                          //     width: 100,
                          //     height: 100,
                          //   ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        textColor: brightness == Brightness.dark ? Colors.white : Colors.black,
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text('doctorsNumber').plural(
                          numberOfDoctors,
                          format: NumberFormat.compact(
                            locale: context.locale.toString(),
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_right)
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
