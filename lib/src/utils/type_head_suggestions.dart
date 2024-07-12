
import 'package:health_care/models/cities.dart';
import 'package:health_care/models/countries.dart';
import 'package:health_care/models/states.dart';
import 'package:health_care/stream_socket.dart';

Future<List<Countries>> countrySuggestionsCallback(String search) async {
    if (search.isNotEmpty) {
      socket.emit('countrySearch', {'searchText': search, "fieldValue": 'name', "state": "", "country": ""});
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

  Future<List<States>> stateSuggestionsCallback(String search, String? countryValue)async {
    if (search.isNotEmpty) {
      socket.emit('stateSearch', {'searchText': search, "fieldValue": 'name', "country": countryValue});
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

  Future<List<Cities>> citySuggestionsCallback(String search, String? countryValue, String? stateValue) async {
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
