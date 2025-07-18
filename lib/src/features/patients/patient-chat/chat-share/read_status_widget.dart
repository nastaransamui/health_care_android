import 'package:flutter/material.dart';
import 'package:health_care/models/chat_data_type.dart';

class ReadStatusWidget extends StatelessWidget {
  final MessageType lastMessage;
  const ReadStatusWidget({
    super.key,
    required this.lastMessage,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color disabledColor = Theme.of(context).disabledColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check,
          size: 8,
          color: lastMessage.read ? primaryColor : disabledColor,
        ),
        if (lastMessage.read)
          Transform.translate(
            offset: const Offset(-5, 0),
            child: Icon(
              Icons.check,
              size: 8,
              color: primaryColor,
            ),
          ),
      ],
    );
  }
}
