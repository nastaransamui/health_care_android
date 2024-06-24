import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                    image: AssetImage("assets/images/drawer.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(context.tr('home')),
                selected: ModalRoute.of(context)?.settings.name == '/',
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);
                  context.go('/');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_box),
                title: const Text("Pharmacy"),
                selected: ModalRoute.of(context)?.settings.name == '/pharmacy',
                onTap: () {
                  _onItemTapped(1);
                  Navigator.pop(context);
                  context.go('/pharmacy');
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_3x3_outlined),
                title: const Text("Blog"),
                selected: _selectedIndex == 2,
                onTap: () {
                  _onItemTapped(1);
                  Navigator.pop(context);
                  context.go('/blog');
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text("Contact us"),
                selected: _selectedIndex == 3,
                onTap: () {
                  _onItemTapped(3);
                   Navigator.pop(context);
                  context.go('/contact');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
