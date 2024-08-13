
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/src/utils/gradient_text.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CardioHomeSpecialist extends StatefulWidget {
  final double cardioHomeSpecialistHeight;
  const CardioHomeSpecialist({super.key, required this.cardioHomeSpecialistHeight});

  @override
  State<CardioHomeSpecialist> createState() => _CardioHomeSpecialistState();
}

class _CardioHomeSpecialistState extends State<CardioHomeSpecialist> with TickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      lowerBound: 0.75,
      upperBound: 1,
      duration: const Duration(milliseconds: 200),
    )..repeat(reverse: true);
    _heartAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(_heartController);
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specialities = Provider.of<SpecialitiesProvider>(context).specialities;

    return Positioned(
      right: 0,
      left: 0,
      top: 800 + MediaQuery.of(context).size.width + 530 + 130,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              title: Text(
                context.tr('ourSpecialistDoctors'),
                style: GoogleFonts.robotoCondensed(
                  fontSize: 30.0,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            CarouselSlider(
                options: CarouselOptions(
                  height: 580.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: [
                  if (specialities.isNotEmpty) ...[
                    ...cardioHomeSpecialistsList.map((i) {
                      String cardioImage = specialities.firstWhere((a) => a.specialities == 'Cardiologist').image;
                      return Builder(builder: (context) {
                        return Container(
                          height: widget.cardioHomeSpecialistHeight,
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
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
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  splashColor: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(20.0),
                                  onTap: () {},
                                  child: SizedBox(
                                    height: 400,
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(20.0),
                                            child: Image.network(
                                              i['mainImage'],
                                              height: 400,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            left: 10,
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                              ),
                                              height: 30,
                                              width: 60,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Text(
                                                    i['starsCount'].toString(),
                                                    style: GoogleFonts.robotoCondensed(color: Colors.black, fontSize: 20),
                                                  ),
                                                  const Icon(Icons.star)
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                                height: 30,
                                                width: 30,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black,
                                                ),
                                                child: const FaIcon(
                                                  FontAwesomeIcons.solidHeart,
                                                  size: 17,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        context.tr(i['specialities']),
                                        style: GoogleFonts.robotoCondensed(fontSize: 20.0),
                                      ),
                                    ),
                                    ScaleTransition(
                                      scale: _heartAnimation,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          cardioImage,
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: GradientText(
                                    i['doctorName'],
                                    style: GoogleFonts.robotoCondensed(fontSize: 20.0),
                                    gradient: LinearGradient(colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).primaryColorLight,
                                    ]),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 10),
                                      child: Container(
                                        height: 44.0,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.horizontal(
                                            left: Radius.circular(50.0),
                                            right: Radius.circular(50.0),
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).primaryColorLight,
                                              Theme.of(context).primaryColor,
                                            ],
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Text(context.tr('consult')),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Lottie.asset(
                                        height: 60,
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        'assets/images/heartBeat.json',
                                        animate: true,
                                        alignment: Alignment.centerLeft,
                                        delegates: LottieDelegates(values: [
                                          ValueDelegate.colorFilter(
                                            ['ellipes', '**'],
                                            value: ColorFilter.mode(
                                              Theme.of(context).primaryColorLight,
                                              BlendMode.src,
                                            ),
                                          ),
                                          ValueDelegate.colorFilter(
                                            ['shape', '**'],
                                            value: ColorFilter.mode(
                                              Theme.of(context).primaryColor,
                                              BlendMode.src,
                                            ),
                                          ),
                                          ValueDelegate.colorFilter(
                                            ['bg', '**'],
                                            value: ColorFilter.mode(
                                              Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                              BlendMode.src,
                                            ),
                                          ),
                                        ]),
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    })
                  ],
                ]),
          ],
        ),
      ),
    );
  }
}
