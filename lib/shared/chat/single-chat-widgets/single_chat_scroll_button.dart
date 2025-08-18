import 'dart:math' as math;
import 'package:flutter/material.dart';

class SingleChatScrollButton extends StatefulWidget {
  final ScrollController scrollController;
  final double scrollPercentage;
  const SingleChatScrollButton({
    super.key,
    required this.scrollController,
    required this.scrollPercentage,
  });

  @override
  State<SingleChatScrollButton> createState() => _SingleChatScrollButtonState();
}

class _SingleChatScrollButtonState extends State<SingleChatScrollButton> {
   bool _showButton = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!widget.scrollController.hasClients) return;

    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.offset;

    // Show button if scrolled up at least 80px from bottom
    if (maxScroll - currentScroll > 80) {
      if (!_showButton) {
        setState(() => _showButton = true);
      }
    } else {
      if (_showButton) {
        setState(() => _showButton = false);
      }
    }
  }
  void scrollDown() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

 @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showButton ? 1.0 : 0.0,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 5),
          child: GestureDetector(
            onTap: scrollDown,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 30, maxHeight: 30),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Theme.of(context).cardTheme.color?.withOpacity(1.0),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: 90 * (math.pi / 180),
                  child: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
