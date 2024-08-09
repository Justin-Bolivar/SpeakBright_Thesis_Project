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
}
