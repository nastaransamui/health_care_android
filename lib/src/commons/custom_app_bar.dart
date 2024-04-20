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
      title: Text(context.tr(widget.title)),
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
          icon: const Icon(Icons.language, size: 32),
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
