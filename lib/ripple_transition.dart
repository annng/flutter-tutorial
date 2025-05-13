import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A reusable widget that provides a ripple transition effect when changing colors
class RippleTransition extends StatefulWidget {
  /// The child widget to apply the ripple effect to
  final Widget child;

  /// The current background color
  final Color backgroundColor;

  /// Optional callback when transition completes
  final VoidCallback? onTransitionComplete;

  /// Duration of the ripple animation
  final Duration duration;

  /// Whether to start the ripple from bottom right (true) or center (false)
  final bool fromBottomRight;

  /// Ripple starting position (only used if fromBottomRight is false)
  final Alignment? rippleOrigin;

  const RippleTransition({
    Key? key,
    required this.child,
    required this.backgroundColor,
    this.onTransitionComplete,
    this.duration = const Duration(milliseconds: 800),
    this.fromBottomRight = true,
    this.rippleOrigin,
  }) : super(key: key);

  @override
  State<RippleTransition> createState() => _RippleTransitionState();
}

class _RippleTransitionState extends State<RippleTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Color _oldColor;
  late Color _currentColor;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.backgroundColor;
    _oldColor = widget.backgroundColor;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
        _controller.reset();
        if (widget.onTransitionComplete != null) {
          widget.onTransitionComplete!();
        }
      }
    });
  }

  @override
  void didUpdateWidget(RippleTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If background color has changed, trigger the ripple animation
    if (widget.backgroundColor != oldWidget.backgroundColor && !_isAnimating) {
      _startRippleTransition(oldWidget.backgroundColor, widget.backgroundColor);
    }

    // Update animation duration if it changed
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  void _startRippleTransition(Color oldColor, Color newColor) {
    setState(() {
      _oldColor = oldColor;
      _currentColor = newColor;
      _isAnimating = true;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base container with current color
        Container(
          color: _currentColor,
          width: double.infinity,
          height: double.infinity,
          child: widget.child,
        ),

        // Only show ripple when animating
        if (_isAnimating)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: RipplePainter(
                  color: _oldColor,
                  animationValue: _controller.value,
                  context: context,
                  fromBottomRight: widget.fromBottomRight,
                  rippleOrigin: widget.rippleOrigin,
                ),
              );
            },
          ),
      ],
    );
  }
}

class RipplePainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final BuildContext context;
  final bool fromBottomRight;
  final Alignment? rippleOrigin;

  RipplePainter({
    required this.color,
    required this.animationValue,
    required this.context,
    this.fromBottomRight = true,
    this.rippleOrigin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue <= 0) return;

    // Determine the center point for the ripple
    late final Offset center;

    if (fromBottomRight) {
      // Start from bottom right corner
      center = Offset(size.width, size.height);
    } else if (rippleOrigin != null) {
      // Use custom alignment
      final double dx = (rippleOrigin!.x + 1) / 2 * size.width;
      final double dy = (rippleOrigin!.y + 1) / 2 * size.height;
      center = Offset(dx, dy);
    } else {
      // Default to center
      center = Offset(size.width / 2, size.height / 2);
    }

    // Calculate max radius needed to cover the entire screen
    final double maxDistanceX = max(center.dx, size.width - center.dx);
    final double maxDistanceY = max(center.dy, size.height - center.dy);
    final double maxRadius = sqrt(maxDistanceX * maxDistanceX + maxDistanceY * maxDistanceY) * 1.1;

    // Reverse the animation - we're painting the old color that's being wiped away
    final double inverseValue = 1.0 - animationValue;
    final double currentRadius = maxRadius * inverseValue;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
          oldDelegate.color != color;

  // Helper function
  double max(double a, double b) => a > b ? a : b;

  // Helper function
  double sqrt(double value) => value <= 0 ? 0 : value.sqrt;
}

// Extension to make sqrt more convenient
extension on double {
  double get sqrt => math.sqrt(this);
}