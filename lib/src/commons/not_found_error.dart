
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';

import 'package:lottie/lottie.dart';

class TopAnime extends StatelessWidget {
  final Widget? child;
  final Curve? curve;
  final int seconds;
  final int toppadding;

  const TopAnime(this.seconds, this.toppadding, {super.key, required this.child, this.curve});

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
 final Widget? child;
 final Curve? curve;
 final int seconds;
 final int toppadding;

  const BottomAnime(this.seconds, this.toppadding, {super.key, required this.child, this.curve});

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
    return OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
      return ScaffoldWrapper(
        title: context.tr('goBack'),
        children: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TopAnime(
                        1,
                        orientation == Orientation.landscape ? 1 : 25,
                        curve: Curves.fastOutSlowIn,
                        child: SizedBox(
                          width: currentWidth,
                          height: orientation == Orientation.landscape ? currentHeight / 4 : currentHeight / 3,
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
                                fontSize: orientation == Orientation.landscape ? 20 : 45,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: Text(
                                context.tr('errorPageSubtitle'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: orientation == Orientation.landscape ? 8 : 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TopAnime(
                        2,
                        orientation == Orientation.landscape ? 1 : 30,
                        curve: Curves.fastOutSlowIn,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          child: Center(
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              minWidth: orientation == Orientation.landscape ? currentWidth / 5 : currentWidth / 3,
                              height: orientation == Orientation.landscape ? currentHeight / 20 : currentHeight / 16.5,
                              elevation: 3,
                              onPressed: () {
                                context.go('/');
                              },
                              color: Theme.of(context).primaryColorLight,
                              child: Text(
                                context.tr('home'),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Ensure extra space to prevent tight squeeze
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
