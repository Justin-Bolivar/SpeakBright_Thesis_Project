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
  int _independentTapCount = 0;

  String? get cardId => _cardId;
  bool get showDistractor => _showDistractor;

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update card ID
  void setCardId(String? cardId) {
    _cardId = cardId;
    notifyListeners();
  }

  // Check if the card meets the session criteria
  Future<bool> _checkRecentSessionsForCard(String cardID) async {
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

    int validSessionsCount = 0;

    // Iterate over the fetched sessions
    for (var sessionDoc in sessionSnapshot.docs) {
      final trialPromptCollection =
          sessionDoc.reference.collection('trialPrompt');

      // Check if the session contains the given cardID in its `trialPrompt` subcollection
      QuerySnapshot trialPromptSnapshot = await trialPromptCollection
          .where('cardID', isEqualTo: cardID)
          .limit(1)
          .get();

      // If no matching trial prompt is found, mark this session as invalid and stop further processing
      if (trialPromptSnapshot.docs.isEmpty) {
        print("Session ${sessionDoc.id} is invalid for cardID $cardID");
        continue;
      }

      // Increment valid session count
      validSessionsCount++;

      int independentCount = sessionDoc['independentCount'] ?? 0;
      int totalTaps = sessionDoc['totalTaps'] ?? 0;

      totalIndependentCount += independentCount;
      totalTapsCount += totalTaps;

      if (validSessionsCount >= 3) break;
    }

// Check if there are at least 3 valid sessions
    if (validSessionsCount < 3) {
      print("Insufficient valid sessions for cardID $cardID in phase 1");
      return false;
    }

    if (totalTapsCount == 0) {
      return false; // No taps recorded across the sessions
    }

    double independencePercentage =
        (totalIndependentCount / totalTapsCount) * 100;
    print('Independence Percentage for $cardID: $independencePercentage%');

    return independencePercentage >= 70;
  }

  // Handle prompt taps
  Future<void> tapPrompt(int promptIndex) async {
    if (_cardId == null) return;

    // Check if the card meets the 3-session, 70% independence criteria

    // Track independent taps if the criteria are met
    if (promptIndex == 4) {
      // Independent prompt index
      _independentTapCount++;
      print('Independent taps: $_independentTapCount');
    } else {
      _independentTapCount = 0; // Reset if a different prompt is tapped
    }

    // Show distractor if there are 4 consecutive independent taps
    if (_independentTapCount >= 5) {
      bool meetsCriteria = await _checkRecentSessionsForCard(_cardId!);

      if (!meetsCriteria) {
        _showDistractor = false;
        notifyListeners();
        return;
      }

      _showDistractor = true;
      notifyListeners();
    }
  }

  // Reset values if needed
  void reset() {
    _cardId = null;
    _showDistractor = false;
    _independentTapCount = 0;
    print('RESEEEETTT!!!!!!!!! $showDistractor, count: $_independentTapCount, priv: $_showDistractor');

    notifyListeners();
  }
}
