// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, sized_box_for_whitespace, must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/src/commons/bottom_bar.dart';

import 'package:lottie/lottie.dart';

class TopAnime extends StatelessWidget {
  Widget? child;
  Curve? curve;
  int seconds;
  int toppadding;

  TopAnime(this.seconds, this.toppadding,
      {super.key, required this.child, this.curve});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(seconds: seconds),
        curve: curve ?? Curves.bounceIn,
        builder: (BuildContext context, double value, child) {
          return Opacity(
            opacity: value,
            child: Padding(
              padding: EdgeInsets.only(top: value * toppadding),
              child: this.child,
            ),
          );
        },
        child: child);
  }
}

class BottomAnime extends StatelessWidget {
  Widget? child;
  Curve? curve;
  int seconds;
  int toppadding;

  BottomAnime(this.seconds, this.toppadding,
      {super.key, required this.child, this.curve});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        curve: curve ?? Curves.bounceIn,
        duration: Duration(seconds: seconds),
        builder: (BuildContext context, double value, child) {
          return Opacity(
            opacity: value,
            child: Padding(
              padding: EdgeInsets.only(bottom: value * toppadding),
              child: this.child,
            ),
          );
        },
        child: child);
  }
}

class NotFound404Error extends StatefulWidget {
  const NotFound404Error({super.key});

  @override
  State<NotFound404Error> createState() => _NotFound404ErrorState();
}

class _NotFound404ErrorState extends State<NotFound404Error> {
  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              context.tr('goBack'),
            ),
          ),
          bottomNavigationBar: BottomBar(
            showLogin: true,
          ),
          body: Container(
            width: currentWidth,
            height: currentHeight,
            color: Theme.of(context).canvasColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TopAnime(
                  1,
                  orientation == Orientation.landscape ? 1 : 25,
                  curve: Curves.fastOutSlowIn,
                  child: Container(
                    width: currentWidth,
                    height: orientation == Orientation.landscape
                        ? currentHeight / 4
                        : currentHeight / 3,
                    child: Lottie.asset(
                      "assets/images/health_error.json",
                      animate: true,
                    ),
                  ),
                ),
                TopAnime(
                  2,
                  5,
                  curve: Curves.fastOutSlowIn,
                  child: Column(
                    children: [
                      Text(
                        context.tr('errorPageTitle'),
                        style: TextStyle(
                          fontSize:
                              orientation == Orientation.landscape ? 20 : 45,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text(
                          context.tr('errorPageSubtitle'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                orientation == Orientation.landscape ? 8 : 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 40,),
                TopAnime(
                  2,
                  orientation == Orientation.landscape ? 1 : 30,
                  curve: Curves.fastOutSlowIn,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: Center(
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        minWidth: orientation == Orientation.landscape
                            ? currentWidth / 5
                            : currentWidth / 3,
                        height: orientation == Orientation.landscape
                            ? currentHeight / 20
                            : currentHeight / 16.5,
                        elevation: 3,
                        onPressed: () {
                           context.go('/');
                        },
                        color: Theme.of(context).primaryColorLight,
                        child: Text(
                          context.tr('home'),
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
