// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';

class PromptButton extends StatefulWidget {
  final int phaseCurrent;

  const PromptButton({
    super.key,
    required this.phaseCurrent,
  });

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
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _firestoreService.fetchPhase();

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

    // Update prompt collection
    await firestore.collection('prompt').doc(uid).set({
      fieldToUpdate: FieldValue.increment(1),
      'email': auth.currentUser?.email ?? '',
    }, SetOptions(merge: true));

    updateActivityLog(index);
  }
  //act log
  Future<void> updateActivityLog(int index) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    User? user = auth.currentUser;

    if (user != null) {
      // Reference to activity_log document
      DocumentReference activityLogRef =
          firestore.collection('activity_log').doc(user.uid);

      // Add or merge user information in activity_log
      await activityLogRef.set({
        'email': user.email,
        'userID': user.uid,
      }, SetOptions(merge: true));

      int currentPhase = widget.phaseCurrent;

      // Reference to phase document
      DocumentReference phaseRef =
          activityLogRef.collection('phase').doc(currentPhase.toString());

      // Ensure the phase document exists, but do not reset total fields to 0
      await phaseRef.set({
        'phase': currentPhase,  // Only ensure the phase field is set, no resetting totals
      }, SetOptions(merge: true));

      // Get the most recent session
      QuerySnapshot lastSessionSnapshot = await phaseRef
          .collection('session')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      bool createNewSession = false;
      if (lastSessionSnapshot.docs.isNotEmpty) {
        DocumentSnapshot lastSessionDoc = lastSessionSnapshot.docs.first;
        Timestamp lastSessionTimestamp = lastSessionDoc['timestamp'];
        int totalTrials = lastSessionDoc['total_trials'];

        DateTime now = DateTime.now();
        Duration timeSinceLastSession =
            now.difference(lastSessionTimestamp.toDate());

        if (timeSinceLastSession.inMinutes >= 10 || totalTrials >= 20) {
          createNewSession = true;
        }
      } else {
        createNewSession = true;
      }

      // Reference for new or existing trial
      DocumentReference trialRef;
      if (createNewSession) {
        trialRef = phaseRef.collection('session').doc();
        await trialRef.set({
          'timestamp': FieldValue.serverTimestamp(),
          'total_trials': 1,
        }, SetOptions(merge: true));
      } else {
        trialRef = phaseRef
            .collection('session')
            .doc(lastSessionSnapshot.docs.first.id);
        await trialRef.update({
          'total_trials': FieldValue.increment(1),
        });
      }

      // Fetch the cardID from temp_recentCard collection
      DocumentSnapshot tempRecentCardSnapshot =
          await firestore.collection('temp_recentCard').doc(user.uid).get();

      if (tempRecentCardSnapshot.exists) {
        String cardID = tempRecentCardSnapshot.get('cardID');
        DocumentReference trialPromptRef =
            trialRef.collection('trialPrompt').doc(cardID);

        // Set the trial prompt document with cardID if not already created
        await trialPromptRef.set({
          'Independent': FieldValue.increment(0), 
          'Verbal': FieldValue.increment(0), 
          'Gestural': FieldValue.increment(0), 
          'Modeling': FieldValue.increment(0), 
          'Physical': FieldValue.increment(0), 
          'cardID': cardID,
        }, SetOptions(merge: true));

        String totalField;
        String trialPromptField;

        // Determine which field to update based on index
        switch (index) {
          case 0:
            totalField = 'totalPhysical';
            trialPromptField = 'Physical';
            break;
          case 1:
            totalField = 'totalModeling';
            trialPromptField = 'Modeling';
            break;
          case 2:
            totalField = 'totalGestural';
            trialPromptField = 'Gestural';
            break;
          case 3:
            totalField = 'totalVerbal';
            trialPromptField = 'Verbal';
            break;
          case 4:
            totalField = 'totalIndependent';
            trialPromptField = 'Independent';
            break;
          default:
            throw Exception("Invalid index");
        }

        // Firestore transaction to increment both the total and trial prompt fields
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot phaseSnapshot = await transaction.get(phaseRef);
          DocumentSnapshot trialPromptSnapshot =
              await transaction.get(trialPromptRef);

          if (!phaseSnapshot.exists || !trialPromptSnapshot.exists) {
            throw Exception("Required document does not exist!");
          }

          // Increment the relevant total field (e.g., totalPhysical) without resetting
          transaction.update(phaseRef, {
            totalField: FieldValue.increment(1),
          });

          // Increment the specific trial prompt field (e.g., Physical)
          transaction.update(trialPromptRef, {
            trialPromptField: FieldValue.increment(1),
          });
        });

        print("$totalField and $trialPromptField incremented successfully.");
      } else {
        print("Tap on a card first");
        throw Exception("Tap on a card first");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return showLock
                    ? _buildImageButtons()
                    : _buildPurpleContainer();
              },
            ),
          ),
        ],
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
                  if (index == 4) {
                    FlameAudio.play('bell_congrats.mp3');
                    Confetti.launch(
                      context,
                      options: const ConfettiOptions(
                          particleCount: 400, spread: 70, y: 0.6),
                    );
                  } else {
                    FlameAudio.play('chime_fast.mp3');
                  }
                  ;
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Prompt updated successfully')),
                  // );
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
