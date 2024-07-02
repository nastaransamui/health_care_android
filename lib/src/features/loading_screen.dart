
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            height: 200,
            child:  Opacity(
              opacity: 0.3,
              child: Center(
                child:
                    SpinKitFadingCube(color: Theme.of(context).primaryColor, size: 50.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}