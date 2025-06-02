import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/search_wrapper.dart';

class DefaultSilverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool hideTitleWhenExpanded;
  final String title;
  DefaultSilverAppBar({
    required this.expandedHeight,
    required this.title,
    this.hideTitleWhenExpanded = false,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;

    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        children: <Widget>[
          SizedBox(
            height: overlapsContent
                ? kToolbarHeight
                : appBarSize < kToolbarHeight
                    ? kToolbarHeight
                    : appBarSize,
            child: CustomAppBar(
              percent: percent,
              title: title,
            ),
          ),
          //Prevent finddoctor card to ovelap header buttons
          percent == 0 || overlapsContent
              ? const SizedBox(
                  height: 100,
                )
              : SearchWrapper(
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
  bool shouldRebuild(covariant DefaultSilverAppBar oldDelegate) {
    return oldDelegate.expandedHeight != expandedHeight || oldDelegate.title != title || oldDelegate.hideTitleWhenExpanded != hideTitleWhenExpanded;
  }
}

class CustomAppBar extends StatefulWidget {
  final double percent;
  final String title;
  const CustomAppBar({super.key, required this.percent, required this.title});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
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
        crossFadeState: widget.percent == 0 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 400),
        firstChild: Text(
          context.tr(widget.title),
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),
        ),
        secondChild: Text(
          context.tr('appTitle'),
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),
        ),
      ),
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
                    backgroundImage: AssetImage("assets/images/lang/en.png"),
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
                    backgroundImage: AssetImage("assets/images/lang/th.png"),
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
    );
  }
}
