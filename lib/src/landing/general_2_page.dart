

import 'package:flutter/material.dart';
import 'package:health_care/src/commons/silver_scaffold_wrapper.dart';

class General2Page extends StatefulWidget {
  static const String routeName = '/';
  const General2Page({
    super.key,
  });

  @override
  State<General2Page> createState() => _General2PageState();
}

class _General2PageState extends State<General2Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 2 Page'),
        ],
      ),
    );
  }
}
