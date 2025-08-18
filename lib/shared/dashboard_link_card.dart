
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardLinkCard extends StatelessWidget {
  const DashboardLinkCard({
    super.key,
    required this.theme,
    required this.element,
  });

  final ThemeData theme;
  final dynamic element;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.canvasColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColorLight, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: InkWell(
        splashColor: Theme.of(context).primaryColor,
        onTap: () {
          context.pushNamed(element['routeName']);
        },
        child: SizedBox(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: element['icon'],
            title: Text(context.tr(element['name'])),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
    );
  }
}
