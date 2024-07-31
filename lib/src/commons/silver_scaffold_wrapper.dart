import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/default_silver_app_bar.dart';

import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/end_drawer.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/commons/start_drawer.dart';

class SilverScaffoldWrapper extends StatefulWidget {
  final Widget children;
  final String title;

  const SilverScaffoldWrapper({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  State<SilverScaffoldWrapper> createState() => _SilverScaffoldWrapperState();
}

class _SilverScaffoldWrapperState extends State<SilverScaffoldWrapper> {
  final _globalKey = GlobalKey();
  final ScrollController defaultScrollController = ScrollController();
  double defaultScrollPercentage = 0;

  @override
  void dispose() {
    defaultScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      drawer: const StartDrawer(),
      endDrawer: const EndDrawer(),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            double per = 0;
            if (defaultScrollController.hasClients) {
              per = (defaultScrollController.offset / defaultScrollController.position.maxScrollExtent);
            }
            if (per >= 0) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    defaultScrollPercentage = 307 * per;
                  });
                }
              });
            }
            return false;
          },
          child: Stack(
            children: [
              CustomScrollView(
                controller: defaultScrollController,
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    floating: true,
                    delegate: DefaultSilverAppBar(
                      title: widget.title,
                      expandedHeight: expandedHeight,
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: widget.children,
                  ),
                ],
              ),
              ScrollButton(
                scrollController: defaultScrollController,
                scrollPercentage: defaultScrollPercentage,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(showLogin: true),
    );
  }
}
