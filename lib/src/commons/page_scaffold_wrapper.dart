import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/end_drawer.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/src/commons/start_drawer.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/default_silver_app_bar.dart';

class PageScaffoldWrapper extends StatefulWidget {
  final Widget children;
  final String title;
  const PageScaffoldWrapper({
    super.key,
    required this.children,
    required this.title,
  });

  @override
  State<PageScaffoldWrapper> createState() => _PageScaffoldWrapperState();
}

class _PageScaffoldWrapperState extends State<PageScaffoldWrapper> {
  final ScrollController pageScrollController = ScrollController();
  double pageScrollPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const StartDrawer(),
      endDrawer: const EndDrawer(),
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 68),
        child: SafeArea(
          child: CustomAppBar(
            percent: 0,
            title: widget.title,
          ),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: NotificationListener(
          onNotification: (notification) {
            double per = 0;
            if (pageScrollController.hasClients) {
              per = (pageScrollController.offset / pageScrollController.position.maxScrollExtent);
            }
            if (per >= 0) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    pageScrollPercentage = 307 * per;
                  });
                }
              });
            }
            return false;
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: pageScrollController,
                child: widget.children,
              ),
              ScrollButton(
                scrollController: pageScrollController,
                scrollPercentage: pageScrollPercentage,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBar(showLogin: true),
    );
  }
}
