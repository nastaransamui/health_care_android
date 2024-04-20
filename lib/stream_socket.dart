// ignore_for_file: avoid_print, library_prefixes

import 'dart:async';
import 'dart:convert';

import 'package:health_care/models/theme_from_admin.dart';
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
      print(themeFromAdmin.toJson());
      streamSocket.addResponse(themeFromAdmin.toJson());
    });
  });
  //When an event recieved from server, data is added to the stream
  socket.on('event', (data) => streamSocket.addResponse);
  socket.onDisconnect((_) => print('disconnect'));
}
