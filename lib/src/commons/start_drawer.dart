import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:provider/provider.dart';

class StartDrawer extends StatefulWidget {
  const StartDrawer({super.key});

  @override
  State<StartDrawer> createState() => _StartDrawerState();
}

class _StartDrawerState extends State<StartDrawer> {
  int _selectedIndex = 0;
  final AuthService authService = AuthService();
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;
    var doctorsProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    var roleName = Provider.of<AuthProvider>(context).roleName;

    return SafeArea(
      child: Drawer(
        child: ListTileTheme(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(context.tr('appTitle')),
                accountEmail: Text(isLogin
                    ? '${roleName == 'patient' ? patientProfile?.userProfile.userName : doctorsProfile?.userProfile.userName}'
                    : ""),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage("assets/icon/icon.png"),
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/drawer.jpeg"),
                    fit: BoxFit.fill,
                  ),
                ),
                // otherAccountsPictures: [
                //   IconButton(
                //     key: icon_key,
                //     onPressed: () => updateTheme(),
                //     icon: Icon(
                //       icon,
                //       color: Colors.white,
                //       size: 30,
                //     ),
                //   ),
                // ],
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(context.tr('home')),
                selected: ModalRoute.of(context)?.settings.name == '/',
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(0);
                  // Then close the drawer
                  // Navigator.pop(context);
                  if (ModalRoute.of(context)?.settings.name != '/') {
                    Navigator.pushNamed(context, '/');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_box),
                title: const Text("Pharmacy"),
                // selected: _selectedIndex == 1,
                selected: ModalRoute.of(context)?.settings.name == '/pharmacy',
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(1);
                  // Then close the drawer
                  Navigator.pop(context);
                  if (ModalRoute.of(context)?.settings.name != '/pharmacy') {
                    Navigator.pushNamed(context, '/pharmacy');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_3x3_outlined),
                title: const Text("Blog"),
                selected: _selectedIndex == 2,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(1);
                  // Then close the drawer
                  Navigator.pop(context);
                  if (ModalRoute.of(context)?.settings.name != '/blog') {
                    Navigator.pushNamed(context, '/blog');
                  }
                  // // Then close the drawer
                  // Navigator.pop(context);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const BlogScreen()
                  //     ),
                  //   );
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text("Contact us"),
                selected: _selectedIndex == 3,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(3);
                  // Then close the drawer
                  // Navigator.pop(context);
                  if (ModalRoute.of(context)?.settings.name != '/contact') {
                    Navigator.pushNamed(context, '/contact');
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
