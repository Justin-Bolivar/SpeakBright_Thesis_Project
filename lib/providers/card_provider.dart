// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';

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
      //.orderBy('tapCount', descending: true)
      .snapshots(
          includeMetadataChanges: true) // Important for online/offline tracking
      .handleError((error) {
    print('Error occurred: $error');
    //return Stream.value([]);
  }).map((snapshot) {
    // Check if the snapshot comes from cache or server
    if (snapshot.metadata.isFromCache) {
      print('Data from cache');
    } else {
      print('Data from server');
    }
    return snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList();
  });
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
      .collection('cards')
      .where('userId', isEqualTo: user.uid)
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
      .collection('cards')
      .where('userId', isEqualTo: user.uid)
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
      .collection('cards')
      .where('userId', isEqualTo: user.uid)
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


// RECOMMENDED CARDS
final recommendedCardsProvider =
    StateNotifierProvider<RecommendedCardsNotifier, List<CardModel>>((ref) {
  return RecommendedCardsNotifier(); // Directly create an instance
});



class RecommendedCardsNotifier extends StateNotifier<List<CardModel>> {
  final FirestoreService _firestoreService = FirestoreService();
  RecommendedCardsNotifier() : super([]) {
    loadRecommendedCards();
  }

  Future<void> loadRecommendedCards() async {
    try {
      // Fetch recommended card IDs
      List<String> recommendedCardIDs = await _firestoreService.getCardRecommendations();

      if (recommendedCardIDs.isEmpty) {
        state = [];
        return;
      }

      // Query Firestore for card details using the recommended IDs
      final snapshot = await FirebaseFirestore.instance
          .collection('cards')
          .where(FieldPath.documentId, whereIn: recommendedCardIDs)
          .get();

      // Convert Firestore documents to `CardModel`
      state = snapshot.docs.map((doc) => CardModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching recommended cards: $e");
      state = []; // Gracefully handle errors
    }
  }
}
class CardNotifier extends StateNotifier<List<CardModel>> {
  CardNotifier() : super([]);

  Future<void> deleteCard(String cardId, String studentID) async {
    try {
      DocumentSnapshot cardSnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .doc(cardId)
          .get();

      if (cardSnapshot.exists) {
        bool isFavorite = cardSnapshot.get('isFavorite');

        await FirebaseFirestore.instance
            .collection('cards')
            .doc(cardId)
            .delete();

        if (isFavorite) {
          await _deleteFavoriteAndAdjustRanks(cardId, studentID);
        }
      }
    } catch (e) {
      print('Error deleting card: $e');
    }
  }
}

Future<void> _deleteFavoriteAndAdjustRanks(
    String cardId, String studentID) async {
  try {
    CollectionReference favoritesCollection = FirebaseFirestore.instance
        .collection('favorites')
        .doc(studentID)
        .collection('cards');

    DocumentSnapshot cardSnapshot = await favoritesCollection.doc(cardId).get();
    if (!cardSnapshot.exists) return;

    int deletedCardRank = cardSnapshot.get('rank');

    await favoritesCollection.doc(cardId).delete();

    QuerySnapshot querySnapshot = await favoritesCollection
        .where('rank', isGreaterThan: deletedCardRank)
        .orderBy('rank')
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      int currentRank = doc.get('rank');
      batch.update(doc.reference, {'rank': currentRank - 1});
    }

    await batch.commit();

    print(
        'Successfully adjusted ranks after deleting card with rank $deletedCardRank');
  } catch (e) {
    print('Error adjusting ranks: $e');
  }
}
