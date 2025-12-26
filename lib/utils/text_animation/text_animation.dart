import 'package:flutter/material.dart';

/// Animated text widget that displays text with fade-in animation
/// Supports both plain text and RichText with inline styling
class AnimatedTextWidget extends StatefulWidget {
  final String? text;
  final TextSpan? richText;
  final TextStyle? style;
  final Duration duration;
  final TextAlign? textAlign;

  const AnimatedTextWidget({
    Key? key,
    this.text,
    this.richText,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.textAlign,
  })  : assert(text != null || richText != null, 'Either text or richText must be provided'),
        super(key: key);

  @override
  State<AnimatedTextWidget> createState() => _AnimatedTextWidgetState();
}

class _AnimatedTextWidgetState extends State<AnimatedTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.richText != null
          ? RichText(
              text: widget.richText!,
              textAlign: widget.textAlign ?? TextAlign.start,
            )
          : Text(
              widget.text!,
              style: widget.style,
              textAlign: widget.textAlign,
            ),
    );
  }
}
