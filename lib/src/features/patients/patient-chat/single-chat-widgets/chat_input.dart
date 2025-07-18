import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color?.withAlpha(255),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  // handle upload
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Icon(Icons.upload_file, color: theme.iconTheme.color),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    maxHeight: 120, // roughly 5 lines depending on font
                  ),
                  child: Scrollbar(
                    child: TextField(
                      // controller: yourMessageController,

                      enableSuggestions: true,
                      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: context.tr('typeSomething'),
                        hintStyle: TextStyle(color: textColor),
                        isDense: true,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // handle send
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Icon(Icons.send, color: theme.iconTheme.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
