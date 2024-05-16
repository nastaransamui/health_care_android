import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/models/patients.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/src/utils/capitalize.dart';
import 'package:health_care/stream_socket.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:toastify/toastify.dart';
import 'package:badges/badges.dart' as badges;

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var profile = Provider.of<AuthProvider>(context).profile;
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
          if (!isLogin && widget.showLogin) ...[
            ...[
              IconButton(
                iconSize: 30.0,
                padding: const EdgeInsets.only(bottom: 28.0),
                icon: const Icon(Icons.login),
                onPressed: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  });
                },
              )
            ],
          ] else if (widget.showLogin) ...[
            Builder(builder: (context) {
              return GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: SizedBox(
                            width: 30.0,
                            height: 30.0,
                            child: (profile!.userProfile.profileImage.isEmpty)
                                ? Image.asset(
                                    "assets/images/default-avatar.png",
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(
                                    profile.userProfile.profileImage,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: badges.Badge(
                          position: badges.BadgePosition.topStart(),
                          badgeStyle: badges.BadgeStyle(
                            padding: const EdgeInsets.all(6),
                            badgeColor: Theme.of(context).primaryColorLight,
                          ),
                          badgeContent: Container(
                            height: 1,
                            width: 1,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  showPopover(
                    context: context,
                    bodyBuilder: (context) => const ListItems(),
                    // onPop: () => print('Popover was popped!'),
                    direction: PopoverDirection.bottom,
                    width: 200,
                    height: 240,
                    arrowHeight: 15,
                    arrowWidth: 30,
                    arrowDyOffset: -12,
                    backgroundColor: Theme.of(context).cardColor,
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}

class ListItems extends StatefulWidget {
  const ListItems({super.key});

  @override
  State<ListItems> createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  final AuthService authService = AuthService();

  @override
  void didChangeDependencies() {
    Navigator.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<AuthProvider>(context).profile;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
        ),
        children: [
          InkWell(
            onTap: () {},
            child: SizedBox(
              height: 70,
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: ClipOval(
                            child: SizedBox(
                              width: 70.0,
                              height: 70.0,
                              child: (profile!.userProfile.profileImage.isEmpty)
                                  ? Image.asset(
                                      "assets/images/default-avatar.png",
                                      fit: BoxFit.fill,
                                    )
                                  : Image.network(
                                      profile.userProfile.profileImage,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: badges.Badge(
                            position: badges.BadgePosition.topStart(),
                            badgeStyle: badges.BadgeStyle(
                              padding: const EdgeInsets.all(6),
                              badgeColor: Theme.of(context).primaryColorLight,
                            ),
                            badgeContent: Container(
                              height: 1,
                              width: 1,
                              color: Theme.of(context).primaryColorLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                    '${profile.userProfile.gender} ${profile.userProfile.firstName} ${profile.userProfile.lastName} \n \n'),
                            TextSpan(
                              text: context.tr(profile.roleName),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
          InkWell(
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  '/${profile.roleName}_dashboard') {
                Navigator.pushNamed(context, '/${profile.roleName}_dashboard');
              }
            },
            child: SizedBox(
              height: 30,
              child: Row(
                children: [
                  const Icon(Icons.dashboard),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(context.tr('dashboard')),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)?.settings.name !=
                  '/${profile.roleName}_profile') {
                Navigator.pushNamed(context, '/${profile.roleName}_profile');
              }
            },
            child: SizedBox(
              height: 30,
              child: Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(context.tr('profile')),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
          InkWell(
            onTap: () {
              logoutSubmit(context, profile);
            },
            child: SizedBox(
              height: 30,
              child: SizedBox(
              height: 30,
              child: Row(
                children: [
                  const Icon(Icons.logout),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(context.tr('logout')),
                  ),
                ],
              ),
            ),
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  void logoutSubmit(context, Patients? profile) {
    if (profile != null) {
      var id = profile.userId;
      var services = profile.services;
      Navigator.of(context).pop();
      socket.emit('logOutSubmit', {id, services});
      socket.on('logOutReturn', (data) {
        if (data['status'] != 200) {
          showToast(
            context,
            Toast(
              title: 'Failed',
              description: data['reason'] ?? context.tr('logoutFailed'),
              duration: Duration(milliseconds: 200.toInt()),
              lifeTime: Duration(
                milliseconds: 2500.toInt(),
              ),
            ),
          );
        } else {
          authService.logoutService(context);
        }
      });
    }
  }
}
