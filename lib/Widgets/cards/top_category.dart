import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class TopCategoryCard {
  static Future<List<CardModel>?> fetchTopCategoryAndDistractorCards(String selectedCategory) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    String studentID = userId ?? ''; // Replace with actual student ID if different

    CollectionReference categoryRankingCollection =
        FirebaseFirestore.instance.collection('categoryRanking');

    try {
      // Fetch cards for the selected category and student
      QuerySnapshot categorySnapshot = await categoryRankingCollection
          .doc(studentID) // Access the student's document
          .collection(selectedCategory) // Access the selected category
          .orderBy('rank') // Ensure the order is by rank
          .get();

      List<CardModel> validCards = [];
      
      // Map category card IDs to their ranks for ordering
      Map<String, int> categoryCardRanks = {
        for (var doc in categorySnapshot.docs) doc.id: doc['rank'] ?? 0
      };

      // Fetch the general cards collection for the user
      QuerySnapshot cardsSnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .get();

      Set<String> categoryCardIds = categoryCardRanks.keys.toSet();

      // Iterate through the cards and filter them
      for (var cardDoc in cardsSnapshot.docs) {
        if (categoryCardIds.contains(cardDoc.id)) {
          bool phase1Independence = cardDoc['phase1_independence'] ?? false;

          // Only include cards that are not marked with phase1_independence
          if (!phase1Independence) {
            validCards.add(CardModel.fromFirestore(cardDoc));
          }
        }
      }

      // Sort validCards by rank
      validCards.sort((a, b) => (categoryCardRanks[a.id] ?? 0).compareTo(categoryCardRanks[b.id] ?? 0));

      return validCards.isNotEmpty ? validCards : null;
    } catch (e) {
      print('Error fetching top category and distractor cards: $e');
    }

    return null;
  }
}
