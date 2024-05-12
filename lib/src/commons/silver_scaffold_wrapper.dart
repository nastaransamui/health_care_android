import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/src/commons/bottom_bar.dart';
import 'package:health_care/src/commons/end_drawer.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      drawer: const StartDrawer(),
      endDrawer: const EndDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: CustomSilverAppBar(
                title: widget.title,
                expandedHeight: expandedHeight,
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: widget.children,
              // child: Container(
              //   margin: const EdgeInsets.only(top: kToolbarHeight),
              //   child: widget.children,
              // ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(showLogin: true),
    );
  }
}

class CustomSilverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool hideTitleWhenExpanded;
  final String title;
  CustomSilverAppBar({
    required this.expandedHeight,
    required this.title,
    this.hideTitleWhenExpanded = false,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    // final cardTopPosition = expandedHeight / 2 - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;

    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: overlapsContent ? kToolbarHeight : appBarSize < kToolbarHeight ? kToolbarHeight : appBarSize,
            child: AppBar(
              leading: Builder(builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(
                    Icons.menu,
                    size: 32,
                  ),
                );
              }),
              elevation: 10,
              title: AnimatedCrossFade(
                crossFadeState: percent == 0
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 400),
                firstChild: Text(
                  context.tr(title),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.black),
                ),
                secondChild: Text(
                  context.tr('appTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.black),
                ),
              ),
              // Opacity(
              //   opacity: percent,
              //   child: Text(
              //     context.tr(title),
              //     style: const TextStyle(
              //       color: Colors.black,
              //       fontSize: 24,
              //     ),
              //   ),
              // ),
              actions: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      icon: const Icon(
                        Icons.notifications,
                        size: 32,
                      ),
                      tooltip: 'More',
                    );
                  },
                ),
                PopupMenuButton<int>(
                  icon: const Icon(
                    Icons.language,
                    size: 32,
                    // color: hexToColor('#76ff02'),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/lang/en.png"),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('English'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/lang/th.png"),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text('Thai'),
                        ],
                      ),
                    )
                  ],
                  elevation: 4,
                  onSelected: (value) {
                    if (value == 1) {
                      context.setLocale(const Locale("en", 'US'));
                    } else if (value == 2) {
                      context.setLocale(const Locale("th", "TH"));
                    }
                  },
                ),
              ],
            ),
          ),
          //Prevent finddoctor card to ovelap header buttons
          percent == 0 || overlapsContent
              ? const SizedBox(
                  height: 100,
                )
              : FindDoctorsCard(
                  expandedHeight: expandedHeight,
                  shrinkOffset: shrinkOffset,
                  percent: percent,
                ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class FindDoctorsCard extends StatefulWidget {
  final double expandedHeight;
  final double shrinkOffset;
  final double percent;
  const FindDoctorsCard(
      {super.key,
      required this.expandedHeight,
      required this.shrinkOffset,
      required this.percent});

  @override
  State<FindDoctorsCard> createState() => _FindDoctorsCardState();
}

class _FindDoctorsCardState extends State<FindDoctorsCard> {
  var height = 200.0;
  static late String _chosenModel;
  bool selected = false;

  void init(BuildContext context) {
    _chosenModel = context.tr('none');
  }

  @override
  void didChangeDependencies() {
    context.locale.toString(); // OK
    _chosenModel = context.tr('none');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final cardTopPosition = widget.expandedHeight / 2 - widget.shrinkOffset;
    var brightness = Theme.of(context).brightness;
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: cardTopPosition > 0 ? cardTopPosition - 50 : 0,
      bottom: 0,
      child: Opacity(
        opacity: widget.percent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Card(
            // color: _color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(5.0, 20.0),
                          child: Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35.0),
                            ),
                            child: const SizedBox(
                              width: 45,
                              height: 45,
                              child: Icon(
                                Icons.search,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              hintText: context.tr('keyWord'),
                              hintStyle: const TextStyle(
                                fontSize: 12.0,
                              ),
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 32.0),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      height: 30.0,
                      child: CustomPaint(
                        size: const Size(1, double.infinity),
                        painter: DashedLineVerticalPainter(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Transform.translate(
                      offset: const Offset(0, -25),
                      child: Row(
                        children: [
                          Transform.translate(
                            offset: const Offset(6, 12),
                            child: Card(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35.0),
                              ),
                              child: const SizedBox(
                                width: 45,
                                height: 45,
                                child: Icon(
                                  Icons.event_available,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: DropdownButton<String>(
                              iconEnabledColor: Theme.of(context).primaryColor,
                              style: const TextStyle(
                                fontSize: 12.0,
                              ),
                              underline: Container(
                                height: 1.6,
                                color: Theme.of(context).primaryColor,
                              ),
                              isExpanded: true,
                              value: _chosenModel,
                              items: <String>[
                                context.tr('none'),
                                context.tr('available'),
                                context.tr('today'),
                                context.tr('tomorrow'),
                                context.tr('thisWeek'),
                                context.tr('thisMonth'),
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _chosenModel = newValue!;
                                });
                              },
                              hint: Text(
                                context.tr('availability'),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 30),
                        elevation: 5.0,
                      ),
                      onPressed: () {},
                      child: Text(
                        context.tr('searchNow'),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(double.maxFinite, 30),
                        elevation: 5.0,
                        foregroundColor: Theme.of(context).primaryColor,
                        animationDuration: const Duration(milliseconds: 1000),
                        backgroundColor: Theme.of(context).primaryColorLight,
                        shadowColor: Theme.of(context).primaryColorLight,
                      ),
                      onPressed: () {},
                      child: Text(
                        context.tr('filters'),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  // ignore: prefer_typing_uninitialized_variables
  final color;

  const DashedLineVerticalPainter({
    Key? key,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 5;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
