// ignore_for_file: avoid_print, library_prefixes

import 'dart:async';


import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

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
  dotenv.env['SOCKET_URL'],
  OptionBuilder()
      .setTransports(['websocket'])
      // .setExtraHeaders({'foo': 'bar'}) // optional
      .build(),
);

void initiateSocket() {
  socket.onConnect((_) {
    print('conneted');

    // socket.on('getUserProfileFromAdmin', (data) {
    //   print(data);
    //   // final themeFromAdmin = ThemeFromAdmin.fromJson(json.encode(data));
    //   // streamSocket.addResponse(themeFromAdmin.toJson());
    // });
  });


  //When an event recieved from server, data is added to the stream
  // socket.on('event', (data) => streamSocket.addResponse);
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
