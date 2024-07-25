

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:health_care/models/cities.dart';
import 'package:health_care/models/countries.dart';
import 'package:health_care/models/specialities.dart';
import 'package:health_care/models/states.dart';
import 'package:health_care/providers/specialities_provider.dart';
import 'package:health_care/services/specialities_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';

class FilterScreen extends StatefulWidget {
  final String title;
  final String description;
  final dynamic onSubmit;
  final Function onReset;
  final String? genderValue;
  final String? specialitiesValue;
  final String? countryValue;
  final String? stateValue;
  final String? cityValue;
  const FilterScreen({
    super.key,
    required this.title,
    required this.description,
    required this.onSubmit,
    required this.onReset,
    required this.genderValue,
    required this.specialitiesValue,
    required this.countryValue,
    required this.stateValue,
    required this.cityValue,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final SpecialitiesService specialitiesService = SpecialitiesService();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  String? genderValue;
  String? specialitiesValue;
  String? countryValue;
  String? stateValue;
  String? cityValue;
  @override
  void initState() {
    super.initState();
    genderValue = widget.genderValue;
    specialitiesValue = widget.specialitiesValue;
    countryValue = widget.countryValue;
    stateValue = widget.stateValue;
    cityValue = widget.cityValue;
    countryController.text = widget.countryValue ?? '';
    stateController.text = widget.stateValue ?? '';
    cityController.text = widget.cityValue ?? '';
    specialitiesService.getSpecialitiesData(context);
  }

  @override
  void dispose() {
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    super.dispose(); // Always call super.dispose() at the end.
  }

  Future<List<Countries>> countrySuggestionsCallback(String search) async {
    if (search.isNotEmpty) {
      socket.emit('countrySearch', {
        'searchText': search,
        "fieldValue": 'name',
        "state": "",
        "country": ""
      });
    }
    List<Countries> countries = [];
    socket.on(
      'countrySearchReturn',
      (data) async {
        if (data['status'] == 200) {
          countries.clear();
          var m = data['country'];

          for (int i = 0; i < m.length; i++) {
            final countriesFromAdmin = Countries.fromMap(m[i]);
            countries.add(countriesFromAdmin);
          }

          return countries;
        } else {
          return countries;
        }
      },
    );
    return Future<List<Countries>>.delayed(
      const Duration(milliseconds: 300),
      () async {
        return countries.toList();
      },
    );
  }

  Future<List<States>> stateSuggestionsCallback(String search) async {
    if (search.isNotEmpty) {
      socket.emit('stateSearch', {
        'searchText': search,
        "fieldValue": 'name',
        "country": countryValue,
      });
    }
    List<States> states = [];
    socket.on(
      'stateSearchReturn',
      (data) async {
        if (data['status'] == 200) {
          states.clear();
          var m = data['state'];
          for (int i = 0; i < m.length; i++) {
            final statesFromAdmin = States.fromMap(m[i]);
            states.add(statesFromAdmin);
          }

          return states;
        } else {
          return states;
        }
      },
    );
    return Future<List<States>>.delayed(
      const Duration(milliseconds: 300),
      () async {
        return states.toList();
      },
    );
  }

  Future<List<Cities>> citySuggestionsCallback(String search) async {
    if (search.isNotEmpty) {
      socket.emit('citySearch', {
        'searchText': search,
        "fieldValue": 'name',
        "country": countryValue,
        "state": stateValue,
      });
    }
    List<Cities> cities = [];
    socket.on(
      'citySearchReturn',
      (data) async {
        if (data['status'] == 200) {
          cities.clear();
          var m = data['city'];
          for (int i = 0; i < m.length; i++) {
            final citiesFromAdmin = Cities.fromMap(m[i]);
            cities.add(citiesFromAdmin);
          }

          return cities;
        } else {
          return cities;
        }
      },
    );
    return Future<List<Cities>>.delayed(
      const Duration(milliseconds: 300),
      () async {
        return cities.toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final specialities =
        Provider.of<SpecialitiesProvider>(context).specialities;
    var brightness = Theme.of(context).brightness;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColorLight,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            context.tr("filters"),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).primaryColorLight),
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          context.tr("chooseFilters"),
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      if (specialities.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 28.0, left: 8.0, right: 8.0, bottom: 8.0),
                          child: SearchChoices.single(
                            closeButton: context.tr('close'),
                            iconSize: 24.0,
                            fieldDecoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                                top: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                                left: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                                right: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            displayClearIcon:
                                specialitiesValue == null ? false : true,
                            icon: null,
                            clearIcon: Icon(
                              Icons.clear,
                              color: Theme.of(context).primaryColorLight,
                            ),
                            items: specialities.map<DropdownMenuItem<String>>(
                              (Specialities value) {
                                var brightness = Theme.of(context).brightness;
                                final name = context.tr(value.specialities);
                                final imageSrc = value.image;
                                final imageIsSvg = imageSrc.endsWith('.svg');
                                return DropdownMenuItem<String>(
                                  value: value.specialities,
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: imageIsSvg
                                            ? SvgPicture.network(
                                                imageSrc, //?random=${DateTime.now().millisecondsSinceEpoch}
                                                width: 20,
                                                height: 20,
                                                fit: BoxFit.fitHeight,
                                              )
                                            : Image.network(
                                                imageSrc, //?random=${DateTime.now().millisecondsSinceEpoch}
                                                width: 20,
                                                height: 20,
                                              ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        name,
                                        style: TextStyle(
                                            color: brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                            value: specialitiesValue,
                            hint: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                tr('specialities'),
                              ),
                            ),
                            onClear: () {
                              setState(() {
                                specialitiesValue = null;
                              });
                            },
                            searchHint: tr('specialities'),
                            onChanged: (value) {
                              setState(() {
                                specialitiesValue = value;
                              });
                            },
                            isExpanded: true,
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 95.0,
                          left: 8.0,
                          right: 8.0,
                          bottom: 8.0,
                        ),
                        child: SearchChoices.single(
                          iconSize: 24.0,
                          fieldDecoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                              top: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                              left: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                              right: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                          closeButton: context.tr('close'),
                          displayClearIcon: genderValue == null ? false : true,
                          icon: null,
                          clearIcon: Icon(
                            Icons.clear,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          items: <Map<String, String>>[
                            {"title": context.tr('Mr'), 'icon': '👨'},
                            {"title": context.tr('Mrs'), 'icon': '👩'},
                            {"title": context.tr('Mss'), 'icon': '👩'},
                          ].map<DropdownMenuItem<String>>(
                            (Map<String, String> value) {
                              var brightness = Theme.of(context).brightness;
                              return DropdownMenuItem<String>(
                                value: value['title'],
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: Text(value['icon']!),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      value['title']!,
                                      style: TextStyle(
                                        color: brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                          value: genderValue,
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              tr('gender'),
                            ),
                          ),
                          searchHint: tr('gender'),
                          onClear: () {
                            setState(() {
                              genderValue = null;
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              genderValue = value;
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 173.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: TypeAheadField<Countries>(
                          controller: countryController,
                          hideWithKeyboard: false,
                          suggestionsCallback: (search) =>
                              countrySuggestionsCallback(search),
                          itemSeparatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                          emptyBuilder: (context) => ListTile(
                            title: Text(
                              context.tr('noItem'),
                            ),
                          ),
                          errorBuilder: (context, error) {
                            return ListTile(
                              title: Text(
                                error.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            );
                          },
                          loadingBuilder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context).primaryColorLight,
                                  )
                                ],
                              ),
                            );
                          },
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              focusNode: focusNode,
                              autofocus: false,
                              onChanged: (value) {
                                countryController.text = value;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 8,
                                ),
                                suffixIcon: countryValue == null
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          countryController.text = '';
                                          stateController.text = '';
                                          cityController.text = '';
                                          setState(() {
                                            countryValue = null;
                                            stateValue = null;
                                            cityValue = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                      ),
                                border: const OutlineInputBorder(),
                                labelStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                labelText: context.tr('country'),
                              ),
                            );
                          },
                          decorationBuilder: (context, child) {
                            return Material(
                              type: MaterialType.card,
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              borderOnForeground: true,
                              child: child,
                            );
                          },
                          offset: const Offset(0, 2),
                          constraints: const BoxConstraints(maxHeight: 500),
                          itemBuilder: (context, country) {
                            List<InlineSpan> temp = highlightText(
                                countryController.text,
                                country.name,
                                brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                Theme.of(context).primaryColor);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    country.emoji,
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: ListTile(
                                    title: Text.rich(
                                      TextSpan(
                                        children: temp,
                                      ),
                                    ),
                                    subtitle: Text(
                                      country.subtitle ??
                                          '{$country.region} - ${country.subregion}',
                                      style: TextStyle(
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                          onSelected: (country) {
                            setState(() {
                              countryValue = country.name;
                            });
                            countryController.text =
                                '${country.emoji} - ${country.name}';
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 245.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: TypeAheadField<States>(
                          controller: stateController,
                          hideWithKeyboard: false,
                          suggestionsCallback: (search) =>
                              stateSuggestionsCallback(search),
                          itemSeparatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                          emptyBuilder: (context) => ListTile(
                            title: Text(
                              context.tr('noItem'),
                            ),
                          ),
                          errorBuilder: (context, error) {
                            return ListTile(
                              title: Text(
                                error.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            );
                          },
                          loadingBuilder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context).primaryColorLight,
                                  )
                                ],
                              ),
                            );
                          },
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              focusNode: focusNode,
                              autofocus: false,
                              onChanged: (value) {
                                stateController.text = value;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 8,
                                ),
                                suffixIcon: stateValue == null
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          stateController.text = '';
                                          cityController.text = '';
                                          cityValue = null;
                                          setState(() {
                                            stateValue = null;
                                            cityValue = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                      ),
                                border: const OutlineInputBorder(),
                                labelStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                labelText: context.tr('state'),
                              ),
                            );
                          },
                          decorationBuilder: (context, child) {
                            return Material(
                              type: MaterialType.card,
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              borderOnForeground: true,
                              child: child,
                            );
                          },
                          offset: const Offset(0, 2),
                          constraints: const BoxConstraints(maxHeight: 500),
                          itemBuilder: (context, state) {
                            List<InlineSpan> temp = highlightText(
                                stateController.text,
                                state.name,
                                brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                Theme.of(context).primaryColor);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    state.emoji,
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: ListTile(
                                    title: Text.rich(
                                      TextSpan(children: temp)
                                    ),
                                    subtitle: Text(
                                      state.subtitle ??
                                          '{$state.countryName} - ${state.iso2}',
                                      style: TextStyle(
                                        color: brightness == Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                          onSelected: (state) {
                            setState(() {
                              countryValue = state.countryName;
                              stateValue = state.name;
                            });
                            stateController.text =
                                '${state.emoji} - ${state.name}';
                            countryController.text =
                                '${state.emoji} - ${state.countryName}';
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 315.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: TypeAheadField<Cities>(
                          controller: cityController,
                          hideWithKeyboard: false,
                          suggestionsCallback: (search) =>
                              citySuggestionsCallback(search),
                          itemSeparatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                          emptyBuilder: (context) => ListTile(
                            title: Text(
                              context.tr('noItem'),
                            ),
                          ),
                          errorBuilder: (context, error) {
                            return ListTile(
                              title: Text(
                                error.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            );
                          },
                          loadingBuilder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Theme.of(context).primaryColorLight,
                                  )
                                ],
                              ),
                            );
                          },
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              focusNode: focusNode,
                              autofocus: false,
                              onChanged: (value) {
                                cityController.text = value;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 8,
                                ),
                                suffixIcon: cityValue == null
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          cityController.text = '';
                                          setState(() {
                                            cityValue = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                      ),
                                border: const OutlineInputBorder(),
                                labelStyle: const TextStyle(color: Colors.grey),
                                labelText: context.tr('city'),
                              ),
                            );
                          },
                          decorationBuilder: (context, child) {
                            return Material(
                              type: MaterialType.card,
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              borderOnForeground: true,
                              child: child,
                            );
                          },
                          offset: const Offset(0, 2),
                          constraints: const BoxConstraints(maxHeight: 500),
                          itemBuilder: (context, city) {
                             List<InlineSpan> temp = highlightText(
                                cityController.text,
                                city.name,
                                brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                Theme.of(context).primaryColor);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    city.emoji,
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: ListTile(
                                    title: Text.rich(
                                      TextSpan(children: temp)
                                    ),
                                    subtitle: Text(
                                      city.subtitle ??
                                          '{$city.countryName} - ${city.stateName}',
                                      style: TextStyle(
                                          color: brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                          onSelected: (city) {
                            setState(() {
                              countryValue = city.countryName;
                              stateValue = city.stateName;
                              cityValue = city.name;
                            });

                            stateController.text =
                                '${city.emoji} - ${city.stateName}';
                            countryController.text =
                                '${city.emoji} - ${city.countryName}';
                            cityController.text =
                                '${city.emoji} - ${city.name}';
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 378.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(double.maxFinite, 30),
                            elevation: 5.0,
                            foregroundColor: Theme.of(context).primaryColor,
                            animationDuration:
                                const Duration(milliseconds: 1000),
                            backgroundColor:
                                Theme.of(context).primaryColorLight,
                            shadowColor: Theme.of(context).primaryColorLight,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onSubmit(
                              specialitiesValue,
                              genderValue,
                              countryValue,
                              stateValue,
                              cityValue,
                            );
                          },
                          child: Text(
                            context.tr('submit'),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 440.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(double.maxFinite, 30),
                            elevation: 5.0,
                            foregroundColor: Theme.of(context).primaryColor,
                            animationDuration:
                                const Duration(milliseconds: 1000),
                            backgroundColor: Theme.of(context).primaryColor,
                            shadowColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              specialitiesValue = null;
                              genderValue = null;
                              countryValue = null;
                              stateValue = null;
                              cityValue = null;
                            });
                            countryController.text = '';
                            stateController.text = '';
                            cityController.text = '';
                            widget.onReset();
                          },
                          child: Text(
                            context.tr('reset'),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<InlineSpan> highlightText(
    String text, String fullName, Color normalColor, Color highlightColor) {
  List<InlineSpan> temp = [];
  final re = RegExp(text, caseSensitive: false);
  List<String> splittedNamesOfCountry = fullName.split(re);
  for (var i = 0; i < splittedNamesOfCountry.length - 1; i++) {
    temp.add(
      TextSpan(
        text: splittedNamesOfCountry[i],
        style: TextStyle(
          height: 1.0,
          color: normalColor,
        ),
      ),
    );
    temp.add(
      TextSpan(
        text: text,
        style: TextStyle(
          color: highlightColor,
        ),
      ),
    );
  }
  temp.add(
    TextSpan(
      text: splittedNamesOfCountry.last,
      style: TextStyle(
        color: normalColor,
      ),
    ),
  );
  return temp;
}
