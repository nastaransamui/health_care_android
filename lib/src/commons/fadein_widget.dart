import 'package:flutter/material.dart';


class FadeinWidget extends StatefulWidget {
  final Widget child;
  final bool isCenter;
  const FadeinWidget({
    super.key,
    required this.child,
    required this.isCenter,
  });

  @override
  State<FadeinWidget> createState() => _FadeinWidgetState();
}

class _FadeinWidgetState extends State<FadeinWidget> {
  bool _isFinished = false;
  Future<void> removeLoader() async {
    Future.delayed(const Duration(microseconds: 1000), () {
     if(mounted){
       setState(() {
        _isFinished = true;
      });
     }
    });
  }

  @override
  void initState() {
   removeLoader();
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: widget.child,
      firstCurve: Curves.easeInCubic,
      secondCurve: Curves.easeInCubic,
      secondChild: widget.isCenter
          ? const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                // child: LoadingIndicator(
                //     indicatorType: Indicator.ballRotateChase,
                //     colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                //     strokeWidth: 2.0,
                //     pathBackgroundColor: null),
              ),
            )
          : const SizedBox(height: 200, width: 200,child: Text(''),),
      crossFadeState: _isFinished ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 1000),
    );
  }
}
