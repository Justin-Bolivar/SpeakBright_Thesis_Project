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

    bool isFavoriteNull = false;

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
        if (targetCardId == null) isFavoriteNull = true;
      }

      if (isFavoriteNull) {
        // Fetch main_category_ranking
        DocumentSnapshot categoryRankingDoc = await firestore
            .collection('main_category_ranking')
            .doc(userId)
            .get();

        if (!categoryRankingDoc.exists) {
          print('No main_category_ranking document found for user $userId');
          return null;
        }

        List<dynamic>? categories =
            (categoryRankingDoc.data() as Map<String, dynamic>)['categories'];
        if (categories == null || categories.isEmpty) {
          print('No categories found in main_category_ranking');
          return null;
        }

        // Iterate over categories to find the target card
        for (var categoryEntry in categories) {
          String category = categoryEntry['category'];

          // Fetch cards in the categoryRanking collection
          QuerySnapshot categorySnapshot = await firestore
              .collection('categoryRanking')
              .doc(userId)
              .collection(category)
              .orderBy('rank')
              .get();

          if (categorySnapshot.docs.isEmpty) {
            print('No cards found in categoryRanking for category $category');
            continue;
          }

          for (var cardDoc in categorySnapshot.docs) {
            // Check phase1_independence in the cards collection
            DocumentSnapshot cardSnapshot =
                await firestore.collection('cards').doc(cardDoc.id).get();

            if (!cardSnapshot.exists) {
              print('Card not found in cards collection for ID: ${cardDoc.id}');
              continue;
            }

            Map<String, dynamic>? cardData =
                cardSnapshot.data() as Map<String, dynamic>?;
            bool isPhase1Independence =
                cardData?['phase1_independence'] ?? false;

            // Only select cards with phase1_independence == false
            if (!isPhase1Independence) {
              targetCardId = cardDoc.id;
              print('Found targetCardId: $targetCardId in category: $category');
              break; // Stop searching once a valid card is found
            }
          }

          if (targetCardId != null) {
            break; // Exit the outer loop once a card is found
          }
        }

        if (targetCardId == null) {
          print('No valid card found in any category');
          return null;
        }
      }

      // Step 3: Fetch potential distractor cards
      QuerySnapshot cardsSnapshot = await firestore
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .get();

      List<CardModel> validCards = [];
      String? targetCategory;

// Fetch the category of the target card
      if (targetCardId != null) {
        DocumentSnapshot targetCardSnapshot =
            await firestore.collection('cards').doc(targetCardId).get();

        if (targetCardSnapshot.exists) {
          Map<String, dynamic>? targetCardData =
              targetCardSnapshot.data() as Map<String, dynamic>?;
          targetCategory = targetCardData?['category'];
        }
      }

      List<CardModel> fallbackCards = [];

      for (var cardDoc in cardsSnapshot.docs) {
        Map<String, dynamic>? cardData =
            cardDoc.data() as Map<String, dynamic>?;

        String? cardCategory = cardData?['category'];

        // Check if the card matches the target category or doesn't
        bool isSameCategory = (cardCategory == targetCategory);
        bool isPhase1Independence = cardData?['phase1_independence'] ?? false;

        if (isSameCategory && cardDoc.id != targetCardId) {
          // Prioritize cards in the same category as the target card
          validCards.add(CardModel.fromFirestore(cardDoc));
        } else if (!isSameCategory &&
            !isPhase1Independence &&
            cardDoc.id != targetCardId) {
          // Collect fallback cards
          fallbackCards.add(CardModel.fromFirestore(cardDoc));
        } else if (cardDoc.id != targetCardId) {
          fallbackCards.add(CardModel.fromFirestore(cardDoc));
        }
      }

// If no cards match the same category, use randomized fallback cards
      if (validCards.isEmpty) {
        fallbackCards.shuffle(); // Randomize the order of fallback cards
        validCards = fallbackCards;
      }

      List<CardModel> result = [];
      // Fetch the target card details
      DocumentSnapshot targetCardDoc =
          await firestore.collection('cards').doc(targetCardId).get();

      if (targetCardDoc.exists) {
        CardModel targetCardModel = CardModel.fromFirestore(targetCardDoc);
        result.add(targetCardModel);
      }

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
