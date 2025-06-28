import 'package:flutter/material.dart';

class FilterShowTextWidget extends StatelessWidget {
  const FilterShowTextWidget({
    super.key,
    required bool isFinished,
    required this.genderValue,
    required this.availabilityValue,
    required this.specialitiesValue,
    required this.keyWordController,
    required this.countryValue,
    required this.stateValue,
    required this.cityValue,
  }) : _isFinished = isFinished;

  final bool _isFinished;
  final String? genderValue;
  final String? availabilityValue;
  final String? specialitiesValue;
  final TextEditingController keyWordController;
  final String? countryValue;
  final String? stateValue;
  final String? cityValue;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: !_isFinished ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 1000),
      firstChild: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${genderValue ?? ''} ${availabilityValue ?? ''}  ${specialitiesValue ?? ''} ${keyWordController.text}  ${countryValue ?? ''} ${stateValue ?? ''} ${cityValue ?? ''}',
        ),
      ),
      secondChild: const Text(''),
    );
  }
}
