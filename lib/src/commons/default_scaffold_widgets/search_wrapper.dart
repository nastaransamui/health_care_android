
import 'package:flutter/material.dart';
import 'package:health_care/src/commons/default_scaffold_widgets/search_card.dart';

class SearchWrapper extends StatefulWidget {
  final double expandedHeight;
  final double shrinkOffset;
  final double percent;
  const SearchWrapper({
    super.key,
    required this.expandedHeight,
    required this.shrinkOffset,
    required this.percent,
  });

  @override
  State<SearchWrapper> createState() => _SearchWrapperState();
}

class _SearchWrapperState extends State<SearchWrapper> {
  var height = 200.0;

  String? specialitiesValue;
  String? genderValue;
  String? countryValue;
  String? stateValue;
  String? cityValue;

  void updateFilterState(
    String? specialities,
    String? gender,
    String? country,
    String? state,
    String? city,
  ) {
    setState(() {
      specialitiesValue = specialities;
      genderValue = gender;
      countryValue = country;
      stateValue = state;
      cityValue = city;
    });
  }

  void resetFilterState() {
    setState(() {
      specialitiesValue = null;
      genderValue = null;
      countryValue = null;
      stateValue = null;
      cityValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardTopPosition = widget.expandedHeight / 2 - widget.shrinkOffset;
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: cardTopPosition > 0 ? cardTopPosition - 70 : 0,
      bottom: 0,
      child: Opacity(
        opacity: widget.percent,
        child: SearchCard(
          specialitiesValue: specialitiesValue,
          genderValue: genderValue,
          countryValue: countryValue,
          stateValue: stateValue,
          cityValue: cityValue,
          updateFilterState: updateFilterState,
          resetFilterState: resetFilterState,
        ),
      ),
    );
  }
}
