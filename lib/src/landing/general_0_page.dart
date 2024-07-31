
import 'package:flutter/material.dart';
import 'package:health_care/services/user_data_service.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/default_silver_app_bar.dart';
import 'package:health_care/src/commons/end_drawer.dart';

import 'package:health_care/src/commons/start_drawer.dart';
import 'package:health_care/src/landing/general0Widgets/custom_general_wraper.dart';

class General0Page extends StatefulWidget {
  static const String routeName = '/';
  const General0Page({
    super.key,
  });

  @override
  State<General0Page> createState() => _General0PageState();
}

class _General0PageState extends State<General0Page> {
  final UserDataService userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    userDataService.fetchUserData(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: const StartDrawer(),
      endDrawer: const EndDrawer(),
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 68),
        child: const SafeArea(
          child: CustomAppBar(
            percent: 0,
            title: 'appTitle',
          ),
        ),
      ),
      body: SizedBox(width: MediaQuery.of(context).size.width, child: const CustomGeneralWrapper()),
      bottomNavigationBar: const BottomBar(showLogin: true),
    );

  }
}
