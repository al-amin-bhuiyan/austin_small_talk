import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  final String text; // Text to be animated
  final Duration duration; // Duration for the animation

  // Constructor that accepts the text and duration for the animation
  const AnimatedText({
    super.key,
    required this.text,
    this.duration = const Duration(seconds: 5),

    // Default duration of 5 seconds
  });

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    // Set up the AnimationController
    _controller = AnimationController(
      duration: widget.duration, // Use the passed duration
      vsync: this,
    );

    // Define the animation from 0 to the length of the text
    _animation = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear, // Smooth transition curve for forward animation
        reverseCurve: Curves.linear, // Smooth transition curve for reverse animation
      ),
    );
    // Start the animation when the widget is initialized
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Show a substring of the text up to the current animation value
        String visibleText = widget.text.substring(0, _animation.value);

        return Text(
          visibleText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.0, // Customize the text size here
            fontWeight: FontWeight.bold, // Customize the font weight
            color: Colors.white, // Customize the text color
          ),
        );
      },
    );
  }
}
