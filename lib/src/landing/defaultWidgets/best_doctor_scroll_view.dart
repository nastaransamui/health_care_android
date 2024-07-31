import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:health_care/providers/doctors_provider.dart';
import 'package:provider/provider.dart';

class BestDoctorsScrollView extends StatefulWidget {
  const BestDoctorsScrollView({super.key});

  @override
  State<BestDoctorsScrollView> createState() => _BestDoctorsScrollViewState();
}

class _BestDoctorsScrollViewState extends State<BestDoctorsScrollView> {
  @override
  Widget build(BuildContext context) {
    final doctors = Provider.of<DoctorsProvider>(context).doctors;

    final isCollapsed = ValueNotifier<bool>(true);
    var brightness = Theme.of(context).brightness;
    return ValueListenableBuilder(
      valueListenable: isCollapsed,
      builder: (context, value, child) {
        return CarouselSlider(
          options: CarouselOptions(
            autoPlay: false,
            enlargeCenterPage: true,
            // viewportFraction: 1,
            // aspectRatio: 2.0,
            // initialPage: 1,
            height: 350,
          ),
          items: doctors.map<Widget>((i) {
            return Builder(
              builder: (BuildContext context) {
                var subheading = context.tr(i.specialities[0].specialities);
                final name = "${i.firstName} ${i.lastName}";
                var cardImage = NetworkImage(i.profileImage.isEmpty
                    ? 'http://admin-mjcode.ddns.net/assets/img/doctors/doctors_profile.jpg'
                    : '${i.profileImage}?random=${DateTime.now().millisecondsSinceEpoch}');
                var supportingText = i.aboutMe;
                return SizedBox(
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 70,
                          child: ListTile(
                            title: Text("Dr. $name"),
                            subtitle: Text(subheading),
                            trailing: const Icon(Icons.favorite_outline),
                          ),
                        ),
                        InkWell(
                          splashColor: Theme.of(context).hintColor,
                          onTap: () {},
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            child: Ink.image(
                              image: cardImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 50,
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    style: TextStyle(
                                      color: brightness == Brightness.dark ? Colors.white : Colors.black,
                                    ),
                                    text: supportingText.length <= 240 ? supportingText : supportingText.substring(0, 240),
                                  ),
                                  if (supportingText.length >= 240) ...[
                                    TextSpan(
                                        text: value ? ' ...Read more' : 'Read less',
                                        style: TextStyle(color: Theme.of(context).primaryColor),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            isCollapsed.value = !isCollapsed.value;
                                            showModalBottomSheet(
                                              context: context,
                                              useSafeArea: true,
                                              isDismissible: true,
                                              showDragHandle: true,
                                              constraints: const BoxConstraints(
                                                maxHeight: double.infinity,
                                              ),
                                              scrollControlDisabledMaxHeightRatio: 1,
                                              builder: (context) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(8),
                                                  child: Text(
                                                    supportingText,
                                                    textAlign: TextAlign.justify,
                                                    style: const TextStyle(
                                                      fontSize: 18.0,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).whenComplete(() {
                                              isCollapsed.value = !isCollapsed.value;
                                            });
                                          })
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
