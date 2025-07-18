import 'package:health_care/models/chat_data_type.dart';

List<ChatDataType> sortLatestMessage(List<ChatDataType> userChatData) {
  // Clone the list to avoid mutating the original
  final sortedList = List<ChatDataType>.from(userChatData);

  sortedList.sort((a, b) {
    final lastMessageA = (a.messages.isNotEmpty) ? a.messages.reduce((latest, msg) => msg.timestamp > latest.timestamp ? msg : latest) : null;

    final lastMessageB = (b.messages.isNotEmpty) ? b.messages.reduce((latest, msg) => msg.timestamp > latest.timestamp ? msg : latest) : null;

    return (lastMessageB?.timestamp ?? 0).compareTo(lastMessageA?.timestamp ?? 0);
  });

  return sortedList;
}
