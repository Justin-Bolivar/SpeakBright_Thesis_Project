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

      List<String> allCategories =
          querySnapshot.docs.map((doc) => doc['category'] as String).toList();

      final priorityCategories = ['All', 'Food', 'Toys', 'Emotions', 'School'];

      allCategories.sort((a, b) {
        final indexA = priorityCategories.indexOf(a);
        final indexB = priorityCategories.indexOf(b);

        if (indexA != -1 && indexB != -1) {
          return indexA.compareTo(indexB);
        } else if (indexA != -1) {
          return -1;
        } else if (indexB != -1) {
          return 1;
        } else {
          return a.compareTo(b);
        }
      });

      return allCategories;
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<void> storeTappedCards(
      String cardTitle, String category, String cardId) async {
    updateRecentCard(cardId);
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('card_basket');
    final DocumentReference userDoc = usersCollection.doc(user.uid);

    await userDoc.set({
      'userID': user.uid,
      'email': user.email,
    }, SetOptions(merge: true));

    final CollectionReference sessionsCollection =
        userDoc.collection('sessions');

    // find lastest session
    final DateTime now = DateTime.now();
    final QuerySnapshot querySnapshot = await sessionsCollection
        .where('sessionTime',
            isGreaterThan:
                Timestamp.fromDate(now.subtract(const Duration(minutes: 1))))
        .orderBy('sessionTime', descending: true)
        .limit(1)
        .get();

    DocumentReference sessionDoc;

    if (querySnapshot.docs.isNotEmpty) {
      sessionDoc = querySnapshot.docs.first.reference;
    } else {
      final Map<String, dynamic> newSessionData = {
        'sessionID': sessionsCollection.doc().id,
        'sessionTime': Timestamp.fromDate(now),
      };
      sessionDoc = await sessionsCollection.add(newSessionData);
    }

    await sessionDoc.collection('cardsTapped').add({
      'cardTitle': cardTitle,
      'category': category,
      'timeTapped': Timestamp.fromDate(now),
    });
  }

  void tapCountIncrement(String cardId) {
    FirebaseFirestore.instance.collection('cards').doc(cardId).update({
      'tapCount': FieldValue.increment(1),
    });
  }

  Future<String?> getCurrentUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid.isEmpty) {
      return null;
    }

    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final userData = docSnap.data() as Map<String, dynamic>;
        return userData['name'];
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }

    return null;
  }

  Future<void> updateStudentPhase(String studentID, int phase) async {
    await FirebaseFirestore.instance.collection('users').doc(studentID).update({
      'phase': phase,
    });
  }

  Future<String?> fetchStudentName(String studentID) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(studentID);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final userData = docSnap.data() as Map<String, dynamic>;
        return userData['name'];
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
    return null;
  }

  Future<int> fetchPhase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    String userId = user.uid;

    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    DocumentSnapshot userDoc = await userRef.doc(userId).get();

    if (userDoc.exists) {
      return userDoc.get('phase');
    } else {
      print('User document not found.');
    }
    return 1;
  }

  Future<void> updateRecentCard(String cardId) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    if (userId == null) {
      throw Exception('User is not logged in');
    }

    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('temp_recentCard').doc(userId);

      await docRef.set({
        'cardID': cardId,
      }, SetOptions(merge: true));

      print('Successfully updated recent card for user $userId');
    } catch (e) {
      print('Error updating recent card: $e');
      rethrow; // Re-throw the exception to be handled by the caller
    }
  }

  Future<Map<String, int>> getPromptFrequencies(
      String selectedStudentId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      Map<String, int> frequencies = {
        'Independent': await db
            .collection('prompt')
            .doc(selectedStudentId)
            .get()
            .then((value) => value.get('Independent') ?? 0),
        'Verbal': await db
            .collection('prompt')
            .doc(selectedStudentId)
            .get()
            .then((value) => value.get('Verbal') ?? 0),
        'Gestural': await db
            .collection('prompt')
            .doc(selectedStudentId)
            .get()
            .then((value) => value.get('Gestural') ?? 0),
        'Modeling': await db
            .collection('prompt')
            .doc(selectedStudentId)
            .get()
            .then((value) => value.get('Modeling') ?? 0),
        'Physical': await db
            .collection('prompt')
            .doc(selectedStudentId)
            .get()
            .then((value) => value.get('Physical') ?? 0),
      };

      return frequencies;
    } catch (e) {
      print('Error fetching prompt frequencies: $e');
      rethrow;
    }
  }

  //distractor???
  Future<bool> showDistractor(String cardID) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    // Reference to the user's activity log
    DocumentReference activityLogRef =
        firestore.collection('activity_log').doc(uid);

    // Fetch recent sessions containing the target cardID in trialPrompt
    QuerySnapshot sessionSnapshot = await activityLogRef
        .collection('phase')
        .doc('1')
        .collection('session')
        .orderBy('timestamp', descending: true)
        .limit(10) // Limit to recent 10 sessions for efficiency
        .get();

    // Track the sessions that meet the criteria
    List<QueryDocumentSnapshot> relevantSessions = [];

    // Iterate through sessions to find ones where cardID is frequently tapped
    for (var sessionDoc in sessionSnapshot.docs) {
      QuerySnapshot trialPromptsSnapshot = await sessionDoc.reference
          .collection('trialPrompt')
          .where('cardID', isEqualTo: cardID)
          .get();

      int cardIDTapCount = trialPromptsSnapshot.size;
      int totalTapCount =
          (await sessionDoc.reference.collection('trialPrompt').get()).size;

      // Check if cardID was tapped in more than half of the total taps
      if (cardIDTapCount > totalTapCount / 2) {
        relevantSessions.add(sessionDoc);
        if (relevantSessions.length == 3) break;
      }
    }

    // If less than 3 sessions met the criteria, return false
    if (relevantSessions.length < 3) return false;

    // Calculate proficiency in the recent 3 sessions
    int independentCount = 0;
    int totalTapCount = 0;

    for (var sessionDoc in relevantSessions) {
      QuerySnapshot trialPromptsSnapshot =
          await sessionDoc.reference.collection('trialPrompt').get();

      for (var trialPromptDoc in trialPromptsSnapshot.docs) {
        totalTapCount++;
        if (trialPromptDoc['prompt'] == 'Independent') {
          independentCount++;
        }
      }
    }

    // Calculate proficiency percentage
    double proficiency = (independentCount / totalTapCount) * 100;
    print(proficiency);
    return proficiency >= 70;
  }
}
