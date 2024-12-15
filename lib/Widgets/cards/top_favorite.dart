// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class TopFavoriteCard {
  static Future<List<CardModel>?> fetchTopFavoriteAndDistractorCards() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference favoritesCollection = firestore.collection('favorites');
    CollectionReference currentlyLearningCollection =
        firestore.collection('currently_learning');

    try {
      String? targetCardId;
      bool isCurrentlyLearningPhase1Independence = false;

      // Step 1: Check the currently learning card first
      QuerySnapshot currentlyLearningSnapshot =
          await currentlyLearningCollection
              .doc(userId)
              .collection('Favorites')
              .limit(1)
              .get();

      if (currentlyLearningSnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot currentlyLearningDoc =
            currentlyLearningSnapshot.docs.first;
        Map<String, dynamic>? data =
            currentlyLearningDoc.data() as Map<String, dynamic>?;
        String? currentlyLearningCardId = data?['cardId'];

        if (currentlyLearningCardId != null) {
          DocumentSnapshot cardSnapshot = await firestore
              .collection('cards')
              .doc(currentlyLearningCardId)
              .get();

          if (cardSnapshot.exists) {
            Map<String, dynamic>? cardData =
                cardSnapshot.data() as Map<String, dynamic>?;
            isCurrentlyLearningPhase1Independence =
                cardData?['phase1_independence'] ?? true;

            // If the currently learning card is NOT phase1_independence, use it as the target card
            if (!isCurrentlyLearningPhase1Independence) {
              targetCardId = currentlyLearningCardId;

              print(
                  '!isCurrentlyLearningPhase1Independence and target card is $targetCardId');
            }
          }
        }
      }

      // Step 2: If no valid currently learning card, fetch from top favorites
      if (targetCardId == null) {
        QuerySnapshot favoritesSnapshot = await favoritesCollection
            .doc(userId)
            .collection('cards')
            .orderBy('rank')
            .get();

        for (var doc in favoritesSnapshot.docs) {
          
          String cardId = doc.id;
          DocumentSnapshot cardSnapshot =
              await firestore.collection('cards').doc(cardId).get();

          if (!cardSnapshot.exists) {
            print('Card not found for $cardId');
            continue;
          }

          Map<String, dynamic>? cardData =
              cardSnapshot.data() as Map<String, dynamic>?;

          // Only consider cards with phase1_independence set to false
          bool isPhase1Independence = cardData?['phase1_independence'] ?? false;
          if (!isPhase1Independence) {
            targetCardId = cardId;
            break; // Stop the loop once we find a suitable card
          }
        }

        // If no valid favorite card found, return null
        if (targetCardId == null) return null;
      }

      // Step 3: Fetch potential distractor cards
      QuerySnapshot cardsSnapshot = await firestore
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .get();

      List<CardModel> validCards = [];
      for (var cardDoc in cardsSnapshot.docs) {
        Map<String, dynamic>? cardData =
            cardDoc.data() as Map<String, dynamic>?;
        // Exclude the target card and any cards with phase1_independence set to true
        if (cardDoc.id != targetCardId &&
            !(cardData?['phase1_independence'] ?? false)) {
          validCards.add(CardModel.fromFirestore(cardDoc));
        }
      }

      List<CardModel> result = [];
      // Fetch the target card details
      DocumentSnapshot targetCardDoc =
          await firestore.collection('cards').doc(targetCardId).get();

      if (targetCardDoc.exists) {
        CardModel targetCardModel = CardModel.fromFirestore(targetCardDoc);
        result.add(targetCardModel);
      }

      // Add a distractor card if available
      if (validCards.isNotEmpty) {
        result.add(validCards[0]);
      }

      return result.isNotEmpty ? result : null;
    } catch (e) {
      print('Error fetching top favorite and distractor cards: $e');
    }

    return null;
  }
}
