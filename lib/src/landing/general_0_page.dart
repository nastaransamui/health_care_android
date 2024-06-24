
import 'package:flutter/material.dart';
import 'package:health_care/src/commons/silver_scaffold_wrapper.dart';

class General0Page extends StatefulWidget {
  static const String routeName = '/';
  const General0Page({
    super.key,
  });

  @override
  State<General0Page> createState() => _General0PageState();
}

class _General0PageState extends State<General0Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 0 Page'),
        ],
      ),
    );
  }
}
