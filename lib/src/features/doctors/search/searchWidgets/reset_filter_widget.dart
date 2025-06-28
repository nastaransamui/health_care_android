import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ResetFilterWidget extends StatelessWidget {
  const ResetFilterWidget({super.key, required this.isFinished, required this.localQueryParams, required this.resetFilterState});

  final bool isFinished;
  final Map<String, String> localQueryParams;
  final void Function(Map<String, String>) resetFilterState;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: !isFinished ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 1000),
      firstChild: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColorLight,
            fixedSize: const Size(double.maxFinite, 30),
            elevation: 5.0,
          ),
          onPressed: () {
            resetFilterState(localQueryParams);
          },
          child: Text(context.tr('reset')),
        ),
      ),
      secondChild: const Text(''),
    );
  }
}
