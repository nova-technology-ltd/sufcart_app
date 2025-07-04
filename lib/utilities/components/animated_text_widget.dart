import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedTextWidget extends StatefulWidget {
  final List<String> texts;
  final Duration textDuration;
  final Duration animationDuration;
  final TextStyle textStyle;
  final Offset beginOffset;
  final Offset endOffset;

  const AnimatedTextWidget({
    super.key,
    required this.texts,
    this.textDuration = const Duration(seconds: 3),
    this.animationDuration = const Duration(milliseconds: 500),
    this.textStyle = const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    this.beginOffset = const Offset(0, 0.5),
    this.endOffset = Offset.zero,
  });

  @override
  State<AnimatedTextWidget> createState() => _AnimatedTextWidgetState();
}

class _AnimatedTextWidgetState extends State<AnimatedTextWidget> {
  int currentIndex = 0;
  Timer? _timer;
  bool _isLastTextDisplayed = false;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    _timer = Timer.periodic(widget.textDuration, (Timer timer) {
      if (currentIndex < widget.texts.length - 1) {
        setState(() {
          currentIndex = (currentIndex + 1) % widget.texts.length;
        });
      } else {
        // Stop the timer when the last text is reached
        _timer?.cancel();
        setState(() {
          _isLastTextDisplayed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.animationDuration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: widget.beginOffset,
              end: widget.endOffset,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        widget.texts[currentIndex],
        key: ValueKey<int>(currentIndex),
        style: widget.textStyle,
      ),
    );
  }
}