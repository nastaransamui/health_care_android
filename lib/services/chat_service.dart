import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/services/time_schedule_service.dart';
import 'package:health_care/stream_socket.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ChatService {
  Future<void> getUserRooms(BuildContext context) async {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final bool isLogin = authProvider.isLogin;
    final String roleName = authProvider.roleName;
    if (!isLogin) return;

    String userId = "";
    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
    }

    void getUserRoomsWithUpdate() {
      socket.emit('getUserRooms', {"userId": userId});
    }

    socket.off('getUserRoomsReturn');
    socket.on('getUserRoomsReturn', (data) async {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      if (context.mounted && isLogin) {
        chatProvider.setLoading(false);
      }

      final userRooms = data['userRooms'];
      if (userRooms is List && userRooms.isNotEmpty) {
        try {
          // (userRooms).map((json) => ChatDataType.fromMap(json)).toList();
          final chatList = await Future.wait(
            userRooms.map<Future<ChatDataType>>(
              (json) async {
                final chatRoom = ChatDataType.fromMap(json);

                final updatedMessages = await Future.wait(
                  chatRoom.messages.map<Future<MessageType>>(
                    (msg) async {
                      final updatedAttachements = await Future.wait(
                        msg.attachment.map<Future<AttachmentType>>(
                          (attach) async {
                            final fileId = attach.id;
                            final fileBytes = (fileId.isNotEmpty) ? await getChatFile(fileId, userId) : null;
                            return attach.copyWith(imageBytes: fileBytes);
                          },
                        ),
                      );
                      return msg.copyWith(attachment: updatedAttachements);
                    },
                  ),
                );
                return chatRoom.copyWith(messages: updatedMessages);
              },
            ).toList(),
          );
          chatProvider.setUserChatData(chatList);
        } catch (e) {
          log('chatErro: e');
        }
      } else {
        if (context.mounted && isLogin) {
          chatProvider.setLoading(false);
          chatProvider.setUserChatData([]);
        }
      }
    });

    socket.off('updateGetUserRooms');
    socket.on('updateGetUserRooms', (_) => getUserRoomsWithUpdate());
    getUserRoomsWithUpdate();
  }

  Future<List<ChatUserAutocompleteData>> fetchAutoComplete(String input, String userType) async {
    final completer = Completer<List<ChatUserAutocompleteData>>();

    socket.emit("userSearchAutocomplete", {"searchText": input, "userType": userType});
    socket.off('userSearchAutocompleteReturn');
    socket.on("userSearchAutocompleteReturn", (data) {
      if (data['status'] == 200) {
        final users = data['users'];
        if (users is List) {
          try {
            final userList = users.map((json) => ChatUserAutocompleteData.fromMap(json)).toList();
            completer.complete(userList);
          } catch (e) {
            log('chatErro: $e');
            completer.complete([]); // complete with empty if parsing fails
          }
        } else {
          completer.complete([]); // users is not a List
        }
      } else {
        completer.complete([]); // status not 200
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        log('Autocomplete timeout');
        return [];
      },
    );
  }

  Future<void> deleteChat(BuildContext context, Map<String, dynamic> payload) async {
    socket.emit('deleteChat', payload);

    socket.off('deleteChatReturn');
    socket.on('deleteChatReturn', (data) {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? data['reason']);
        }
        return;
      } else {
        if (context.mounted) {
          showErrorSnackBar(context, data['message'] ?? "Delete Succefully");
        }
      }
    });
  }

  Future<void> getSingleRoomById(
    BuildContext context,
    String roomId,
    VoidCallback onDone,
  ) async {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final bool isLogin = authProvider.isLogin;
    final String roleName = authProvider.roleName;
    if (!isLogin) return;
    String userId = "";
    if (roleName == 'doctors') {
      userId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      userId = authProvider.patientProfile!.userId;
    }

    void getSingleRoomByIdWithUpdate() {
      socket.emit('getSingleRoomById', {"userId": userId, "roomId": roomId});
    }

    socket.off("getSingleRoomByIdReturn");
    socket.on('getSingleRoomByIdReturn', (data) async {
      if (data['status'] != 200) {
        if (context.mounted) {
          showErrorSnackBar(context, data['message']);
        }
        return;
      }
      final userRoom = data['userRoom'];
      if (userRoom == null) {
        chatProvider.setCurrentRoom(null);
        onDone();
        return;
      }
      try {
        final chatRoom = ChatDataType.fromMap(userRoom);
        // STEP 1: Set room immediately (with empty imageBytes)
        chatProvider.setCurrentRoom(chatRoom);
        onDone();
      } catch (e) {
        log('chatErro: $e');
      }
    });

    socket.off('updateGetSingleRoomById');
    socket.on('updateGetSingleRoomById', (_) => getSingleRoomByIdWithUpdate());
    getSingleRoomByIdWithUpdate();
  }

  Future<void> receiveVoiceCall(BuildContext context) async {
    socket.on('receiveVoiceCall', (data) async {
      // final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
      // chatProvider.setEndCall(false);
      // chatProvider.setIsAcceptCall(false);
      try {
        log('$data data recieveVocidecal:');
        // final RTCSessionDescription offer = RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
        // final String receiverId = data['receiverId'];
        // final String callerId = data['callerId'];
        // final String roomId = data['roomId'];
        // var messageDataMap = data['messageData'];
        // final MessageType messageData = MessageType.fromMap(messageDataMap);
        // chatProvider.setIncomingCall(
        //   IncomingCall(
        //     offer: offer,
        //     receiverId: receiverId,
        //     callerId: callerId,
        //     roomId: roomId,
        //     messageData: messageData,
        //   ),
        // );
        // await initiateVoiceCallIfPermitted(
        //   context,
        //   widget.currentRoom,
        //   widget.currentUserId,
        // );
      } catch (e) {
        log("Error socket receiveVoiceCall: $e");
      }
    });
  }
}

Future<Uint8List?> getChatFile(String fileId, String userId) async {
  final String url = "${dotenv.env['adminUrl']}/api/chat/file/$fileId?userId=$userId";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return null; // fallback will be handled in UI
    }
  } catch (e) {
    return null; // on error, return null to trigger fallback in UI
  }
}
