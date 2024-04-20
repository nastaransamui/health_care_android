
import 'package:flutter/material.dart';
import 'package:health_care/src/features/auth/login_screen.dart';

class BottomBar extends StatefulWidget {

  final bool showLogin;

  const BottomBar({
    super.key,
    required this.showLogin,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: kBottomNavigationBarHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            iconSize: 30.0,
            padding: const EdgeInsets.only(bottom: 28.0),
            icon: const Icon(Icons.home),
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushNamed(context, '/');
              }
            },
          ),
          IconButton(
            iconSize: 30.0,
            padding: const EdgeInsets.only(bottom: 28.0),
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                // _myPage.jumpToPage(1);
              });
            },
          ),
          IconButton(
            iconSize: 30.0,
            padding: const EdgeInsets.only(bottom: 28.0),
            icon: const Icon(Icons.notifications),
            onPressed: () {
              setState(() {
                // _myPage.jumpToPage(2);
              });
            },
          ),
          if (widget.showLogin) ...[
            // if (widget.showLogin) ...[
            //   const CircleAvatar(
            //     backgroundImage: AssetImage("assets/images/avatar.jpg"),
            //   ),
            // ] else 
            ...[
              IconButton(
                iconSize: 30.0,
                padding: const EdgeInsets.only(bottom: 28.0),
                icon: const Icon(Icons.login),
                onPressed: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen()
                      ),
                    );
                  });
                },
              )
            ],
          ],
        ],
      ),
    );
  }
}
