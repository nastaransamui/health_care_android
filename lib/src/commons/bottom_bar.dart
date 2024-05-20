import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:toastify/toastify.dart';

import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/src/features/auth/login_screen.dart';
import 'package:health_care/stream_socket.dart';

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
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
  }

  @override
  void dispose() {
    super.dispose(); // Always call super.dispose() at the end.
  }

  @override
  void didChangeDependencies() {
    Navigator.of(context);
    super.didChangeDependencies();
    // authService.updateLiveAuth(context);
  }

  @override
  Widget build(BuildContext context) {
    var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;
    var doctorsProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    var roleName = Provider.of<AuthProvider>(context).roleName;
    late Image image = Image.asset(
      "assets/images/default-avatar.png",
      fit: BoxFit.fill,
    );

    if (isLogin) {
      if (roleName == 'patient') {
        if (patientProfile!.userProfile.profileImage.isEmpty) {
          image = Image.asset(
            "assets/images/default-avatar.png",
            fit: BoxFit.fill,
          );
        } else {
          image = Image.network(patientProfile.userProfile.profileImage);
        }
      } else if (roleName == 'doctors') {
        if (doctorsProfile!.userProfile.profileImage.isEmpty) {
          image = Image.asset(
            "assets/images/default-avatar.png",
            fit: BoxFit.fill,
          );
        } else {
          image = Image.network(doctorsProfile.userProfile.profileImage);
        }
      }
    }
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
                            child: image,
                          ),
                        ),
                      ),
                      // Align(
                      //   alignment: Alignment.topRight,
                      //   child: badges.Badge(
                      //     position: badges.BadgePosition.topStart(),
                      //     badgeStyle: badges.BadgeStyle(
                      //       padding: const EdgeInsets.all(6),
                      //       badgeColor: Theme.of(context).primaryColorLight,
                      //     ),
                      //     badgeContent: Container(
                      //       height: 1,
                      //       width: 1,
                      //       color: Theme.of(context).primaryColorLight,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                onTap: () {
                  showPopover(
                    context: context,
                    bodyBuilder: (context) => ListItems(image: image),
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
  final Image image;

  const ListItems({
    super.key,
    required this.image,
  });

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
    var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;
    var doctorsProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    var roleName = Provider.of<AuthProvider>(context).roleName;
    var brightness = Theme.of(context).brightness;
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
                              child: widget.image,
                            ),
                          ),
                        ),
                        // Align(
                        //   alignment: Alignment.topRight,
                        //   child: badges.Badge(
                        //     position: badges.BadgePosition.topStart(),
                        //     badgeStyle: badges.BadgeStyle(
                        //       padding: const EdgeInsets.all(6),
                        //       badgeColor: Theme.of(context).primaryColorLight,
                        //     ),
                        //     badgeContent: Container(
                        //       height: 1,
                        //       width: 1,
                        //       color: Theme.of(context).primaryColorLight,
                        //     ),
                        //   ),
                        // ),
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
                                style: TextStyle(
                                  color: brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                text:
                                    '${roleName == 'patient' && isLogin ? patientProfile?.userProfile.gender : doctorsProfile?.userProfile.gender} ${roleName == 'patient' ? patientProfile?.userProfile.firstName : doctorsProfile?.userProfile.firstName} \n ${roleName == 'patient' ? patientProfile?.userProfile.lastName : doctorsProfile?.userProfile.lastName} \n \n'),
                            TextSpan(
                              text: context.tr(roleName),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
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
                  '/${roleName}_dashboard') {
                Navigator.pushNamed(context, '/${roleName}_dashboard');
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
                  '/${roleName}_profile') {
                Navigator.pushNamed(context, '/${roleName}_profile');
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
              logoutSubmit(
                  context, patientProfile, doctorsProfile, isLogin, roleName);
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

  void logoutSubmit(
      context, patientProfile, doctorsProfile, isLogin, roleName) {
    late String services;
    late String userid;
    if (isLogin != null && isLogin) {
      if (roleName == 'patient') {
        services = patientProfile.services;
        userid = patientProfile.userId;
      } else if (roleName == 'doctors') {
        services = doctorsProfile.services;
        userid = doctorsProfile.userId;
      }
      Navigator.of(context).pop();
      socket.emit('logOutSubmit', {userid, services});
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
