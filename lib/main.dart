import 'package:flutter/material.dart';
import 'package:tutorial/feature/biometric_screen.dart';
import 'package:tutorial/utils/constants/constant.dart';
import 'package:tutorial/utils/constants/route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ROUTE_BIOMETRIC: (context) => const BiometricScreen()
      },
      title: 'Ripple Transition Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RippleTransitionDemo(),
    );
  }
}

class RippleTransitionDemo extends StatefulWidget {
  const RippleTransitionDemo({Key? key}) : super(key: key);

  @override
  State<RippleTransitionDemo> createState() => _RippleTransitionDemoState();
}

class _RippleTransitionDemoState extends State<RippleTransitionDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFirstColor = true;

  // Define your colors here
  final Color _firstColor = Colors.white;
  final Color _secondColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFirstColor = !_isFirstColor;
        });
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerRipple() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fab overlay transition'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          // Base container with current background color
          Container(
            color: _isFirstColor ? _firstColor : _secondColor,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: ListView.builder(
              itemCount: MAIN_MENUS.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(MAIN_MENUS[index].title),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, MAIN_MENUS[index].route);
                  },
                );
              },
            ),
          ),

          // Ripple effect layer
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: RipplePainter(
                  color: _isFirstColor ? _secondColor : _firstColor,
                  animationValue: _controller.value,
                  context: context,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerRipple,
        child: const Icon(Icons.refresh),
        backgroundColor: _isFirstColor ? _secondColor : _firstColor,
        foregroundColor: _isFirstColor ? Colors.white : Colors.blue,
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final BuildContext context;

  RipplePainter({
    required this.color,
    required this.animationValue,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue <= 0) return;

    // Start from bottom right corner
    final Offset center = Offset(size.width, size.height);

    // Calculate max radius needed to cover the entire screen
    // Using the distance formula from bottom-right to top-left
    final double maxRadius =
        size.width * 2.5; // A bit larger to ensure full coverage

    // Current radius based on animation progress
    final double currentRadius = maxRadius * animationValue;

    final Paint paint =
    Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
          oldDelegate.color != color;
}
