import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/constants/global_variables.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/clinics_provider.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/theme_config.dart';
import 'package:provider/provider.dart';

class StartDrawer extends StatefulWidget {
  const StartDrawer({super.key});

  @override
  State<StartDrawer> createState() => _StartDrawerState();
}

class _StartDrawerState extends State<StartDrawer> {
  final AuthService authService = AuthService();
  int? expandedIndex;
  @override
  Widget build(BuildContext context) {
    var isLogin = Provider.of<AuthProvider>(context).isLogin;
    var patientProfile = Provider.of<AuthProvider>(context).patientProfile;
    var doctorsProfile = Provider.of<AuthProvider>(context).doctorsProfile;
    var roleName = Provider.of<AuthProvider>(context).roleName;
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;
    final currentPath = GoRouter.of(context).routeInformationProvider.value.uri.path;
    final clinics = Provider.of<ClinicsProvider>(context).clinics;

    return SafeArea(
      child: Drawer(
        backgroundColor: Theme.of(context).canvasColor,
        child: ListTileTheme(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(context.tr('appTitle')),
                accountEmail:
                    Text(isLogin ? '${roleName == 'patient' ? patientProfile?.userProfile.userName : doctorsProfile?.userProfile.userName}' : ""),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage("assets/icon/icon.png"),
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/drawer.jpg"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              ...startDrawerTitleList.asMap().entries.map((entry) {
                int index = entry.key;
                var i = Map<String, dynamic>.from(entry.value);
                if (i['injectClinics'] == true) {
                  i['children'] = clinics.map((clinic) {
                    return {
                      'name': clinic.name,
                      'routeName': clinic.href,
                      'isClinic': true, // flag to handle special rendering
                      'active': clinic.active,
                      'image': clinic.image,
                      "hasThemeImage": clinic.hasThemeImage,
                    };
                  }).toList();
                }
                if (i.containsKey('children') && (i['children'] as List).isNotEmpty) {
                  // This item has sub-items
                  final isExpanded = expandedIndex == index;
                  return ExpansionTile(
                    leading: IconTheme(
                      data: IconThemeData(
                        size: 19, // adjust size here
                        color: Theme.of(context).primaryColorLight,
                      ),
                      child: i['icon'],
                    ),
                    textColor: Theme.of(context).primaryColor,
                    dense: true,
                    iconColor: Theme.of(context).primaryColor, // icon when open
                    collapsedIconColor: Theme.of(context).primaryColorLight,
                    title: Text(
                      context.tr(i['name']),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                    initiallyExpanded: i['children'].any((child) => currentPath == child['routeName']),
                    onExpansionChanged: (value) {
                      setState(() {
                        expandedIndex = value ? index : null;
                      });
                    },
                    children: i['children'].map<Widget>((child) {
                      final imagee = child['image'];
                      final bool hasThemeImage = child['hasThemeImage'] as bool? ?? false;
                      final bool isClinic = child['isClinic'] == true;
                      final bool isActive = child['active'] == true;
                      final primaryColorCode = primaryColorCodeReturn(homeThemeName);
                      final imageSrc = hasThemeImage
                          ? '${dotenv.env['webUrl']}${imagee.replaceAll('primaryMain', primaryColorCode)}'
                          : '${dotenv.env['webUrl']}$imagee';
                      return Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: ListTile(
                          leading: isClinic && isActive
                              ? Image.network(
                                  imageSrc,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                )
                              : (IconTheme(
                                  data: IconThemeData(
                                    size: 19, // adjust size here
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  child: child['icon'] ?? const Icon(Icons.chevron_right),
                                )),
                          title: Text(context.tr(child['name'])),
                          selected: currentPath == child['routeName'],
                          onTap: () {
                            Navigator.pop(context);
                            context.go(child['routeName']);
                          },
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  // Regular single-level ListTile
                  return ListTile(
                    leading: i['icon'],
                    title: Text(context.tr(i['name'])),
                    selected: currentPath == i['routeName'],
                    onTap: () {
                      Navigator.pop(context);
                      context.go(i['routeName']);
                    },
                  );
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}
