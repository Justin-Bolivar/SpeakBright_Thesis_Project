// ignore_for_file: avoid_print, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';

class TopCategoryCard {
  static Future<List<CardModel>?> fetchTopCategoryAndDistractorCards(
      String selectedCategory) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null; // Exit early if no user is logged in

    String studentID = userId;
    CollectionReference categoryRankingCollection =
        FirebaseFirestore.instance.collection('categoryRanking');
    CollectionReference currentlyLearningCollection =
        FirebaseFirestore.instance.collection('currently_learning');
    CollectionReference cardsCollection =
        FirebaseFirestore.instance.collection('cards');

    String? currentlyLearningCardId;
    bool isCurrentlyLearningPhase1Independence = false;

    try {
      // Step 1: Fetch the currently learning card (if any) for the selected category
      QuerySnapshot currentlyLearningSnapshot =
          await currentlyLearningCollection
              .doc(userId)
              .collection(selectedCategory)
              .limit(1)
              .get();

      QueryDocumentSnapshot? currentlyLearningDoc =
          currentlyLearningSnapshot.docs.isNotEmpty
              ? currentlyLearningSnapshot.docs.first
              : null;

      if (currentlyLearningDoc != null) {
        Map<String, dynamic>? data =
            currentlyLearningDoc.data() as Map<String, dynamic>?;
        currentlyLearningCardId = data?['cardId'];

        Fluttertoast.showToast(
            msg: "Fetched from Currently Learning",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: ugYellow,
            textColor: lGray,
            fontSize: 16.0);

        if (currentlyLearningCardId != null) {
          // Fetch card info for the currently learning card
          QuerySnapshot cardSnapshot = await cardsCollection
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

      // Step 2: Determine the target card
      String targetCardId;
      bool targetCardPhase1Independence = true;

      if (currentlyLearningCardId != null &&
          !isCurrentlyLearningPhase1Independence) {
        // Use the currently learning card if it exists and is not phase1_independent
        targetCardId = currentlyLearningCardId;
        targetCardPhase1Independence = false;
      } else {
        // Step 3: Fetch the top-ranked card from the selected category
        QuerySnapshot categorySnapshot = await categoryRankingCollection
            .doc(studentID)
            .collection(selectedCategory)
            .orderBy('rank')
            .get();

        if (categorySnapshot.docs.isEmpty) return null;

        var topCategoryDoc = categorySnapshot.docs.first;
        targetCardId = topCategoryDoc.id;
        Map<String, dynamic>? topCategoryData =
            topCategoryDoc.data() as Map<String, dynamic>?;
        targetCardPhase1Independence =
            topCategoryData?['phase1_independence'] ?? true;
      }

      // Step 4: Fetch all cards to find distractor cards
      QuerySnapshot cardsSnapshot =
          await cardsCollection.where('userId', isEqualTo: userId).get();

      List<CardModel> validCards = [];

      // Find distractor cards
      for (var cardDoc in cardsSnapshot.docs) {
        Map<String, dynamic>? cardData =
            cardDoc.data() as Map<String, dynamic>?;

        // Exclude the target card and check for phase1_independence
        if (cardDoc.id != targetCardId) {
          bool phase1Independence = cardData?['phase1_independence'] ?? false;

          if (!phase1Independence) {
            validCards.add(CardModel.fromFirestore(cardDoc));
          }
        }
      }

      // Step 5: Prepare the result list
      List<CardModel> result = [];

      // Fetch target card details
      DocumentSnapshot targetCardDoc =
          await cardsCollection.doc(targetCardId).get();

      if (targetCardDoc.exists) {
        CardModel targetCardModel = CardModel.fromFirestore(targetCardDoc);
        result.add(targetCardModel); // Add the target card

        // Add a random distractor card if available
        if (validCards.isNotEmpty) {
          result.add(validCards[0]);
        }
      }

      return result.isNotEmpty ? result : null;
    } catch (e) {
      print('Error fetching top category and distractor cards: $e');
    }

    return null;
  }
}
