

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ScrollButton extends StatefulWidget {
  final ScrollController scrollController;
  final double scrollPercentage;
  const ScrollButton({
    super.key,
    required this.scrollController,
    required this.scrollPercentage,
  });

  @override
  State<ScrollButton> createState() => _ScrollButtonState();
}

class _ScrollButtonState extends State<ScrollButton> {
  void scrollDown() {
   if(widget.scrollController.hasClients){
     widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
   }
  }

  void scrollUp() {
    if(widget.scrollController.hasClients){
      widget.scrollController.animateTo(
      widget.scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Stack(children: [
      Positioned(
        bottom: 10,
        right: 5,
        // child: ScrollButton(scrollController: scrollController),
        child: Center(
          child: GestureDetector(
            onTap: scrollDown,
            child: Stack(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 30, maxHeight: 30),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                    shape: BoxShape.circle,
                    // ignore: deprecated_member_use
                    color: Theme.of(context).cardTheme.color?.withOpacity(1.0)
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_downward),
                  ),
                ),
                SvgPicture.string(
                  // ignore: deprecated_member_use
                  "<svg width='100%' height='100%' viewBox='-1 -1 102 102' fill-opacity='0'><path d='M50,1 a49,49 0 0,1 0,98 a49,49 0 0,1 0,-98'  stroke='#${Theme.of(context).primaryColorLight.value.toRadixString(16).substring(2, 8)}' stroke-dasharray='${widget.scrollPercentage}, 307' stroke-width='4'   /></svg>",
                  width: 30,
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 45,
        right: 5,
        child: Center(
          child: GestureDetector(
            onTap: scrollUp,
            child: Stack(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 30, maxHeight: 30),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                    shape: BoxShape.circle,
                    // ignore: deprecated_member_use
                    color: Theme.of(context).cardTheme.color?.withOpacity(1.0)
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_upward),
                  ),
                ),
                SvgPicture.string(
                  // ignore: deprecated_member_use
                  "<svg width='100%' height='100%' viewBox='-1 -1 102 102' fill-opacity='0'><path d='M50,1 a49,49 0 0,1 0,98 a49,49 0 0,1 0,-98'  stroke='#${Theme.of(context).primaryColorLight.value.toRadixString(16).substring(2, 8)}' stroke-dasharray='${widget.scrollPercentage}, 307' stroke-width='4'   /></svg>",
                  width: 30,
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
