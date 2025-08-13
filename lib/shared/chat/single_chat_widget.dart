
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/providers/auth_provider.dart';
import 'package:health_care/providers/chat_provider.dart';
import 'package:health_care/services/auth_service.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/src/commons/scaffold_wrapper.dart';
import 'package:health_care/src/commons/scroll_button.dart';
import 'package:health_care/shared/chat/chat-share/no_chat_available_widget.dart';
import 'package:health_care/shared/chat/chat_bubble_widget.dart';
import 'package:health_care/shared/chat/single-chat-widgets/chat_input.dart';
import 'package:health_care/shared/chat/single-chat-widgets/single_chat_scaffold.dart';
import 'package:health_care/src/utils/play_sound.dart';
import 'package:health_care/stream_socket.dart';
import 'package:provider/provider.dart';

class SingleChatWidget extends StatefulWidget {
  static const String routeName = '/patient/dashboard/patient-chat/single';
  final String roomId;
  const SingleChatWidget({
    super.key,
    required this.roomId,
  });

  @override
  State<SingleChatWidget> createState() => _SingleChateWidgetState();
}

class _SingleChateWidgetState extends State<SingleChatWidget> {
  final ScrollController scrollController = ScrollController();
  final AuthService authService = AuthService();
  late final AuthProvider authProvider;
  final ChatService chatService = ChatService();
  late final ChatProvider chatProvider;
  late String roleName;
  bool _isProvidersInitialized = false;
  bool isLoading = true;
  bool _hasRedirected = false;
  bool hasMarkedRead = false;
  bool isEditMessage = false;
  String? lastSeenMessageId;
  double scrollPercentage = 0;
  late String currentUserId;
  TextEditingController chatInputController = TextEditingController();
  final chatInputFocusNode = FocusNode();
  Set<int> showDeleteIndices = {};
  int editMessageTime = 0;
  int? lastMessageTimestamp;
  void setEditMessageTime(int timestamp) {
    setState(() {
      editMessageTime = timestamp;
    });
  }

  void bubbleChatLongPress(index) {
    setState(() {
      if (showDeleteIndices.contains(index)) {
        showDeleteIndices.remove(index);
        if (isEditMessage) {
          chatInputController.clear();
          chatInputFocusNode.unfocus();
          taggleEditMessage(false);
        }
      } else {
        showDeleteIndices.add(index);
      }
    });
  }

  void taggleEditMessage(bool value) {
    setState(() {
      isEditMessage = value;
    });
  }

  Future<void> getDataOnUpdate() async {
    hasMarkedRead = false;
    chatService.getSingleRoomById(context, widget.roomId, () {
      if (hasMarkedRead) {
        final currentRoom = chatProvider.currentRoom;
        if (currentRoom != null && currentRoom.messages.isNotEmpty) {
          final latestMessage = currentRoom.messages.last;
          // Check if it's a new message AND not from the current user
          if (lastMessageTimestamp == null || latestMessage.timestamp > lastMessageTimestamp!) {
            if (latestMessage.senderId != currentUserId) {
              if(latestMessage.calls.isEmpty){
              playReciveMessageSound();
              }
            }

            // Update the latest seen timestamp
            lastMessageTimestamp = latestMessage.timestamp;
          }
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  void _scrollToBottomOnUpdate() {
    if (!mounted || !scrollController.hasClients || !scrollController.position.hasContentDimensions) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottomOnUpdate);
      return;
    }
    final currentRoom = chatProvider.currentRoom;
    if (currentRoom != null && currentRoom.messages.isNotEmpty) {
      final lastMessage = currentRoom.messages.last;
      final lastMessageId = lastMessage.timestamp.toString();
      // If a new message arrived (different from last seen), reset read tracking
      if (lastMessageId != lastSeenMessageId) {
        lastSeenMessageId = lastMessageId;
        hasMarkedRead = false;
      }
      if (!hasMarkedRead && lastMessage.receiverId == currentUserId && !lastMessage.read) {
        hasMarkedRead = true;
        socket.emit('makeOneMessageRead', lastMessage.toMap());
      }
      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    authService.updateLiveAuth(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDataOnUpdate();
      socket.emit("joinRoom", widget.roomId);
      socket.emit('makeAllMessageRead', {"roomId": widget.roomId, "userId": currentUserId});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isProvidersInitialized) {
      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      roleName = Provider.of<AuthProvider>(context, listen: false).roleName;
      // Add listener here, where it's initialized
      chatProvider.addListener(_scrollToBottomOnUpdate);
      _isProvidersInitialized = true;
    }
    if (roleName == 'doctors') {
      currentUserId = authProvider.doctorsProfile!.userId;
    } else if (roleName == 'patient') {
      currentUserId = authProvider.patientProfile!.userId;
    }
  }

  @override
  void dispose() {
    chatProvider.setUserChatData([], notify: false);
    scrollController.dispose();
    socket.off('getSingleRoomByIdReturn');
    socket.off('updateGetSingleRoomById');
    chatProvider.removeListener(_scrollToBottomOnUpdate);
    chatInputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ChatProvider>(
      builder: (context, authProvider, chatProvider, child) {
        // final theme = Theme.of(context);
        final currentRoom = chatProvider.currentRoom;
        if (roleName.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.microtask(() {
              if (context.mounted) {
                context.go('/');
              }
            });
          });
        }
        if (isLoading) {
          return ScaffoldWrapper(
            title: context.tr('loading'),
            children: const Center(child: CircularProgressIndicator()),
          );
        }
        //Redirect if id is empty
        if (!isLoading && currentRoom == null && !_hasRedirected) {
          _hasRedirected = true;
          Future.microtask(() {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });

          return const SizedBox.shrink();
        }
        return currentRoom != null
            ? SingleChatScaffold(
                currentRoom: currentRoom,
                currentUserId: currentUserId,
                children: Stack(
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
                          padding: const EdgeInsets.only(bottom: 68.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                restorationId: 'pateintChat',
                                key: const ValueKey('pateintChat'),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentRoom.messages.length,
                                itemBuilder: (context, index) {
                                  return ChatBubbleWidget(
                                    currentRoom: currentRoom,
                                    index: index,
                                    currentUserId: currentUserId,
                                    chatInputController: chatInputController,
                                    chatInputFocusNode: chatInputFocusNode,
                                    taggleEditMessage: taggleEditMessage,
                                    isEditMessage: isEditMessage,
                                    showDeleteIndices: showDeleteIndices,
                                    bubbleChatLongPress: bubbleChatLongPress,
                                    setEditMessageTime: setEditMessageTime,
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
                              if (!isLoading && currentRoom.messages.isEmpty) ...[const NoChatAvailableWidget()]
                            ],
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: ScrollButton(
                        scrollController: scrollController,
                        scrollPercentage: scrollPercentage,
                      ),
                    ),
                    // Chat input field at bottom
                    ChatInput(
                      chatInputController: chatInputController,
                      currentRoom: currentRoom,
                      currentUserId: currentUserId,
                      focusNode: chatInputFocusNode,
                      taggleEditMessage: taggleEditMessage,
                      isEditMessage: isEditMessage,
                      showDeleteIndices: showDeleteIndices,
                      bubbleChatLongPress: bubbleChatLongPress,
                      editMessageTime: editMessageTime,
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
