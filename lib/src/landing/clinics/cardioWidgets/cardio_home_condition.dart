import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/src/utils/gradient_text.dart';

class CardioHomeCondition extends StatefulWidget {
  final double cardioHomeConditionHeight;
  const CardioHomeCondition({super.key, required this.cardioHomeConditionHeight});

  @override
  State<CardioHomeCondition> createState() => _CardioHomeConditionState();
}

class _CardioHomeConditionState extends State<CardioHomeCondition> with TickerProviderStateMixin {
  late AnimationController _conditionController;
  late Animation<double> _heartConditionAnimation;
  @override
  void initState() {
    super.initState();
    _conditionController = AnimationController(
      vsync: this,
      lowerBound: 0.75,
      upperBound: 1,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _heartConditionAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(_conditionController);
  }

  @override
  void dispose() {
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      left: 0,
      top: 1350,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              title: Text(
                context.tr('needToKnow'),
                style: GoogleFonts.robotoCondensed(
                  fontSize: 35.0,
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            Container(
              height: widget.cardioHomeConditionHeight,
              width: MediaQuery.of(context).size.width,
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width / 2.2,
                            width: MediaQuery.of(context).size.width / 2.2,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.hardEdge,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).primaryColorLight,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Ink.image(
                                image: const NetworkImage(
                                  'http://web-mjcode.ddns.net/assets/images/features/feature-13.jpg',
                                ),
                                child: InkWell(
                                  splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                  onTap: () {
                                    showModalBottomSheet(
                                      useSafeArea: true,
                                      showDragHandle: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: ((builder) => bottomSheet(context.tr('heartValveDisease'), context.tr('heartValveContent'))),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width / 2.2,
                            width: MediaQuery.of(context).size.width / 2.2,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.hardEdge,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).primaryColorLight,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Ink.image(
                                image: const NetworkImage(
                                  'http://web-mjcode.ddns.net/assets/images/features/feature-15.jpg',
                                ),
                                child: InkWell(
                                  splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                  onTap: () {
                                    showModalBottomSheet(
                                      useSafeArea: true,
                                      showDragHandle: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: ((builder) => bottomSheet(context.tr('heartFailure'), context.tr('heartFailureContent'))),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width / 2.2,
                            width: MediaQuery.of(context).size.width / 2.2,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.hardEdge,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).primaryColorLight,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Ink.image(
                                image: const NetworkImage(
                                  'http://web-mjcode.ddns.net/assets/images/features/feature-14.jpg',
                                ),
                                child: InkWell(
                                  splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                  onTap: () {
                                    showModalBottomSheet(
                                      useSafeArea: true,
                                      showDragHandle: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: ((builder) => bottomSheet(context.tr('pacemakersDefibrillators'), context.tr('pacemakersContent'))),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, top: 8.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width / 2.2,
                            width: MediaQuery.of(context).size.width / 2.2,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.hardEdge,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Theme.of(context).primaryColorLight,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Ink.image(
                                image: const NetworkImage(
                                  'http://web-mjcode.ddns.net/assets/images/features/feature-16.jpg',
                                ),
                                child: InkWell(
                                  splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                  onTap: () {
                                    showModalBottomSheet(
                                      useSafeArea: true,
                                      showDragHandle: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: ((builder) => bottomSheet(context.tr('highBloodPressure'), context.tr('highBloodPressureContent'))),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSheet(String title, String text) {
    return SizedBox(
      height: MediaQuery.of(context).copyWith().size.height * 0.65,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GradientText(
              title,
              style: GoogleFonts.robotoCondensed(fontSize: 30),
              gradient: LinearGradient(colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColorLight,
              ]),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              context.tr(text),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: ScaleTransition(
                scale: _heartConditionAnimation,
                child: Image.network(
                  'http://web-mjcode.ddns.net/assets/images/bg/health-care.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.fitHeight,
                  opacity: const AlwaysStoppedAnimation(.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
