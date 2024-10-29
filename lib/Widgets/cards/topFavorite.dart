import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class TopFavoriteCard {
  static Future<List<CardModel>?> fetchTopFavoriteAndDistractorCards() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference favoritesCollection = FirebaseFirestore.instance.collection('favorites');

    try {
      QuerySnapshot snapshot = await favoritesCollection
          .doc(userId)
          .collection('cards')
          .orderBy('rank')
          .limit(2) // Fetch the top 2 cards
          .get();

      if (snapshot.docs.length >= 2) {
        // Extract the top favorite and the distractor card
        DocumentSnapshot topFavoriteDoc = snapshot.docs[0];
        DocumentSnapshot distractorDoc = snapshot.docs[1];

        return [
          CardModel.fromFirestore(topFavoriteDoc),
          CardModel.fromFirestore(distractorDoc),
        ];
      } else if (snapshot.docs.isNotEmpty) {
        // If there's only one card, return it as the top favorite without a distractor
        DocumentSnapshot topFavoriteDoc = snapshot.docs.first;
        return [CardModel.fromFirestore(topFavoriteDoc)];
      }
    } catch (e) {
      print('Error fetching top favorite and distractor cards: $e');
    }

    return null;
  }
}
