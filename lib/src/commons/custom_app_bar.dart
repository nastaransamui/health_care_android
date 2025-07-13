import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 96,
      leading: Builder(
        builder: (context) {
          final canPop = ModalRoute.of(context)?.canPop ?? false;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canPop)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              Transform.translate(
                offset:  Offset(!canPop ? 2.0 :-12.0, 0), 
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ],
          );
        },
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          context.tr(widget.title),
          maxLines: 1,
        ),
      ),
      titleSpacing: 0,
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.notifications, size: 32),
              tooltip: 'More',
            );
          },
        ),
        PopupMenuButton<int>(
          color: Theme.of(context).cardColor,
          icon: const Icon(Icons.language, size: 32),
          offset: const Offset(0, 53),
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
