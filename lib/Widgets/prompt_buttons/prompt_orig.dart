import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';

class PromptButton1 extends StatefulWidget {
  const PromptButton1({super.key});

  @override
  _PromptButtonState createState() => _PromptButtonState();
}

class _PromptButtonState extends State<PromptButton1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  bool showLock = false;
  bool isAnimationCompleted = false;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.forward:
            break;
          case AnimationStatus.completed:
            isAnimationCompleted = true;
            _controller.reverse();
            break;
          case AnimationStatus.reverse:
            break;
          case AnimationStatus.dismissed:
            if (isAnimationCompleted) {
              setState(() {
                showLock = !showLock;
              });
              isAnimationCompleted = false;
            }
            break;
        }
      });
  }
  //for green circle2 na animation 
_onLongPressStart(LongPressStartDetails details) {
    if (!_controller.isAnimating) {
      _controller.forward();
    } else {
      _controller.forward(from: _controller.value);
    }
  }

  _onLongPressEnd(LongPressEndDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Long press to unlock prompts",style: TextStyle(fontSize: 18)),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Container(
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onLongPressStart: _onLongPressStart,
                      onLongPressEnd: _onLongPressEnd,
                      child: AnimatedBuilder(
                          animation: _controller,
                          builder: (_, child) {
                            return Transform.scale(
                              scale: ((_controller.value * 0.2) + 1),
                              child: Container(
                                width: 100,
                                padding: const EdgeInsets.all(10),
                                height: 100,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.purple[100]!,
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: const Offset(10, 10)),
                                  ],
                                  shape: BoxShape.circle,
                                  color: dullpurple,
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    CustomPaint(
                                      foregroundPainter: CircularBar(
                                          offset: const Offset(40, 40), endAngle: (pi * 2 * _controller.value), radius: 40),
                                    ),
                                    Container(
                                      child: showLock
                                          ? Center(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.green[900],
                                          size: 50,
                                        ),
                                      )
                                          : LockIcon(value: _controller.value),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            )
          ],);
    
  }
}

class LockIcon extends StatelessWidget {
  final double value;
  const LockIcon({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Center(
          child: Icon(
            Icons.lock,
            color: kwhite,
            size: 40,
          ),
        ),
      ],
    );
  }
}

class CircularBar extends CustomPainter {
  var offset = const Offset(0, 0);
  var radius = 40.0;
  var endAngle = (pi * 2 * 0.5);

  CircularBar({required this.offset, required this.radius, required this.endAngle});
  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(Rect.fromCircle(center: offset, radius: radius), -pi / 2,
        endAngle, false, p);
  }
@override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}