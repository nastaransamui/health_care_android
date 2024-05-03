// ignore_for_file: avoid_print, library_prefixes

import 'dart:async';
import 'dart:convert';

// import 'package:health_care/models/clinics.dart';
import 'package:health_care/models/theme_from_admin.dart';
// import 'package:health_care/providers/clinics_provider.dart';
// import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

import 'package:health_care/constants/global_variables.dart';

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

StreamSocket streamSocket = StreamSocket();

IO.Socket socket = IO.io(
  socketUrl,
  OptionBuilder()
      .setTransports(['websocket']).setExtraHeaders({'foo': 'bar'}) // optional
      .build(),
);

void initiateSocket() {
  socket.onConnect((_) {
    print('conneted');
    socket.on('getThemeFromAdmin', (data) {
      final themeFromAdmin = ThemeFromAdmin.fromJson(json.encode(data));
      streamSocket.addResponse(themeFromAdmin.toJson());
    });

    // socket.on('getClinicStatusFromAdmin', (data) {
    //   // print(data.toString());
    //   // List<dynamic> clinicslist = [];
    //   // for (var element in data) {
    //   //   final clinicsFromAdmin = Clinics.fromMap(element);
    //   //   clinicslist.add(Clinics.fromJson(clinicsFromAdmin.toJson()));
    //   // }
    // });
    socket.on('getSpecialitiesFromAdmin', (data) {
      // print(data);
      // final themeFromAdmin = ThemeFromAdmin.fromJson(json.encode(data));
      // streamSocket.addResponse(themeFromAdmin.toJson());
    });
    // socket.on('getUserProfileFromAdmin', (data) {
    //   print(data);
    //   // final themeFromAdmin = ThemeFromAdmin.fromJson(json.encode(data));
    //   // streamSocket.addResponse(themeFromAdmin.toJson());
    // });
  });
  //When an event recieved from server, data is added to the stream
  socket.on('event', (data) => streamSocket.addResponse);
  socket.onDisconnect((_) => print('disconnect'));
}

Set<T> jsonToSet<T>(Object? responseData) {
  final temp = responseData as List? ?? <dynamic>[];
  final set = <T>{};
  for (final tmp in temp) {
    set.add(tmp as T);
  }
  return set;
}

List<T> jsonToList<T>(Object? responseData) {
  final temp = responseData as List? ?? <dynamic>[];
  final list = <T>[];
  for (final tmp in temp) {
    list.add(tmp as T);
  }
  return list;
}
