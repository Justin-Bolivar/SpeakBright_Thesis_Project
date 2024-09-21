// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';

class PromptButton extends StatefulWidget {
  const PromptButton({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PromptButtonState createState() => _PromptButtonState();
}

class _PromptButtonState extends State<PromptButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // ignore: unused_field
  late Animation _animation;

  bool showLock = false;
  bool isAnimationCompleted = false;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

  //for circle2 na animation
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

  Future<void> _updatePromptField(int index) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    Map<int, String> fieldsToUpdate = {
      0: 'physical',
      1: 'modeling',
      2: 'gestural',
      3: 'verbal',
      4: 'independent'
    };

    String fieldToUpdate = fieldsToUpdate[index] ?? '';

    await firestore.collection('prompt').doc(uid).set({
      fieldToUpdate: FieldValue.increment(1),
      'email': auth.currentUser?.email ?? '',
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width-20,
      child: Positioned(
        bottom: 0,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return showLock ? _buildImageButtons() : _buildPurpleContainer();
          },
        ),
      ),
    );
  }

  Widget _buildPurpleContainer() {
    return Align(
          alignment: Alignment.bottomCenter,
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
                          width: 60,
                          padding: const EdgeInsets.all(10),
                          height: 60,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.purple[100]!,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 0)),
                            ],
                            shape: BoxShape.circle,
                            color: kwhite,
                          ),
                          child: Stack(
                            children: <Widget>[
                              CustomPaint(
                                foregroundPainter: CircularBar(
                                    offset: const Offset(20, 20),
                                    endAngle: (pi * 2 * _controller.value),
                                    radius: 30),
                              ),
                              Container(
                                child: showLock
                                    ? const SizedBox()
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
        );
  }

  Widget _buildImageButtons() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (index) => GestureDetector(
              onTap: () async {
                try {
                  await _updatePromptField(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prompt updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating prompt: $e')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 6,
                  height: MediaQuery.of(context).size.width / 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/prompts/prompt_$index.png'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LockIcon extends StatelessWidget {
  final double value;
  const LockIcon({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Opacity(
            opacity: 1 - value,
            child: const Image(
              image: AssetImage('assets/prompts/lock.png'),
              // width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class CircularBar extends CustomPainter {
  var offset = const Offset(0, 0);
  var radius = 10.0;
  var endAngle = (pi * 2 * 0.5);

  CircularBar(
      {required this.offset, required this.radius, required this.endAngle});
  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint()
      ..color = mainpurple
      ..strokeWidth = 4
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
