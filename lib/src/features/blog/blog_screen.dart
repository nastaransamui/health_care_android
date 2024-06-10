import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
// import 'package:health_care/src/commons/scaffold_wrapper.dart';

class BlogScreen extends StatelessWidget {
  static const String routeName = '/blog';
  const BlogScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'blog',
      children: Center(
        child: Text(context.tr('blog')),
      ),
    );
  }
}
