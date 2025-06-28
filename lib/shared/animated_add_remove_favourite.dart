
import 'package:flutter/material.dart';

class AnimatedAddRemoveFavourite extends StatefulWidget {
  final bool isHeart;
  final double size;
  final Color color;
  final bool isLogin;
  final bool isFave;
  const AnimatedAddRemoveFavourite({
    super.key,
    required this.isHeart,
    this.size = 32.0,
    this.color = Colors.red,
    this.isLogin = true,
    this.isFave = true,
  });

  @override
  State<AnimatedAddRemoveFavourite> createState() => _AnimatedAddRemoveFavouriteState();
}

class _AnimatedAddRemoveFavouriteState extends State<AnimatedAddRemoveFavourite> with TickerProviderStateMixin {
  late final AnimationController _heartController;
  late final AnimationController _syncController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.9,
      upperBound: 1.2,
    );

    _syncController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _startProperAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedAddRemoveFavourite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHeart != widget.isHeart) {
      _startProperAnimation();
    }
  }

  void _startProperAnimation() {
    if (widget.isHeart) {
      _syncController.stop();
      _heartController.repeat(reverse: true);
    } else {
      _heartController.stop();
      _syncController.repeat();
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    _syncController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: widget.isHeart
          ? ScaleTransition(
              key: const ValueKey('heart'),
              scale: _heartController,
              child: Icon(
                widget.isLogin
                    ? widget.isFave
                        ? Icons.favorite
                        : Icons.favorite_border
                    : Icons.favorite_outline,
                color: widget.color,
                size: widget.size,
              ),
            )
          : RotationTransition(
              key: const ValueKey('sync'),
              turns: _syncController,
              child: Icon(Icons.sync, color: Theme.of(context).primaryColor, size: widget.size),
            ),
    );
  }
}
