import 'package:flutter/material.dart';

class DashboardMainCardUnderHeader extends StatelessWidget {
  final List<Widget> children;
  const DashboardMainCardUnderHeader({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      margin: const EdgeInsets.only(left: 4.0, right: 4.0, top: 0.0, bottom: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
