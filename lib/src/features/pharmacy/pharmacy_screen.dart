import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';

class PharmacyScreen extends StatelessWidget {
  static const String routeName = '/pharmacy';
  const PharmacyScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'pahrmacy',
      children: Center(
        child: Text(context.tr('pharmacy')),
      ),
    );
  }
}
