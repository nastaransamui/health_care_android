import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/shared/chat/main-chat-widgets/chat_header.dart';
import 'package:health_care/shared/chat/main-chat-widgets/chat_user_autocomplete.dart';
import 'package:health_care/shared/chat/main-chat-widgets/chat_user_with_slider.dart';
import 'package:health_care/shared/chat/chat-share/no_chat_available_widget.dart';
import 'package:health_care/shared/chat/chat_helpers/sort_latest_message.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatefulWidget {
  static const String routeName = '/patient/dashboard/patient-chat';
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final ChatService chatService = ChatService();
  late final ChatProvider chatProvider;
  late String roleName;
  bool _isProvidersInitialized = false;
  double scrollPercentage = 0;
  late String currentRoomId;
  late String currentUserId;
  late String fullName;
  late String profileImage;
  late bool online;
  late bool idle;

  void setCurrentRoomId(String roomId) {
    setState(() {
      currentRoomId = roomId;
    });
  }

  Future<void> getDataOnUpdate() async {
    chatService.getUserRooms(context);
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      _isProvidersInitialized = true;
    }
    if (roleName == 'doctors') {
      currentUserId = authProvider.doctorsProfile!.userId;
      fullName = authProvider.doctorsProfile!.userProfile.fullName;
      profileImage = authProvider.doctorsProfile!.userProfile.profileImage;
      online = authProvider.doctorsProfile!.userProfile.online;
      idle = authProvider.doctorsProfile!.userProfile.lastLogin.idle ?? false;
    } else if (roleName == 'patient') {
      currentUserId = authProvider.patientProfile!.userId;
      fullName = authProvider.patientProfile!.userProfile.fullName;
      profileImage = authProvider.patientProfile!.userProfile.profileImage;
      online = authProvider.patientProfile!.userProfile.online;
      idle = authProvider.patientProfile!.userProfile.lastLogin.idle ?? false;
    }
  }

  @override
  void dispose() {
    chatProvider.setUserChatData([], notify: false);
    scrollController.dispose();
    socket.off('getUserRoomsReturn');
    socket.off('updateGetUserRooms');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ChatProvider>(
      builder: (context, authProvider, chatProvider, child) {
        bool isLoading = chatProvider.isLoading;
        final theme = Theme.of(context);
        final List<ChatDataType> userChatData = chatProvider.userChatData;
        final filteredChatData =
            sortLatestMessage(userChatData).where((chat) => chat.messages.isNotEmpty || chat.createrData.userId == currentUserId).toList();
        return ScaffoldWrapper(
          title: context.tr('${roleName}_chat'),
          children: Container(
            color: theme.canvasColor,
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    double per = 0;
                    if (scrollController.hasClients) {
                      per = ((scrollController.offset / scrollController.position.maxScrollExtent));
                    }
                    if (per >= 0) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          setState(() {
                            scrollPercentage = 307 * per;
                          });
                        }
                      });
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ChatHeader(),
                          ChatUserAutocomplete(
                            roleName: roleName == 'doctors' ? 'patient' : 'doctors',
                            optionFieldName: 'searchString',
                            currentUserId: currentUserId,
                            userChatData: userChatData,
                            setCurrentRoomId: setCurrentRoomId,
                            fullName: fullName,
                            profileImage: profileImage,
                            online: online,
                            idle: idle,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            restorationId: 'pateintChat',
                            key: const ValueKey('pateintChat'),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredChatData.length,
                            itemBuilder: (context, index) {
                              final chatRoom = filteredChatData[index];
                              final bool isTheLast = index == filteredChatData.length - 1;
                              return ChatUserWithSlider(
                                index: index,
                                chatRoom: chatRoom,
                                currentUserId: currentUserId,
                                isTheLast: isTheLast,
                              );
                            },
                          ),
                          if (isLoading) ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          ],
                          if (!isLoading && filteredChatData.isEmpty) ...[const NoChatAvailableWidget()]
                        ],
                      ),
                    ),
                  ),
                ),
                ScrollButton(scrollController: scrollController, scrollPercentage: scrollPercentage),
              ],
            ),
          ),
        );
      },
    );
  }
}
