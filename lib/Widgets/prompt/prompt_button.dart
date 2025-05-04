// ignore_for_file: avoid_print, use_build_context_synchronously, unused_field

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/providers/card_activity_provider.dart';
import 'package:toastification/toastification.dart';

class PromptButton extends ConsumerStatefulWidget {
  final int phaseCurrent;
  final Function()? onRefresh;

  const PromptButton({super.key, required this.phaseCurrent, this.onRefresh});

  @override
  // ignore: library_private_types_in_public_api
  _PromptButtonState createState() => _PromptButtonState();
}

class _PromptButtonState extends ConsumerState<PromptButton>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation _animation;
  bool showLock = false;
  bool isAnimationCompleted = false;
  final FirestoreService _firestoreService = FirestoreService();

// Buffer to store the taps temporarily before uploading
  List<Map<String, dynamic>> tapBuffer = [];

  @override
  void initState() {
    super.initState();
    // Register this widget to listen for lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    // _firestoreService.fetchPhase();

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

  @override
  void dispose() {
    // Unregister this widget when it's disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  Future<void> bufferTapEvent(int index, String? cardID, bool withDistractor,
      bool withDistractor2) async {
    final provider = ref.watch(cardActivityProvider);
    // bool updateSuccess = false;
    // Store the event locally
    if (cardID != null) {
      if (widget.phaseCurrent == 1) {
        tapBuffer.add({
          'index': index,
          'cardID': cardID,
          'timestamp': DateTime.now(),
          'withDistractor': withDistractor,
          'withDistractor2': withDistractor2
        });
      } else {
        tapBuffer.add({
          'index': index,
          'cardID': cardID,
          'timestamp': DateTime.now(),
          'withDistractor': true,
          'withDistractor2': true
        });
      }
    }

    int trial = tapBuffer.length;
    ref.read(cardActivityProvider.notifier).setTrial(trial);
    print('Current buffer size (trial): $trial');

    if (tapBuffer.length >= provider.bufferSize ||
        provider.trial > provider.bufferSize) {
      _uploadBufferedTaps();
      _firestoreService.updatePhaseIndependence(
          cardID!, widget.phaseCurrent, ref);

      // Reset provider and buffer
      ref.read(cardActivityProvider.notifier).reset();
      widget.onRefresh?.call();
    }
  }

  Future<void> _uploadBufferedTaps() async {
    if (tapBuffer.isEmpty) return;

    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final activityLogRef = firestore.collection('activity_log').doc(user.uid);
      final currentPhase = widget.phaseCurrent;
      final phaseRef =
          activityLogRef.collection('phase').doc(currentPhase.toString());

      await activityLogRef.set({
        'email': user.email,
        'userID': user.uid,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Ensure the phase document exists (if not, create it)
      DocumentSnapshot phaseSnapshot = await phaseRef.get();
      if (!phaseSnapshot.exists) {
        print("Phase document not found, creating new phase document");
        await phaseRef.set({'createdAt': FieldValue.serverTimestamp()});
      }

      await phaseRef.set({
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final trialRef = phaseRef.collection('session').doc();

      WriteBatch batch = firestore.batch();

      int independentDistractorCount = 0;
      int totalDistractorCount = 0;

      int independentDistractorTwoCount = 0;
      int totalDistractorTwoCount = 0;

      int independentCount = 0;
      int totalTaps = 0;

      bool updateSuccess = false;
      String? targetCardId;

      // Process each buffered tap event
      for (var tap in tapBuffer) {
        final cardID = tap['cardID'];
        if (cardID == null) {
          print("CardID is null in tap, skipping this tap.");
          continue; // Skip this iteration if cardID is null
        }

        if (tap['index'] != 5) {
          targetCardId = tap['cardID'];
        }

        final trialPromptRef = trialRef.collection('trialPrompt').doc();

        if (tap['withDistractor'] != null) {
          if (tap['withDistractor']) {
            totalDistractorCount++;
            if (tap['index'] == 4) {
              independentDistractorCount++;
            }
          }
        }

        if (tap['withDistractor2'] != null) {
          if (tap['withDistractor2']) {
            totalDistractorTwoCount++;
            if (tap['index'] == 4) {
              independentDistractorTwoCount++;
            }
          }
        }

        if (tap['index'] == 4) {
          independentCount++;
        }
        totalTaps++;

        batch.set(trialPromptRef, {
          'prompt': [
            'Physical',
            'Modeling',
            'Gestural',
            'Verbal',
            'Independent',
            'IndependentWrong'
          ][tap['index']],
          'cardID': cardID,
          'timestamp': tap['timestamp'],
          'withDistractor': tap['withDistractor'],
          'withDistractor2': tap['withDistractor2'],
        });
      }

      await trialRef.set({
        'independentDistractorCount': independentDistractorCount,
        'totalDistractorCount': totalDistractorCount,
        'independentDistractorTwoCount': independentDistractorTwoCount,
        'totalDistractorTwoCount': totalDistractorTwoCount,
        'independentCount': independentCount,
        'totalTaps': totalTaps,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Session document created with distractor counts");

      await batch.commit();
      print("Batch write completed");

      if (ref.watch(cardActivityProvider).showDistractor ||
          ref.watch(cardActivityProvider).showDistractor2 ||
          widget.phaseCurrent == 2 ||
          widget.phaseCurrent == 3) {
        bool isEmotion = await _firestoreService.isEmotion(targetCardId);
        updateSuccess = await _firestoreService
            .autoUpdatePhase(widget.phaseCurrent, isEmotion: isEmotion);

        if (updateSuccess) {
          if (widget.phaseCurrent == 2 || widget.phaseCurrent == 3) {
            phase4Unlocked(context);
          } else if (isEmotion) {
            phase3Unlocked(context);
          } else {
            phase2Unlocked(context);
          }
        }
      }

      tapBuffer.clear();
      // ref.read(cardActivityProvider.notifier).reset();

      Fluttertoast.showToast(
        msg: "Session ended successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print("Error uploading batch: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _uploadBufferedTaps();
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
            top: 50,
            right: 0,
            child: PopupMenuButton<int>(
              onSelected: (value) async {
                switch (value) {
                  case 1: // Add +10 Independent
                    for (int i = 0; i < 10; i++) {
                      bufferTapEvent(
                        4, // Index for "Independent"
                        ref.watch(cardActivityProvider).cardId,
                        ref.watch(cardActivityProvider).showDistractor,
                        ref.watch(cardActivityProvider).showDistractor2,
                      );
                      ref.read(cardActivityProvider).tapPrompt(4);
                    }
                    Fluttertoast.showToast(
                      msg: "Looped Independent 10 times: Activity log updated.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    break;
                  case 2: // Add +5 Independent
                    _firestoreService.setCurrentlyLearningCard(
                      ref.watch(cardActivityProvider).cardId,
                    );
                    for (int i = 0; i < 5; i++) {
                      bufferTapEvent(
                        4,
                        ref.watch(cardActivityProvider).cardId,
                        ref.watch(cardActivityProvider).showDistractor,
                        ref.watch(cardActivityProvider).showDistractor2,
                      );
                      ref.read(cardActivityProvider).tapPrompt(4);
                    }
                    Fluttertoast.showToast(
                      msg: "Looped Independent 5 times: Activity log updated.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    break;
                  case 3: // Add +5 Verbal
                    _firestoreService.setCurrentlyLearningCard(
                      ref.watch(cardActivityProvider).cardId,
                    );
                    for (int i = 0; i < 5; i++) {
                      bufferTapEvent(
                        3, // Index for "Verbal"
                        ref.watch(cardActivityProvider).cardId,
                        ref.watch(cardActivityProvider).showDistractor,
                        ref.watch(cardActivityProvider).showDistractor2,
                      );
                      ref.read(cardActivityProvider).tapPrompt(4);
                    }
                    Fluttertoast.showToast(
                      msg: "Looped Verbal 5 times: Activity log updated.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Text("+10 Independent"),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text("+5 Independent"),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text("+5 Verbal"),
                ),
              ],
              icon: Icon(
                Icons.more_vert, // Change icon if needed
                color: kDarkPruple.withOpacity(0.5),
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
    final cardID = ref.watch(cardActivityProvider).cardId;
    final withDistractor = widget.phaseCurrent > 1
        ? true
        : ref.watch(cardActivityProvider).showDistractor;
    final withDistractor2 = widget.phaseCurrent > 1
        ? true
        : ref.watch(cardActivityProvider).showDistractor2;
    print('Distractor bool: $withDistractor, Phase is ${widget.phaseCurrent}');

    int promptIndexSize = withDistractor || withDistractor2 ? 6 : 5;
    int promptButtonSize = withDistractor || withDistractor2 ? 7 : 6;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            promptIndexSize,
            (index) => GestureDetector(
              onTap: () async {
                try {
                  _firestoreService.setCurrentlyLearningCard(cardID);
                  // await _updatePromptField(index);

                  if (cardID == null) {
                    Fluttertoast.showToast(
                      msg: "TAP A CARD FIRST",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: const Color.fromARGB(255, 215, 187, 26),
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }

                  bufferTapEvent(
                      index, cardID, withDistractor, withDistractor2);
                  if (index == 4) {
                    FlameAudio.play('bell_congrats.mp3');
                    Confetti.launch(
                      context,
                      options: const ConfettiOptions(
                          particleCount: 400, spread: 70, y: 0.6),
                    );

                    ref.read(cardActivityProvider).tapPrompt(index);

                    widget.onRefresh?.call();
                  } else if (index == 5) {
                    //no sound
                  } else {
                    FlameAudio.play('chime_fast.mp3');
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating prompt: $e')),
                  );
                }
                ref.read(cardActivityProvider.notifier).resetCardID();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width / promptButtonSize,
                  height: MediaQuery.of(context).size.width / promptButtonSize,
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

ToastificationItem phase3Unlocked(BuildContext context) {
  return toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    title: const Text("Phase 3 Unlocked"),
    description: const Text("Congratulations!"),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 5),
    primaryColor: phase3Color,
    backgroundColor: const Color(0xffffffff),
    foregroundColor: const Color(0xffffffff),
    icon: const Icon(Iconsax.medal_star),
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: highModeShadow,
    dragToClose: true,
    applyBlurEffect: true,
  );
}

ToastificationItem phase2Unlocked(BuildContext context) {
  return toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    title: const Text("Phase 2 Unlocked"),
    description: const Text("Congratulations!"),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 5),
    primaryColor: phase2Color,
    backgroundColor: const Color(0xffffffff),
    foregroundColor: const Color(0xffffffff),
    icon: const Icon(Iconsax.medal_star),
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: highModeShadow,
    dragToClose: true,
    applyBlurEffect: true,
  );
}

ToastificationItem phase4Unlocked(BuildContext context) {
  return toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    title: const Text("Phase 4 Unlocked"),
    description: const Text("Congratulations!"),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 5),
    primaryColor: phase4Color,
    backgroundColor: const Color(0xffffffff),
    foregroundColor: const Color(0xffffffff),
    icon: const Icon(Iconsax.medal_star),
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: highModeShadow,
    dragToClose: true,
    applyBlurEffect: true,
  );
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
