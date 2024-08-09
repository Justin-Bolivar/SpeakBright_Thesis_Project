// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

final cardProvider =
    StateNotifierProvider<CardNotifier, List<CardModel>>((ref) {
  return CardNotifier();
});

final cardsStreamProvider = StreamProvider<List<CardModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('cards')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList());
});

final cardsExploreProvider = StreamProvider<List<CardModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance.collection('cards').snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList());
});

class CardNotifier extends StateNotifier<List<CardModel>> {
  CardNotifier() : super([]);

  Future<void> deleteCard(String cardId) async {
    try {
      await FirebaseFirestore.instance.collection('cards').doc(cardId).delete();
    } catch (e) {
      print('Error deleting card: $e');
    }
  }
}
