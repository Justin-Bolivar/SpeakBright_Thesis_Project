// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class TopFavoriteCard {
  static Future<List<CardModel>?> fetchTopFavoriteAndDistractorCards() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference favoritesCollection =
        FirebaseFirestore.instance.collection('favorites');

    try {
      QuerySnapshot favoritesSnapshot = await favoritesCollection
          .doc(userId)
          .collection('cards')
          .orderBy('rank')
          .get();

      List<CardModel> validCards = [];

      // Map favorite card IDs to their ranks for ordering
      Map<String, int> favoriteCardRanks = {
        for (var doc in favoritesSnapshot.docs) doc.id: doc['rank'] ?? 0
      };

      QuerySnapshot cardsSnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: userId)
          .get();

      Set<String> favoriteCardIds = favoriteCardRanks.keys.toSet();

      for (var cardDoc in cardsSnapshot.docs) {
        if (favoriteCardIds.contains(cardDoc.id)) {
          bool phase1Independence = cardDoc['phase1_independence'] ?? false;

          if (!phase1Independence) {
            validCards.add(CardModel.fromFirestore(cardDoc));
          }
        }
      }

      // Sort validCards by rank
      validCards.sort((a, b) => (favoriteCardRanks[a.id] ?? 0)
          .compareTo(favoriteCardRanks[b.id] ?? 0));

      return validCards.isNotEmpty ? validCards : null;
    } catch (e) {
      print('Error fetching top favorite and distractor cards: $e');
    }

    return null;
  }
}
