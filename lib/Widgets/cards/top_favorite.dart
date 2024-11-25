// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class TopFavoriteCard {
  static Future<List<CardModel>?> fetchTopFavoriteAndDistractorCards() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null; // Exit early if no user is logged in

    CollectionReference favoritesCollection =
        FirebaseFirestore.instance.collection('favorites');
    CollectionReference currentlyLearningCollection =
        FirebaseFirestore.instance.collection('currently_learning');


    try {
      // Fetch the currently learning card (if any)
      QuerySnapshot currentlyLearningSnapshot =
          await currentlyLearningCollection
              .doc(userId)
              .collection('Favorites')
              .limit(1)
              .get();

      QueryDocumentSnapshot? currentlyLearningDoc =
          currentlyLearningSnapshot.docs.isNotEmpty
              ? currentlyLearningSnapshot.docs.first
              : null;

      String? currentlyLearningCardId;
      bool isCurrentlyLearningPhase1Independence = false;

      if (currentlyLearningDoc != null) {
        Map<String, dynamic>? data =
            currentlyLearningDoc.data() as Map<String, dynamic>?;
        currentlyLearningCardId = data?['cardId'];

        print(currentlyLearningCardId);

        if (currentlyLearningCardId != null) {
          // Fetch card info for the currently learning card
          QuerySnapshot cardSnapshot = await FirebaseFirestore.instance
              .collection('cards')
              .where('cardId', isEqualTo: currentlyLearningCardId)
              .limit(1)
              .get();

          if (cardSnapshot.docs.isNotEmpty) {
            DocumentSnapshot cardDoc = cardSnapshot.docs.first;
            Map<String, dynamic>? cardDocData =
                cardDoc.data() as Map<String, dynamic>?;
            isCurrentlyLearningPhase1Independence =
                cardDocData?['phase1_independence'] ?? true;
          }
        }
      }

      // If there's no currently learning card or it's phase1_independence true, use the top favorite
      String targetCardId;
      bool targetCardPhase1Independence = true;

      if (currentlyLearningCardId != null &&
          !isCurrentlyLearningPhase1Independence) {
        targetCardId = currentlyLearningCardId;
        targetCardPhase1Independence = false;
      } else {
        // Fetch favorite cards and their ranks
        QuerySnapshot favoritesSnapshot = await favoritesCollection
            .doc(userId)
            .collection('cards')
            .orderBy('rank')
            .get();

        if (favoritesSnapshot.docs.isEmpty) {
          return null;
        }

        // Find the top-ranked favorite card (rank 1)
        var topFavoriteDoc = favoritesSnapshot.docs.first;
        targetCardId = topFavoriteDoc.id;
        Map<String, dynamic>? topFavoriteData =
            topFavoriteDoc.data() as Map<String, dynamic>?;
        targetCardPhase1Independence =
            topFavoriteData?['phase1_independence'] ?? true;
      }

      // Fetch all cards to find the distractor
      QuerySnapshot cardsSnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .get();

      List<CardModel> validCards = [];

      // Get the distractor card (any favorite card except the target card)
      for (var cardDoc in cardsSnapshot.docs) {
        Map<String, dynamic>? cardData =
            cardDoc.data() as Map<String, dynamic>?;

        if (cardDoc.id != targetCardId) {
          bool phase1Independence = cardData?['phase1_independence'] ?? false;

          if (!phase1Independence) {
            validCards.add(CardModel.fromFirestore(cardDoc));
          }
        }
      }

      // Return the favorite (target) card and distractor cards
      List<CardModel> result = [];
      CardModel? targetCardModel;

      // Fetch target card details
      DocumentSnapshot targetCardDoc = await FirebaseFirestore.instance
          .collection('cards')
          .doc(targetCardId)
          .get();

      if (targetCardDoc.exists) {
        targetCardModel = CardModel.fromFirestore(targetCardDoc);
        result.add(targetCardModel); // Add target card (favorite)
      }

      // Add a random distractor card (if available)
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
