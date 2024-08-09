import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  Future<void> storeSentence(List<String> sentence) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    CollectionReference sentences =
        FirebaseFirestore.instance.collection('sentences');

    Map<String, dynamic> sentenceData = {
      'sentence': sentence.join(' '),
      'userID': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await sentences.add(sentenceData);
  }

  Future<List<String>> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      return querySnapshot.docs
          .map((doc) => doc['category'] as String)
          .toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  //record for the tapped cards
  Future<void> storeTappedCards(String cardTitle, String category) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    final CollectionReference tappedRef =
        FirebaseFirestore.instance.collection('tappedCardsPerSession');
    final DateTime now = DateTime.now();

    //latest session within the last 5 minutes
    final QuerySnapshot querySnapshot = await tappedRef
        .where('userID', isEqualTo: user.uid)
        .where('sessionTime',
            isGreaterThan:
                Timestamp.fromDate(now.subtract(const Duration(minutes: 5))))
        .orderBy('sessionTime', descending: true)
        .limit(1)
        .get();

    DocumentReference sessionDoc;

    if (querySnapshot.docs.isNotEmpty) {
      // recent session exists, use it
      sessionDoc = querySnapshot.docs.first.reference;
    } else {
      // if no recent session found
      final Map<String, dynamic> newSessionData = {
        'userID': user.uid,
        'sessionID': FirebaseFirestore.instance.collection('sessions').doc().id,
        'sessionTime': Timestamp.fromDate(now),
      };
      sessionDoc = await tappedRef.add(newSessionData);
    }

    // subcollection
    await sessionDoc.collection('cards').add({
      'cardTitle': cardTitle,
      'category': category,
      'tapTime': Timestamp.fromDate(now),
    });
  }
}
