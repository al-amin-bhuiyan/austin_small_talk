import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wave_blob/wave_blob.dart';

class AnimatedCircle extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final List<Color> circleColors;
  final int blobCount;
  final double amplitude;
  final double scale;
  final bool autoScale;
  final bool centerCircle;
  final bool overCircle;

  const AnimatedCircle({
    Key? key,
    required this.child,
    this.width = 250,
    this.height = 350,
    this.circleColors = const [
      Color(0xFF6B8CFF),
      Color(0xFF8B5CF6),
      Color(0xFFB24BF3),
    ],
    this.blobCount = 5,
    this.amplitude = 8250.0,
    this.scale = 5.0,
    this.autoScale = true,
    this.centerCircle = true,
    this.overCircle = true,
  }) : super(key: key);

  @override
  State<AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle> {
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: WaveBlob(
        blobCount: widget.blobCount,
        amplitude: widget.amplitude,
        scale: widget.scale,
        autoScale: widget.autoScale,
        centerCircle: widget.centerCircle,
        overCircle: widget.overCircle,
        circleColors: widget.circleColors,
        child: widget.child,
      ),
    );
  }
}
