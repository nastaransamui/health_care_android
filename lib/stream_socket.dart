// ignore_for_file: avoid_print, library_prefixes

import 'dart:async';
import 'dart:convert';


import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care/models/users.dart';
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
      .disableAutoConnect()
      .build(),
);

void initiateSocket(isLogin, profile,roleName, userData) {
    late String accessToken = '';
    late String userid = '';
if (isLogin != null && isLogin) {
      if (roleName == 'patient') {
        final parsedPatient = PatientsProfile.fromJson(
          jsonEncode(
            jsonDecode(profile!),
          ),
        );
        accessToken = parsedPatient.accessToken;
        userid = parsedPatient.userId;
      } else if (roleName == 'doctors') {
        final parsedDoctor = DoctorsProfile.fromJson(
          jsonEncode(
            jsonDecode(profile!),
          ),
        );
        accessToken = parsedDoctor.accessToken;
        userid = parsedDoctor.userId;
      }
    }
    socket.io.options?['extraHeaders'] = {
      'userData': "$userData",
      'token': 'Bearer $accessToken',
      'userid': userid //${parsedProfile?.userId}
    }; // Update the extra headers.
    // socket.io
    //   ..disconnect()
    //   ..connect();
  socket.connect();
  socket.onConnect((_) {
    print('conneted');

    // socket.on('getUserProfileFromAdmin', (data) {
    //   print(data);
    //   // final themeFromAdmin = ThemeFromAdmin.fromJson(json.encode(data));
    //   // streamSocket.addResponse(themeFromAdmin.toJson());
    // });
  });

  socket.onConnectError((err){
    print('err: $err');
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
