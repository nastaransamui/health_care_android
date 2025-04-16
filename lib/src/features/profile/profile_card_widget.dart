import 'package:flutter/material.dart';

class ProfileCardWidget extends StatelessWidget {
  final String listTitle;
  final List<Widget> childrens;
  const ProfileCardWidget({
    super.key,
    required this.childrens,
    required this.listTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).canvasColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).primaryColorLight, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Column(
          children: [
            ListTile(
              title: Text(listTitle),
            ),
            ...childrens,
          ],
        ));
  }
}
