import 'package:flutter/material.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/custom_app_bar.dart';
import 'package:health_care/src/commons/end_drawer.dart';
import 'package:health_care/src/commons/start_drawer.dart';

class ScaffoldWrapper extends StatefulWidget {
  final Widget children;
  final String title;

  const ScaffoldWrapper(
      {super.key, required this.children, required this.title});

  @override
  State<ScaffoldWrapper> createState() => _ScaffoldWrapperState();
}

class _ScaffoldWrapperState extends State<ScaffoldWrapper> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: widget.title),
        endDrawer: const EndDrawer(),
        drawer: const StartDrawer(),
        body: widget.children,
       bottomNavigationBar:  const BottomBar(showLogin: true),
      ),
    );
  }
}
