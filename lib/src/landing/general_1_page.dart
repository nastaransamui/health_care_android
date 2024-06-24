

import 'package:flutter/material.dart';
import 'package:health_care/src/commons/silver_scaffold_wrapper.dart';

class General1Page extends StatefulWidget {
  static const String routeName = '/';
  const General1Page({
    super.key,
  });

  @override
  State<General1Page> createState() => _General1PageState();
}

class _General1PageState extends State<General1Page> {
  @override
  Widget build(BuildContext context) {
    return const SilverScaffoldWrapper(
      title: 'appTitle',
      children: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('General 1 Page'),
        ],
      ),
    );
  }
}
