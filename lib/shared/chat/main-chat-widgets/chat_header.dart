import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:health_care/src/commons/fadein_widget.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FadeinWidget(
      isCenter: true,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Card(
              elevation: 6,
              color: theme.cardTheme.color,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColorLight),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('chats'),
                      style: TextStyle(color: theme.primaryColor, fontSize: 18),
                    ),
                    Text(context.tr('chatEndToEndEncrypt'))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
