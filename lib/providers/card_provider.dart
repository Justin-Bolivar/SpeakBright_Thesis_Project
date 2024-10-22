// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';

final cardProvider =
    StateNotifierProvider<CardNotifier, List<CardModel>>((ref) {
  return CardNotifier();
});

final cardsStreamProvider = StreamProvider.autoDispose<List<CardModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('cards')
      .where('userId', isEqualTo: user.uid)
      .orderBy('tapCount', descending: true)
      .snapshots()
      .handleError((error) {
    return Stream.value([]);
  }).map((snapshot) =>
          snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList());
});

final cardsListProvider = StreamProvider.autoDispose<List<CardModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('favorites')
      .doc(user.uid)
      .collection('cards')
      .orderBy('rank')
      .snapshots()
      .handleError((error) {
    return Stream.value([]);
  }).map((snapshot) =>
          snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList());
});

final cardsListProviderPhase2 =
    StreamProvider.autoDispose<List<CardModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('favorites')
      .doc(user.uid)
      .collection('cards')
      .orderBy('rank')
      .where('phase1_independence', isEqualTo: true)
      .where('category', isNotEqualTo: 'Emotions')
      .snapshots()
      .handleError((error) {
    print("Error fetching cards: $error");
    return Stream.value([]);
  }).map((snapshot) {
    print("Fetched ${snapshot.docs.length} cards");
    return snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList();
  });
});

final cardsListProviderPhase3 =
    StreamProvider.autoDispose<List<CardModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('favorites')
      .doc(user.uid)
      .collection('cards')
      .orderBy('rank')
      .where('category', isEqualTo: 'Emotions')
      .where('phase1_independence', isEqualTo: true)
      .snapshots()
      .handleError((error) {
    print("Error fetching cards: $error");
    return Stream.value([]);
  }).map((snapshot) {
    print("Fetched ${snapshot.docs.length} cards");
    return snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList();
  });
});

final cardsListProviderPhase4 =
    StreamProvider.autoDispose<List<CardModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('favorites')
      .doc(user.uid)
      .collection('cards')
      .orderBy('rank')
      .where('phase2_independence', isEqualTo: true)
      .where('phase3_independence', isEqualTo: true)
      .snapshots()
      .handleError((error) {
    print("Error fetching cards: $error");
    return Stream.value([]);
  }).map((snapshot) {
    print("Fetched ${snapshot.docs.length} cards");
    return snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList();
  });
});

final cardsExploreProvider = StreamProvider.autoDispose<List<CardModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance.collection('cards').snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList());
});

final cardsGuardianProvider =
    StreamProvider.autoDispose<List<CardModel>>((ref) {
  String studentId = ref.read(studentIdProvider);
  print("Fetching cards for student $studentId");

  return FirebaseFirestore.instance
      .collection('cards')
      .where('userId', isEqualTo: studentId)
      .snapshots()
      .handleError((error) {
    print("Error fetching cards: $error");
    return Stream.value([]);
  }).map((snapshot) =>
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
