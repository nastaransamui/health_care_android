import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/src/utils/hex_to_color.dart';
import 'package:health_care/theme_config.dart';

class CardioHomePricing extends StatefulWidget {
  final double cardioHomePricingHeight;
  final String homeThemeName;
  const CardioHomePricing({
    super.key,
    required this.cardioHomePricingHeight,
    required this.homeThemeName,
  });

  @override
  State<CardioHomePricing> createState() => _CardioHomePricingState();
}

class _CardioHomePricingState extends State<CardioHomePricing> with TickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  bool yearlySelect = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      lowerBound: 0.75,
      upperBound: 1,
      duration: const Duration(milliseconds: 900),
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
    var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    return Positioned(
      top: useMobileLayout
          ? MediaQuery.of(context).size.height < 700
              ? (3700)
              : 3600
          : 4050,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: widget.cardioHomePricingHeight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                title: Text(
                  context.tr('ourPricing'),
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 30.0,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(context.tr('priceSelect')),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr('monthly')),
                  SizedBox(
                    height: 20,
                    width: 50,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: CupertinoSwitch(
                        value: yearlySelect,
                        onChanged: (value) {
                          setState(() {
                            yearlySelect = !yearlySelect;
                          });
                        },
                      ),
                    ),
                  ),
                  Text(context.tr("yearly")),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).primaryColorLight,
                          ),
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        visualDensity: const VisualDensity(horizontal: 4, vertical: -3),
                        padding: const EdgeInsets.all(0),
                        label: Text(context.tr('30%Discount'))),
                  )
                ],
              ),
              CarouselSlider(
                options: CarouselOptions(
                  height: 530.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: [
                  priceCard('free', 0),
                  priceCard('essentials', 50),
                  priceCard('team', 90),
                  priceCard('enterprises', 150),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget priceCard(
    String title,
    int price,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(18.0),
          gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, stops: const [
            0.0,
            0.5,
            1.0
          ], colors: [
            hexToColor(primaryLightColorCodeReturn(widget.homeThemeName)),
            hexToColor(secondaryLightColorCodeReturn(widget.homeThemeName)),
            hexToColor(primaryDarkColorCodeReturn(widget.homeThemeName))
          ]),
        ),
        margin: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    context.tr(title),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Image.network(
                      '${dotenv.env['webUrl']}/assets/images/bg/heart-plus.png',
                      opacity: const AlwaysStoppedAnimation(0.7),
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(40, -20),
                child: Text(
                  '$price \$',
                  style: const TextStyle(fontSize: 48, color: Colors.black),
                  textAlign: TextAlign.start,
                ),
              ),
              Transform.translate(
                offset: const Offset(19, -30),
                child: Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Text(
                    context.tr('perMonth'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColorLight],
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.maxFinite, 40),
                          side: const BorderSide(color: Colors.white, width: 2),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 8),
                      onPressed: () {},
                      child: Text(context.tr('choosePlan')),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                ),
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1.5, color: Colors.white))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          ScaleTransition(
                            scale: _heartAnimation,
                            child: SvgPicture.asset(
                              'assets/icon/heart-2.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.fitHeight,
                              colorFilter:
                                  ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(context.tr("cardioPrice1"))
                        ],
                      ),
                      Row(
                        children: [
                          ScaleTransition(
                            scale: _heartAnimation,
                            child: SvgPicture.asset(
                              'assets/icon/heart-2.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.fitHeight,
                              colorFilter:
                                  ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(context.tr("cardioPrice2"))
                        ],
                      ),
                      Row(
                        children: [
                          ScaleTransition(
                            scale: _heartAnimation,
                            child: SvgPicture.asset(
                              'assets/icon/heart-2.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.fitHeight,
                              colorFilter:
                                  ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(context.tr("cardioPrice3"))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 70,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 18.0),
                          child: Icon(Icons.add),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(context.tr("chatWidget"))
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 18.0),
                        child: Icon(Icons.add),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(context.tr("realTimeSupport"))
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
