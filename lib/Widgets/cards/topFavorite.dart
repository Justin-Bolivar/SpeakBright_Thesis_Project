import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class TopFavoriteCard {
  static Future<CardModel?> fetchTopFavoriteCard() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference favoritesCollection = FirebaseFirestore.instance.collection('favorites');

    try {
      QuerySnapshot snapshot = await favoritesCollection.doc(userId).collection('cards')
          .orderBy('rank') 
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        return CardModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching top favorite card: $e');
    }

    return null; 
  }
}
