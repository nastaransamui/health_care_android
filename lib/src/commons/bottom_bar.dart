
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/router.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:toastify/toastify.dart';

import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
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
  String typeClicked = '';
    late bool isLogin;
  late dynamic patientProfile;
  late dynamic doctorsProfile;
  late String roleName;
  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
  }

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    isLogin = authProvider.isLogin;
    patientProfile = authProvider.patientProfile;
    doctorsProfile = authProvider.doctorsProfile;
    roleName = authProvider.roleName;
  }

  @override
  void dispose() {
    super.dispose(); // Always call super.dispose() at the end.
  }

  void authListClicked(String type, String roleName) {
    final RouteMatch lastMatch = router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch ? lastMatch.matches : router.routerDelegate.currentConfiguration;
    final String location = matchList.uri.toString();

    setState(() {
      typeClicked = type;
    });
    switch (type) {
      case 'dashboard':
        Navigator.pop(context);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (location != '/$roleName/dashboard') {
            context.push('/$roleName/dashboard');
          }
        });
        break;
      case 'profile':
        Navigator.pop(context);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (location != '/$roleName/dashboard/profile') {
            context.push('/$roleName/dashboard/profile');
          }
        });
        break;
      case 'logout':
        Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    late String imageUrl = '';
    if (isLogin) {
      if (roleName == 'patient') {
        if (patientProfile.userProfile.profileImage.isNotEmpty) {
          imageUrl = patientProfile.userProfile.profileImage;
        }
      } else if (roleName == 'doctors') {
        if (doctorsProfile.userProfile.profileImage.isNotEmpty) {
          imageUrl = doctorsProfile.userProfile.profileImage; //
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
            icon: const FaIcon(FontAwesomeIcons.home),
            onPressed: () {
              SchedulerBinding.instance.addPostFrameCallback(
                (_) {
                  context.go('/');
                },
              );
            },
          ),
          IconButton(
            iconSize: 30.0,
            padding: const EdgeInsets.only(bottom: 28.0),
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push(
                Uri(path: '/doctors/search', queryParameters: {}).toString(),
              );
            },
          ),
          IconButton(
            iconSize: 30.0,
            padding: const EdgeInsets.only(bottom: 28.0),
            icon: const Icon(Icons.notifications),
            onPressed: widget.showLogin
                ? () {
                    Scaffold.of(context).openEndDrawer();
                  }
                : null,
          ),
          if (!isLogin && widget.showLogin) ...[
            ...[
              IconButton(
                iconSize: 30.0,
                padding: const EdgeInsets.only(bottom: 28.0),
                icon: const Icon(Icons.login),
                onPressed: () {
                  context.go('/login');
                },
              )
            ],
          ] else if (widget.showLogin) ...[
            Builder(builder: (popoverContextOnly) {
              return GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: SizedBox(
                            width: 30.0,
                            height: 30.0,
                            // child: image,
                            child: imageUrl.isEmpty
                                ? roleName == 'doctors'
                                    ? Image.asset('assets/images/doctors_profile.jpg')
                                    : Image.asset(
                                        'assets/images/default-avatar.png',
                                      )
                                : CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    fadeInDuration: const Duration(milliseconds: 0),
                                    fadeOutDuration: const Duration(milliseconds: 0),
                                    errorWidget: (ccontext, url, error) {
                                      return roleName == 'doctors'
                                          ? Image.asset('assets/images/doctors_profile.jpg')
                                          : Image.asset(
                                              'assets/images/default-avatar.png',
                                            );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  showPopover(
                    context: popoverContextOnly,
                    bodyBuilder: (popoverContextOnly) => AuthList(
                      imageUrl: imageUrl,
                      authListClicked: authListClicked,
                    ),
                    onPop: () {
                      if (typeClicked == 'logout') {
                        late String services;
                        late String userid;
                        if (isLogin) {
                          if (roleName == 'patient' && patientProfile != null) {
                            services = patientProfile.services;
                            userid = patientProfile.userId;
                          } else if (roleName == 'doctors' && doctorsProfile != null) {
                            services = doctorsProfile.services;
                            userid = doctorsProfile.userId;
                          }
                        }
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
                            authService.logoutService();
                          }
                        });
                      }
                    },
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

class AuthList extends StatefulWidget {
  final String imageUrl;
  final Function authListClicked;

  const AuthList({
    super.key,
    required this.imageUrl,
    required this.authListClicked,
  });

  @override
  State<AuthList> createState() => _AuthListState();
}

class _AuthListState extends State<AuthList> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;
    var doctorsProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    var roleName = Provider.of<AuthProvider>(context).roleName;
    var brightness = Theme.of(context).brightness;
    var imageUrl = widget.imageUrl;
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
                    backgroundColor: Colors.transparent,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: ClipOval(
                            child: SizedBox(
                              width: 70.0,
                              height: 70.0,
                              child: imageUrl.isEmpty
                                  ? roleName == 'doctors'
                                      ? Image.asset('assets/images/doctors_profile.jpg')
                                      : Image.asset(
                                          'assets/images/default-avatar.png',
                                        )
                                  : CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      fadeInDuration: const Duration(milliseconds: 0),
                                      fadeOutDuration: const Duration(milliseconds: 0),
                                      errorWidget: (ccontext, url, error) {
                                        return Image.asset(
                                          'assets/images/default-avatar.png',
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        softWrap: true,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              style: TextStyle(
                                color: brightness == Brightness.dark ? Colors.white : Colors.black,
                              ),
                              text: '${roleName == 'patient' && isLogin ? patientProfile?.userProfile.gender : ''} ',
                            ),
                            TextSpan(
                              style: TextStyle(
                                color: brightness == Brightness.dark ? Colors.white : Colors.black,
                              ),
                              text: roleName == 'patient' ? '${patientProfile?.userProfile.fullName}' : 'Dr. ${doctorsProfile?.userProfile.fullName}',
                            ),
                            const TextSpan(text: '\n\n'),
                            TextSpan(
                              text: context.tr(roleName),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: brightness == Brightness.dark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
              widget.authListClicked('dashboard', roleName);
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
              widget.authListClicked('profile', roleName);
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
              widget.authListClicked('logout', roleName);
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
}
