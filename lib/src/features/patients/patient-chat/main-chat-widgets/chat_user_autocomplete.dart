import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:health_care/models/chat_data_type.dart';
import 'package:health_care/services/chat_service.dart';
import 'package:health_care/src/features/patients/medicalRecords/medical_record_show_box.dart';
import 'package:health_care/src/features/patients/patient-chat/main-chat-widgets/auto_complete_item_builder.dart';
import 'package:health_care/src/features/patients/patient-chat/chat-share/sort_latest_message.dart';
import 'package:health_care/stream_socket.dart';

class ChatUserAutocomplete extends StatefulWidget {
  final String roleName; // doctors or patient
  final String optionFieldName;
  final String currentUserId;
  final List<ChatDataType> userChatData;
  final String fullName;
  final String profileImage;
  final bool online;
  final bool idle;
  final void Function(String roomId) setCurrentRoomId;
  const ChatUserAutocomplete({
    super.key,
    required this.roleName,
    required this.optionFieldName,
    required this.currentUserId,
    required this.userChatData,
    required this.setCurrentRoomId,
    required this.fullName,
    required this.profileImage,
    required this.online,
    required this.idle,
  });

  @override
  State<ChatUserAutocomplete> createState() => _ChatUserAutocompleteState();
}

class _ChatUserAutocompleteState extends State<ChatUserAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ChatService chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {}); // Triggers rebuild so suffixIcon updates
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    socket.off('userSearchAutocompleteReturn');
    super.dispose();
  }

  void onSelectAutoComplete(ChatUserAutocompleteData suggestion) {
    _focusNode.unfocus();

    setState(() {
      _controller.text = "";
    });
    final userId1 = suggestion.id;
    final userId2 = widget.currentUserId;
    final combinedRoomId = [userId1, userId2]..sort();
    final roomId = combinedRoomId.join();
    final sorted = sortLatestMessage(widget.userChatData);
    final selectedIndex = sorted.indexWhere((a) => a.roomId == roomId);
    widget.setCurrentRoomId(roomId);
    if (selectedIndex == -1) {
      var roomData = {
        "roomId": roomId,
        "participants": [userId2, userId1],
        "createrData": {
          "userId": userId2,
          "fullName": widget.fullName,
          "profileImage": widget.profileImage,
          "online": widget.online,
          "idle": widget.idle,
          "roleName": widget.roleName == 'doctors' ? 'patient': 'doctors',
        },
        "receiverData": {
          "userId": suggestion.id,
          "fullName": suggestion.fullName,
          "profileImage": suggestion.profileImage,
          "online": suggestion.online,
          "idle": suggestion.lastLogin.idle ?? false,
          "roleName": suggestion.roleName,
        },
        "messages": [],
      };
      socket.emit('inviteUserToRoom', roomData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50), // your desired radius
      borderSide: BorderSide(
        color: textColor,
        width: 1, // optional thickness
      ),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      borderSide: BorderSide(
        color: theme.primaryColorLight,
        width: 1,
      ),
    );
    return TypeAheadField<ChatUserAutocompleteData>(
      controller: _controller,
      focusNode: _focusNode,
      suggestionsCallback: (pattern) async {
        return await chatService.fetchAutoComplete(pattern, widget.roleName);
      },
      builder: (context, _, focusNode) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            focusNode: focusNode,
            decoration: InputDecoration(
                filled: true,
                fillColor: theme.cardTheme.color,
                enabledBorder: border,
                focusedBorder: focusBorder,
                prefixIcon: Icon(Icons.search, color: textColor),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : GestureDetector(
                        onTap: () => setState(() => _controller.clear()),
                        child: Icon(Icons.close, color: theme.primaryColor),
                      ),
                hintText: context.tr('search_${widget.roleName}'),
                hintStyle: TextStyle(color: textColor),
                border: const OutlineInputBorder(),
                isDense: true,
                constraints: const BoxConstraints(maxHeight: 45)),
          ),
        );
      },
      itemBuilder: (context, suggestion) {
        return AutoCompleteItemBuilder(roleName: widget.roleName, suggestion: suggestion);
      },
      onSelected: onSelectAutoComplete,
      loadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(),
      ),
      emptyBuilder: (context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(context.tr('noItem')),
      ),
      itemSeparatorBuilder: (context, index) {
        return MyDivider(theme: theme);
      },
      errorBuilder: (context, error) {
        return ListTile(
          title: Text(
            error.toString(),
            style: TextStyle(color: textColor),
          ),
        );
      },
      decorationBuilder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Material(
            type: MaterialType.card,
            elevation: 4,
            borderOnForeground: true,
            // ignore: deprecated_member_use
            color: theme.cardTheme.color?.withOpacity(1.0),
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              side: BorderSide(width: 1, color: theme.primaryColorLight), // Or your desired color
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: child,
            ),
          ),
        );
      },
      offset: const Offset(0, -10),
      hideOnEmpty: true,
      hideOnUnfocus: true,
    );
  }
}
