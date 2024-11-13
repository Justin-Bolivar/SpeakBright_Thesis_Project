// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';

class PromptButton extends StatefulWidget {
  final int phaseCurrent;
  final Function()? onRefresh;

  const PromptButton({super.key, required this.phaseCurrent, this.onRefresh});

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

  Future<void> _updatePromptField(int index, {bool isLoop = false}) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    User? user = auth.currentUser;

    if (user != null) {
      DocumentReference activityLogRef =
          firestore.collection('activity_log').doc(user.uid);

      await activityLogRef.set({
        'email': user.email,
        'userID': user.uid,
      }, SetOptions(merge: true));

      int currentPhase = widget.phaseCurrent;

      DocumentReference phaseRef =
          activityLogRef.collection('phase').doc(currentPhase.toString());

      await phaseRef.set({
        'phase': currentPhase,
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
            trialRef.collection('trialPrompt').doc();

        // Determine the prompt type based on index
        String promptType;
        switch (index) {
          case 0:
            promptType = 'Physical';
            break;
          case 1:
            promptType = 'Modeling';
            break;
          case 2:
            promptType = 'Gestural';
            break;
          case 3:
            promptType = 'Verbal';
            break;
          case 4:
            promptType = 'Independent';
            break;
          default:
            throw Exception("Invalid index");
        }

        // Firestore transaction to increment the total field and add a new trial prompt document
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot phaseSnapshot = await transaction.get(phaseRef);

          if (!phaseSnapshot.exists) {
            throw Exception("Required document does not exist!");
          }

          // Add a new document to the trialPrompt collection
          transaction.set(
            trialPromptRef,
            {
              'prompt': promptType,
              'cardID': cardID,
              'timestamp': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

          // If it's part of the loop (+10 Independent), don't delete tempRecentCard
          if (!isLoop) {
            // Delete tempRecentCard when not in the loop
            transaction.delete(tempRecentCardSnapshot.reference);
            print("Deleting tempRecentCard because it's not Independent.");
          } else {
            print("Not deleting tempRecentCard because it's part of the loop.");
          }
        });

        print("update log successfully.");
      } else {
        print("Tap on a card first");
        throw Exception("Tap on a card first");
      }
    }
  }

  Future<String?> fetchRecentCardID() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      print('User is not logged in');
      return null;
    }

    try {
      DocumentSnapshot tempRecentCardSnapshot =
          await firestore.collection('temp_recentCard').doc(uid).get();

      if (tempRecentCardSnapshot.exists) {
        String cardID = tempRecentCardSnapshot.get('cardID');
        return cardID;
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching recent card ID: $e');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 120,
            child: GestureDetector(
              onTap: () async {
                // Add +10 Independent to the activity log on button press
                for (int i = 0; i < 10; i++) {
                  // Pass isLoop as true for the loop case
                  await _updatePromptField(4,
                      isLoop: true); // Assuming 4 is "Independent"
                }
                Fluttertoast.showToast(
                    msg: "Looped 10 times: Activity log updated.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue, // Adjust the color as needed
                ),
                child: Center(
                  child: Text('+10', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
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

                    widget.onRefresh?.call();
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
