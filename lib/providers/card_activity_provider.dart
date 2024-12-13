// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final cardActivityProvider =
    ChangeNotifierProvider<CardActivityProvider>((ref) {
  return CardActivityProvider();
});

class CardActivityProvider extends ChangeNotifier {
  String? _cardId;
  bool _showDistractor = false;
  bool _showDistractor2 = false;
  int _independentTapCount = 0;
  int _trial = 0;
  int _bufferSize = 20;

  String? get cardId => _cardId;
  bool get showDistractor => _showDistractor;
  bool get showDistractor2 => _showDistractor2;
  int get trial => _trial;
  int get bufferSize => _bufferSize;


  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update card ID
  void setCardId(String? cardId) {
    _cardId = cardId;
    notifyListeners();
  }

  // Check recent sessions for showDistractor2 criteria
  Future<bool> _checkRecentSessionsForShowDistractor2(String cardID) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final activityLogRef = _firestore.collection('activity_log').doc(uid);

    // Fetch the 3 most recent sessions
    QuerySnapshot sessionSnapshot = await activityLogRef
        .collection('phase')
        .doc('1')
        .collection('session')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    if (sessionSnapshot.docs.length < 3) {
      return false; // Less than 3 sessions
    }

    int totalIndependentDistractorCount = 0;
    int totalDistractorCount = 0;
    int validSession = 0;

    // Iterate over the fetched sessions
    for (var sessionDoc in sessionSnapshot.docs) {
      int independentDistractorCount =
          sessionDoc['independentDistractorCount'] ?? 0;
      int distractorCount = sessionDoc['totalDistractorCount'] ?? 0;
      int independentDistractorTwoCount =
          sessionDoc['independentDistractorTwoCount'] ?? 0;
      int totalDistractorTwoCount = sessionDoc['totalDistractorTwoCount'] ?? 0;

      // Access the 'trialPrompt' collection inside the session document
      QuerySnapshot trialPromptSnapshot = await sessionDoc.reference
          .collection('trialPrompt')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .where('cardID', isEqualTo: cardID)
          .get();

      if (trialPromptSnapshot.docs.isEmpty) {
        return false;
      } else {
        if (independentDistractorTwoCount > 0) {
          if ((independentDistractorTwoCount / totalDistractorTwoCount) * 100 >=
              70) return true;
          return false;
        } else if (distractorCount > 0) {
          validSession++;
        } else {
          return false;
        }
      }

      totalIndependentDistractorCount += independentDistractorCount;
      totalDistractorCount += distractorCount;
    }

    if (totalDistractorCount == 0) return false;
    if (validSession < 3) return false;

    double distractorIndependencePercentage =
        (totalIndependentDistractorCount / totalDistractorCount) * 100;
    print(
        'Distractor Independence Percentage for $cardID: $distractorIndependencePercentage%');

    return distractorIndependencePercentage >= 70;
  }

  // Check recent sessions for showDistractor criteria
  Future<bool> _checkRecentSessionsForShowDistractor(String cardID) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final activityLogRef = _firestore.collection('activity_log').doc(uid);

    // Fetch the 3 most recent sessions
    QuerySnapshot sessionSnapshot = await activityLogRef
        .collection('phase')
        .doc('1')
        .collection('session')
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();

    if (sessionSnapshot.docs.length < 3) {
      return false; // Less than 3 sessions
    }

    int totalIndependentCount = 0;
    int totalTapsCount = 0;

    for (var sessionDoc in sessionSnapshot.docs) {
      int independentCount = sessionDoc['independentCount'] ?? 0;
      int totalTaps = sessionDoc['totalTaps'] ?? 0;

      QuerySnapshot trialPromptSnapshot = await sessionDoc.reference
          .collection('trialPrompt')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .where('cardID', isEqualTo: cardID)
          .get();

      if (trialPromptSnapshot.docs.isEmpty) {
        return false;
      }

      totalIndependentCount += independentCount;
      totalTapsCount += totalTaps;
    }

    if (totalTapsCount == 0) return false;

    double independencePercentage =
        (totalIndependentCount / totalTapsCount) * 100;
    print('Independence Percentage for $cardID: $independencePercentage%');

    return independencePercentage >= 70;
  }

  // Handle prompt taps
  Future<void> tapPrompt(int promptIndex) async {
    if (_cardId == null) {
      print("TAP PROMPT CARDID IS NULL");
      return;
    }

    // Track independent taps if the criteria are met
    if (promptIndex == 4) {
      _independentTapCount++;
      print('Independent taps: $_independentTapCount');
    } else {
      _independentTapCount = 0;
    }

    // Show distractor if there are 5 consecutive independent taps
    if (_independentTapCount >= 5 && _cardId != null) {
      bool showDistractor2CriteriaMet =
          await _checkRecentSessionsForShowDistractor2(_cardId!);

      if (showDistractor2CriteriaMet) {
        _showDistractor2 = true;
        _showDistractor = false;
        print('SHOW 2 DSTRTRR: $showDistractor2CriteriaMet');
      } else {
        bool showDistractorCriteriaMet =
            await _checkRecentSessionsForShowDistractor(_cardId!);
        print('SHOW DSTRTRR: $showDistractorCriteriaMet');

        _showDistractor = showDistractorCriteriaMet;
      }

      notifyListeners();
    }
  }

  void setTrial(int trialCount) {
    _trial = trialCount;
    notifyListeners();
  }

  void setbufferSize(int size) {
    _bufferSize = size;
    notifyListeners();
  }


  // Reset values if needed
  void reset() {
    _cardId = null;
    _showDistractor = false;
    _showDistractor2 = false;
    _independentTapCount = 0;
    _trial = 0;
    print(
        'RESET! showDistractor: $_showDistractor, showDistractor2: $_showDistractor2');
    notifyListeners();
  }
}
