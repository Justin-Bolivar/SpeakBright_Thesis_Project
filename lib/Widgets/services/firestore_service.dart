// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/services/temporal_prefixspan.dart';
import 'package:speakbright_mobile/providers/card_activity_provider.dart';
import 'package:intl/intl.dart';

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

  // Future<void> storeTappedCards(
  //     String cardTitle, String category, String cardId) async {
  //   updateRecentCard(cardId);
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     throw Exception('No user is currently signed in.');
  //   }

  //   final CollectionReference usersCollection =
  //       FirebaseFirestore.instance.collection('card_basket');
  //   final DocumentReference userDoc = usersCollection.doc(user.uid);

  //   await userDoc.set({
  //     'userID': user.uid,
  //     'email': user.email,
  //   }, SetOptions(merge: true));

  //   final CollectionReference sessionsCollection =
  //       userDoc.collection('sessions');

  //   // find lastest session
  //   final DateTime now = DateTime.now();
  //   final QuerySnapshot querySnapshot = await sessionsCollection
  //       .where('sessionTime',
  //           isGreaterThan:
  //               Timestamp.fromDate(now.subtract(const Duration(minutes: 1))))
  //       .orderBy('sessionTime', descending: true)
  //       .limit(1)
  //       .get();

  //   DocumentReference sessionDoc;

  //   if (querySnapshot.docs.isNotEmpty) {
  //     sessionDoc = querySnapshot.docs.first.reference;
  //   } else {
  //     final Map<String, dynamic> newSessionData = {
  //       'sessionID': sessionsCollection.doc().id,
  //       'sessionTime': Timestamp.fromDate(now),
  //     };
  //     sessionDoc = await sessionsCollection.add(newSessionData);
  //   }

  //   await sessionDoc.collection('cardsTapped').add({
  //     'cardTitle': cardTitle,
  //     'category': category,
  //     'timeTapped': Timestamp.fromDate(now),
  //   });
  // }

// ----------- ADAPTIVE CARD RECOMMENDATION ------------
  Future<void> storeTappedCards(
      String cardTitle, String category, String cardId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    // Define Firestore references
    final CollectionReference activityCollection =
        FirebaseFirestore.instance.collection('communicate_log');
    final DocumentReference userDoc = activityCollection.doc(user.uid);

    await userDoc.set({
      'userID': user.uid,
      'email': user.email,
    }, SetOptions(merge: true));

    // Format date to 'YYYYMMDD' i used this as a doc ID hence the formattingg
    // edit time
    // DateTime testTime = DateTime(2025, 1, 11, 19, 30);
    final DateTime now = DateTime.now();
    final dateKey =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    final CollectionReference dateInDaysCollection =
        userDoc.collection('date_in_days');
    final DocumentReference dateDoc = dateInDaysCollection.doc(dateKey);

    // Fetch the current day's document, if it exists
    try {
      final docSnapshot = await dateDoc.get();
      List<dynamic> sequence = [];

      if (docSnapshot.exists) {
        // If the document exists, retrieve the existing sequence
        final existingData = docSnapshot.data() as Map<String, dynamic>;
        sequence = existingData['sequence'] as List<dynamic>? ?? [];
      }

      // Check if the card ID is already in the sequence for the day
      final cardIndex =
          sequence.indexWhere((entry) => entry['cardID'] == cardId);

      if (cardIndex != -1) {
        // Card already exists in the sequence, check time difference
        final previousTimestamp =
            (sequence[cardIndex]['timestamp'] as Timestamp).toDate();
        final timeDifference = now.difference(previousTimestamp).inMinutes;

        // Only update the frequency if the time difference is less than 60 minutes
        if (timeDifference < 60) {
          sequence[cardIndex]['frequency'] += 1;
          // Update the timestamp to the most recent tap time
          sequence[cardIndex]['timestamp'] = Timestamp.fromDate(now);
        }
      } else {
        // If it's the first time the card is tapped, add it to the sequence
        sequence.add({
          'cardID': cardId,
          'cardTitle': cardTitle,
          'timestamp': Timestamp.fromDate(now),
          'frequency': 1,
        });
      }

      // Update the Firestore document with the new sequence
      await dateDoc.set({
        'timestamp': Timestamp.fromDate(now),
        'sequence': sequence,
      }, SetOptions(merge: true));

      print("Tapped card data stored successfully.");
    } catch (e) {
      print("Error storing tapped card data: $e");
    }
  }

// Fetch sequence to be used in PrefixSpan
  Future<List<List<Map<String, dynamic>>>> fetchSequenceData(
      String userID) async {
    print('entering fetchSequenceData');
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 7)); 

    final collection = FirebaseFirestore.instance
        .collection('communicate_log')
        .doc(userID)
        .collection('date_in_days');

    final snapshot = await collection
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
                startDate)) 
        .get();
    List<List<Map<String, dynamic>>> sequenceDatabase = [];

    for (var doc in snapshot.docs) {
      var sequence = doc['sequence'];
      if (sequence != null) {
        sequenceDatabase.add(List<Map<String, dynamic>>.from(sequence));
      }
    }
    if (sequenceDatabase.isEmpty) {
      return []; 
    }
    return sequenceDatabase;
  }

  Future<List<String>> getCardRecommendations() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    final userID = user.uid; 
    const supportThreshold = 1;
    final sequenceDatabase = await fetchSequenceData(userID);
    TemporalPrefixSpan prefixSpan = TemporalPrefixSpan(sequenceDatabase: sequenceDatabase);
    List<String> recommendedCards = prefixSpan.mineFrequentSequences(supportThreshold);

    return recommendedCards;
  }

// void testRecommendation() async {
//   User? user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//       throw Exception('No user is currently signed in.');
//     }

//   final userID = user.uid; // Replace with the actual userID
//   const supportThreshold = 1; // Set the support threshold based on your needs

//   // Fetch recommendations based on the current time window and support threshold
//   List<String> recommendations = await getCardRecommendations();

//   print("Recommended Cards: $recommendations");
// }

// List<List<Map<String, dynamic>>> _processSequences(List<Map<String, dynamic>> sequences) {
//   // Process the raw data into temporal sequences structure expected by PrefixSpan
//   List<List<Map<String, dynamic>>> sequenceDatabase = [];

//   // Group sequence data by the day or any other logic you'd like
//   List<Map<String, dynamic>> currentSequence = [];

//   for (var sequence in sequences) {
//     currentSequence.add(sequence);
//     // Assuming timestamp is being used to group
//     if (currentSequence.length == 10) { // An arbitrary number for now; adjust based on your needs
//       sequenceDatabase.add(currentSequence);
//       currentSequence = [];
//     }
//   }
//   return sequenceDatabase;
// }

// END OF ADAPTIVE CARD RECO

  void tapCountIncrement(String cardId) {
    FirebaseFirestore.instance.collection('cards').doc(cardId).update({
      'tapCount': FieldValue.increment(1),
    });
  } //IS THIS USED??

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

  Future<void> updateStudentPhase(String studentID, int newPhase) async {
    try {
      print("entered updateStudent $newPhase");

      // Step 1: Get the previous phase from the 'users' document
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentID)
          .get();
      int previousPhase =
          (userSnapshot.data() as Map<String, dynamic>)['phase'];

      print("$previousPhase Previos");

      // Step 2: Update 'exitTimestamps' for the previous phase in 'activity_log'
      DocumentReference prevPhaseRef = FirebaseFirestore.instance
          .collection('activity_log')
          .doc(studentID)
          .collection('phase')
          .doc(previousPhase.toString());

      await prevPhaseRef.set({
        'exitTimestamps': FieldValue.arrayUnion([DateTime.now()]),
      }, SetOptions(merge: true));

      // Step 3: Update 'entryTimestamps' for the new phase in 'activity_log'
      DocumentReference newPhaseRef = FirebaseFirestore.instance
          .collection('activity_log')
          .doc(studentID)
          .collection('phase')
          .doc(newPhase.toString());

      await newPhaseRef.set({
        'entryTimestamps': FieldValue.arrayUnion([DateTime.now()]),
      }, SetOptions(merge: true));

      // Step 4: Update the 'phase' field in the 'users' document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentID)
          .update({
        'phase': newPhase,
      });

      print('Student phase updated successfully.');
    } catch (e) {
      print('Error updating student phase: $e');
    }
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
  //distractor???---------------------------------------------------
//   Future<bool> showDistractor(String cardID) async {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;

//   String uid = auth.currentUser?.uid ?? '';
//   if (uid.isEmpty) {
//     throw Exception('User not logged in');
//   }

//   // Reference to the user's activity log
//   DocumentReference activityLogRef = firestore.collection('activity_log').doc(uid);

//   // Fetch recent sessions containing the target cardID in trialPrompt
//   QuerySnapshot sessionSnapshot = await activityLogRef
//       .collection('phase')
//       .doc('1')
//       .collection('session')
//       .orderBy('timestamp', descending: true)
//       .limit(10)
//       .get();

//   // Track the sessions that meet the criteria
//   List<QueryDocumentSnapshot> relevantSessions = [];

//   // Iterate through sessions to find ones where cardID is frequently tapped
//   for (var sessionDoc in sessionSnapshot.docs) {
//     QuerySnapshot trialPromptsSnapshot = await sessionDoc.reference
//         .collection('trialPrompt')
//         .where('cardID', isEqualTo: cardID)
//         .get();

//     int cardIDTapCount = trialPromptsSnapshot.size;
//     int totalTapCount =
//         (await sessionDoc.reference.collection('trialPrompt').get()).size;

//     // Check if cardID was tapped in more than half of the total taps
//     if (cardIDTapCount > totalTapCount / 2) {
//       relevantSessions.add(sessionDoc);
//       if (relevantSessions.length == 3) break;
//     }
//   }

//   // If less than 3 sessions met the criteria, check current session
//   if (relevantSessions.length < 3) {
//     // Check current session
//     DocumentReference currentSessionRef =
//         activityLogRef.collection('phase').doc('1').collection('session').doc();

//     QuerySnapshot trialPromptsSnapshot = await currentSessionRef
//         .collection('trialPrompt')
//         .where('prompt', isEqualTo: 'Independent')
//         .get();

//     return trialPromptsSnapshot.size >= 10;
//   }

//   // Calculate proficiency in the recent 3 sessions
//   int independentCount = 0;
//   int totalTapCount = 0;

//   for (var sessionDoc in relevantSessions) {
//     QuerySnapshot trialPromptsSnapshot =
//         await sessionDoc.reference.collection('trialPrompt').get();

//     for (var trialPromptDoc in trialPromptsSnapshot.docs) {
//       totalTapCount++;
//       if (trialPromptDoc['prompt'] == 'Independent') {
//         independentCount++;
//       }
//     }
//   }

//   // Calculate proficiency percentage
//   double proficiency = (independentCount / totalTapCount) * 100;
//   print(proficiency);

//   // Return true if either condition is met
//   bool hasEnoughIndependentPrompts = await activityLogRef.collection('phase').doc('1').collection('session')
//       .where('timestamp', isEqualTo: FieldValue.serverTimestamp())
//       .limit(1)
//       .get()
//       .then((snapshot) {
//         if (snapshot.docs.isEmpty) return false;
//         return snapshot.docs.first.reference
//             .collection('trialPrompt')
//             .where('prompt', isEqualTo: 'Independent')
//             .get()
//             .then((trialPromptsSnapshot) => trialPromptsSnapshot.size >= 10);
//       });

//   return proficiency >= 70 || hasEnoughIndependentPrompts;
// }

  Future<bool> showDistractor(String cardID) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }
    DocumentReference activityLogRef =
        firestore.collection('activity_log').doc(uid);

    QuerySnapshot sessionSnapshot = await activityLogRef
        .collection('phase')
        .doc('1')
        .collection('session')
        .orderBy('timestamp', descending: true)
        .limit(4)
        .get();

    List<QueryDocumentSnapshot> relevantSessions = [];

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
        if (relevantSessions.length == 4) break;
      }
    }

    if (relevantSessions.length < 4) return false;
    print('more than 3 session');

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
    print('independent, distractor prof: $proficiency %');

    // Return true if either condition is met
    bool hasEnoughIndependentPrompts = await activityLogRef
        .collection('phase')
        .doc('1')
        .collection('session')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isEmpty) return false;
      return snapshot.docs.first.reference
          .collection('trialPrompt')
          .where('prompt', isEqualTo: 'Independent')
          .get()
          .then((trialPromptsSnapshot) => trialPromptsSnapshot.size >= 5);
    });

    if (hasEnoughIndependentPrompts) {
      return hasEnoughIndependentPrompts; //dapat in the current session 5 independent then distractor is shown
    }

    // return proficiency >= 70;
    return false;
  }

//phase 1 independence check cards -- idk where to call
  void updatePhase1Independence() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      // Accessing the currently learning card for the user
      DocumentReference currentlyLearningRef =
          firestore.collection('currently_learning').doc(uid);

      DocumentSnapshot currentlyLearningDoc = await currentlyLearningRef.get();

      String? currentlyLearningCardId;

      if (currentlyLearningDoc.exists) {
        // Safely extract the cardId if it exists
        Map<String, dynamic>? currentlyLearningData =
            currentlyLearningDoc.data() as Map<String, dynamic>?;
        currentlyLearningCardId = currentlyLearningData?['cardId'];
      }

      // If currently learning card is not found, check activity log sessions
      if (currentlyLearningCardId == null) {
        print('Currently learning card not found, checking recent sessions.');

        DocumentReference activityLogRef =
            firestore.collection('activity_log').doc(uid);

        QuerySnapshot sessionSnapshot = await activityLogRef
            .collection('phase')
            .doc('1')
            .collection('session')
            .orderBy('timestamp', descending: true)
            .limit(3) // Limit to the most recent 3 sessions
            .get();

        if (sessionSnapshot.docs.isEmpty) {
          print('No recent sessions found in activity log.');
          return;
        }

        List<DocumentSnapshot> recentSessions = sessionSnapshot.docs;

        // Loop through each session to find a card with phase1_independence set to false
        for (var sessionDoc in recentSessions) {
          QuerySnapshot trialPromptsSnapshot =
              await sessionDoc.reference.collection('trialPrompt').get();

          for (var trialPromptDoc in trialPromptsSnapshot.docs) {
            String? cardId = trialPromptDoc['cardID'];

            if (cardId != null) {
              // Fetch the card details from the 'cards' collection
              DocumentSnapshot cardSnapshot =
                  await firestore.collection('cards').doc(cardId).get();

              if (cardSnapshot.exists) {
                Map<String, dynamic>? cardData =
                    cardSnapshot.data() as Map<String, dynamic>?;
                bool isPhase1Independence =
                    cardData?['phase1_independence'] ?? false;

                // If phase1_independence is false, use this card
                if (!isPhase1Independence) {
                  currentlyLearningCardId = cardId;
                  print(
                      'Found a card with phase1_independence as false in recent sessions.');
                  break;
                }
              }
            }
          }

          if (currentlyLearningCardId != null) break;
        }

        // If no card was found in recent sessions
        if (currentlyLearningCardId == null) {
          print(
              'No card with phase1_independence as false found in recent sessions.');
          return;
        }
      }

      // Accessing the card details from 'cards' collection
      DocumentSnapshot cardSnapshot = await firestore
          .collection('cards')
          .doc(currentlyLearningCardId)
          .get();

      if (!cardSnapshot.exists) {
        print('Card not found for cardId: $currentlyLearningCardId');
        return;
      }

      Map<String, dynamic>? cardData =
          cardSnapshot.data() as Map<String, dynamic>?;
      bool isPhase1Independence = cardData?['phase1_independence'] ?? false;

      // If the card already has phase1_independence as true, no need to update
      if (isPhase1Independence) {
        print('The card already has phase1_independence as true.');
        return;
      }

      // Fetching the most recent 3 session data for phase 1
      DocumentReference activityLogRef =
          firestore.collection('activity_log').doc(uid);
      QuerySnapshot sessionSnapshot = await activityLogRef
          .collection('phase')
          .doc('1')
          .collection('session')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      if (sessionSnapshot.docs.isEmpty) {
        print('No relevant sessions found.');
        return; // No sessions to process
      }

      List<DocumentSnapshot> relevantSessions = sessionSnapshot.docs;

      int independentCountWithDistractor = 0;
      int cardTotalTapCount = 0;

      // Calculate the independence percentage based on the recent 3 sessions
      for (var sessionDoc in relevantSessions) {
        QuerySnapshot trialPromptsSnapshot =
            await sessionDoc.reference.collection('trialPrompt').get();

        for (var trialPromptDoc in trialPromptsSnapshot.docs) {
          cardTotalTapCount++;

          // Only count trial prompts that are "Independent" AND have 'withDistractor' true
          if (trialPromptDoc['prompt'] == 'Independent' &&
              trialPromptDoc['withDistractor'] == true) {
            independentCountWithDistractor++;
          }
        }
      }

      // Calculate the independence percentage
      double cardIndependencePercentage = cardTotalTapCount > 0
          ? (independentCountWithDistractor / cardTotalTapCount * 100)
          : 0;

      // If the card has an independence percentage of >= 70, update phase1_independence
      if (cardIndependencePercentage >= 70) {
        await firestore
            .collection('cards')
            .doc(currentlyLearningCardId)
            .update({
          'phase1_independence': true,
        });

        // Also update in the 'favorites' collection
        await firestore
            .collection('favorites')
            .doc(uid)
            .collection('cards')
            .doc(currentlyLearningCardId)
            .update({
          'phase1_independence': true,
        });

        print(
            'Phase1 independence updated to true for $currentlyLearningCardId');
      } else {
        print('Phase1 independence remains false for $currentlyLearningCardId');
      }
    } catch (e) {
      print('Error updating phase1_independence: $e');
    }
  }

//phase 2
  void updatePhase2Independence() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      DocumentReference activityLogRef =
          firestore.collection('activity_log').doc(uid);

      QuerySnapshot cardsSnapshot = await firestore
          .collection('cards')
          .where('userId', isEqualTo: uid)
          .get();

      QuerySnapshot sessionSnapshot = await activityLogRef
          .collection('phase')
          .doc('2')
          .collection('session')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      Map<String, dynamic> independenceData = {};

      for (var cardDoc in cardsSnapshot.docs) {
        String cardID = cardDoc.id;

        List<DocumentSnapshot> relevantSessions = [];

        for (var sessionDoc in sessionSnapshot.docs) {
          QuerySnapshot trialPromptsSnapshot = await sessionDoc.reference
              .collection('trialPrompt')
              .where('cardID', isEqualTo: cardID)
              .get();

          int cardIDTapCount = trialPromptsSnapshot.size;
          int totalSessionTaps =
              (await sessionDoc.reference.collection('trialPrompt').get()).size;

          if (cardIDTapCount > totalSessionTaps / 2) {
            relevantSessions.add(sessionDoc);
            if (relevantSessions.length == 3) break;
          }
        }

        if (relevantSessions.length < 3) {
          DocumentReference currentSessionRef = activityLogRef
              .collection('phase')
              .doc('2')
              .collection('session')
              .doc();

          QuerySnapshot trialPromptsSnapshot = await currentSessionRef
              .collection('trialPrompt')
              .where('cardID', isEqualTo: cardID)
              .get();

          if (trialPromptsSnapshot.size >= 10) {
            independenceData[cardID] = true;
            continue; // Skip further calculations for this card
          } else {
            DocumentSnapshot currentSessionDoc = await currentSessionRef.get();
            if (currentSessionDoc.exists) {
              relevantSessions.add(currentSessionDoc);
            }
          }
        }

        int independentCountWithDistractor = 0;
        int cardTotalTapCount = 0;

        for (var sessionDoc in relevantSessions) {
          QuerySnapshot trialPromptsSnapshot =
              await sessionDoc.reference.collection('trialPrompt').get();

          for (var trialPromptDoc in trialPromptsSnapshot.docs) {
            cardTotalTapCount++;
            if (trialPromptDoc['prompt'] == 'Independent') {
              independentCountWithDistractor++;
            }
          }
        }

        double cardIndependencePercentage = cardTotalTapCount > 0
            ? (independentCountWithDistractor / cardTotalTapCount * 100)
            : 0;

        independenceData[cardID] = cardIndependencePercentage >= 70;
      }

      await Future.wait(
        independenceData.entries.map((entry) async {
          await firestore.collection('cards').doc(entry.key).update({
            'phase2_independence': entry.value,
            'phase3_independence': entry.value,
          });
        }),
      );

      print(
          'Updated phase2_independence for ${independenceData.length} cards.');
    } catch (e) {
      print('Error updating phase2_independence: $e');
    }
  }

//phase 3
  void updatePhase3Independence() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      DocumentReference activityLogRef =
          firestore.collection('activity_log').doc(uid);

      QuerySnapshot cardsSnapshot = await firestore
          .collection('cards')
          .where('userId', isEqualTo: uid)
          .get();

      QuerySnapshot sessionSnapshot = await activityLogRef
          .collection('phase')
          .doc('3')
          .collection('session')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      Map<String, dynamic> independenceData = {};

      for (var cardDoc in cardsSnapshot.docs) {
        String cardID = cardDoc.id;

        List<DocumentSnapshot> relevantSessions = [];

        for (var sessionDoc in sessionSnapshot.docs) {
          QuerySnapshot trialPromptsSnapshot = await sessionDoc.reference
              .collection('trialPrompt')
              .where('cardID', isEqualTo: cardID)
              .get();

          int cardIDTapCount = trialPromptsSnapshot.size;
          int totalSessionTaps =
              (await sessionDoc.reference.collection('trialPrompt').get()).size;

          if (cardIDTapCount > totalSessionTaps / 2) {
            relevantSessions.add(sessionDoc);
            if (relevantSessions.length == 3) break;
          }
        }

        if (relevantSessions.length < 3) {
          DocumentReference currentSessionRef = activityLogRef
              .collection('phase')
              .doc('3')
              .collection('session')
              .doc();

          QuerySnapshot trialPromptsSnapshot = await currentSessionRef
              .collection('trialPrompt')
              .where('cardID', isEqualTo: cardID)
              .get();

          if (trialPromptsSnapshot.size >= 10) {
            independenceData[cardID] = true;
            continue; // Skip further calculations for this card
          } else {
            DocumentSnapshot currentSessionDoc = await currentSessionRef.get();
            if (currentSessionDoc.exists) {
              relevantSessions.add(currentSessionDoc);
            }
          }
        }

        int independentCount = 0;
        int cardTotalTapCount = 0;

        for (var sessionDoc in relevantSessions) {
          QuerySnapshot trialPromptsSnapshot =
              await sessionDoc.reference.collection('trialPrompt').get();

          for (var trialPromptDoc in trialPromptsSnapshot.docs) {
            cardTotalTapCount++;
            if (trialPromptDoc['prompt'] == 'Independent') {
              independentCount++;
            }
          }
        }

        double cardIndependencePercentage = cardTotalTapCount > 0
            ? (independentCount / cardTotalTapCount * 100)
            : 0;

        independenceData[cardID] = cardIndependencePercentage >= 70;
      }

      await Future.wait(
        independenceData.entries.map((entry) async {
          await firestore.collection('cards').doc(entry.key).update({
            'phase3_independence': entry.value,
            'phase2_independence': entry.value,
          });
        }),
      );

      print(
          'Updated phase3_independence for ${independenceData.length} cards.');
    } catch (e) {
      print('Error updating phase3_independence: $e');
    }
  }

  Future<void> setCurrentlyLearningCard(String? cardId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    String? userId = auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      print('User not logged in');
      return;
    }

    DocumentReference<Map<String, dynamic>> parentDocRef =
        firestore.collection('currently_learning').doc(userId);

    DocumentSnapshot<Map<String, dynamic>> parentDocSnapshot =
        await parentDocRef.get();

    try {
      // Check if the card is phase1_independent
      DocumentSnapshot<Map<String, dynamic>> cardDocSnapshot =
          await firestore.collection('cards').doc(cardId).get();

      bool isPhase1Independent = cardDocSnapshot.exists &&
          (cardDocSnapshot.data()?['phase1_independence'] ?? false);
      print('set CL: $isPhase1Independent');

      if (isPhase1Independent) {
        await firestore.collection('currently_learning').doc(userId).delete();
        print("Deleted currently learning card for user $userId.");
        return;
      } else {
        if (!parentDocSnapshot.exists) {
          await parentDocRef.set({
            'userId': userId,
            'cardId': cardId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        print("Set currently learning card: $cardId");
      }
    } catch (e) {
      print("Error setting currently learning card: $e");
    }
  }

  void updatePhase1IndependenceOptimized(String cardId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      // Accessing the card details from the 'cards' collection
      DocumentSnapshot cardSnapshot =
          await firestore.collection('cards').doc(cardId).get();

      if (!cardSnapshot.exists) {
        print('Card not found for cardId: $cardId');
        return;
      }

      Map<String, dynamic>? cardData =
          cardSnapshot.data() as Map<String, dynamic>?;
      bool isPhase1Independence = cardData?['phase1_independence'] ?? false;

      // If the card already has phase1_independence as true, no need to update
      if (isPhase1Independence) {
        print('The card already has phase1_independence as true.');
        return;
      }

      // Fetching the most recent 3 session data for phase 1
      DocumentReference activityLogRef =
          firestore.collection('activity_log').doc(uid);
      QuerySnapshot sessionSnapshot = await activityLogRef
          .collection('phase')
          .doc('1')
          .collection('session')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      if (sessionSnapshot.docs.isEmpty) {
        print('No relevant sessions found.');
        return; // No sessions to process
      }

      List<DocumentSnapshot> relevantSessions = sessionSnapshot.docs;

      int independentDistractorCount = 0;
      int totalDistractorCount = 0;

      // Loop through sessions to access the pre-calculated fields
      for (var sessionDoc in relevantSessions) {
        // Fetch the independentDistractorCount and totalDistractorCount directly from the session
        independentDistractorCount +=
            (sessionDoc['independentDistractorCount'] ?? 0) as int;
        totalDistractorCount +=
            (sessionDoc['totalDistractorCount'] ?? 0) as int;
      }

      // Calculate the independence percentage
      double cardIndependencePercentage = totalDistractorCount > 0
          ? (independentDistractorCount / totalDistractorCount * 100)
          : 0;

      // If the card has an independence percentage of >= 70, update phase1_independence
      if (cardIndependencePercentage >= 70) {
        await firestore.collection('cards').doc(cardId).update({
          'phase1_independence': true,
        });

        // Also update in the 'favorites' collection
        await firestore
            .collection('favorites')
            .doc(uid)
            .collection('cards')
            .doc(cardId)
            .update({
          'phase1_independence': true,
        });

        print('Phase1 independence updated to true for $cardId');
      } else {
        print('Phase1 independence remains false for $cardId');
      }
    } catch (e) {
      print('Error updating phase1_independence: $e');
    }
  }

  Future<void> updatePhaseIndependence(
    String cardID,
    int phase,
    WidgetRef ref, // Pass the widgetRef to update the provider
  ) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;

    if (uid == null) {
      throw Exception("User not logged in");
    }

    try {
      DocumentReference activityLogRef =
          firestore.collection('activity_log').doc(uid);

      // Retrieve the session collection for the correct phase
      DocumentReference phaseRef =
          activityLogRef.collection('phase').doc(phase.toString());
      print('ENTERED UPDATEPHASE');
      // Retrieve the session data (last 3 sessions)
      QuerySnapshot sessionSnapshot = await phaseRef
          .collection('session')
          .orderBy('timestamp', descending: true)
          .limit(3)
          // .where('independentDistractorTwoCount', isGreaterThan: 0)
          .get();

      // Store the counts for the card
      int independentDistractorTwoCount = 0;
      int totalDistractorTwoCount = 0;

      int validSessionsCount = 0;

      // Iterate over the fetched sessions
      for (var sessionDoc in sessionSnapshot.docs) {
        final trialPromptCollection =
            sessionDoc.reference.collection('trialPrompt');

        // Check if the session contains the given cardID in its `trialPrompt` subcollection
        QuerySnapshot trialPromptSnapshot = await trialPromptCollection
            .orderBy('timestamp', descending: true)
            .limit(1)
            .where('cardID', isEqualTo: cardID)
            .get();

        // If no matching trial prompt is found, mark this session as invalid and stop further processing
        if (trialPromptSnapshot.docs.isEmpty) {
          print("Session ${sessionDoc.id} is invalid for cardID $cardID");
          return;
        }

        // Increment valid session count
        validSessionsCount++;

        // Sum up counts for valid sessions
        independentDistractorTwoCount +=
            (sessionDoc['independentDistractorTwoCount'] ?? 0) as int;
        totalDistractorTwoCount +=
            (sessionDoc['totalDistractorTwoCount'] ?? 0) as int;

        if (validSessionsCount >= 3) break;
      }

// Check if there are at least 3 valid sessions
      if (validSessionsCount < 3) {
        print("Insufficient valid sessions for cardID $cardID in phase $phase");
        return;
      }

      // Calculate the independence percentage based on the counts
      double cardIndependencePercentage = totalDistractorTwoCount > 0
          ? (independentDistractorTwoCount / totalDistractorTwoCount * 100)
          : 0;
      print("PHASE!! $phase");
      // Update the card document with the phase-specific independence data
      if (phase == 1) {
        await firestore.collection('cards').doc(cardID).update({
          'phase${phase}_independence': cardIndependencePercentage >= 70,
          'phase1_completion': FieldValue.serverTimestamp(),
        });
      } else {
        await firestore.collection('cards').doc(cardID).update({
          'phase2_independence': cardIndependencePercentage >= 70,
          'phase3_independence': cardIndependencePercentage >= 70,
          'phase2_completion': FieldValue.serverTimestamp(),
          'phase3_completion': FieldValue.serverTimestamp(),
        });
      }

      // If the independence percentage is above 70, update the reset state
      if (cardIndependencePercentage >= 70) {
        ref.read(cardActivityProvider.notifier).reset();
      }

      print("Updated phase $phase data for card: $cardID");
    } catch (e) {
      print("Error updating phase $phase independence: $e");
    }
  }

  Future<bool> autoUpdatePhase(int currentPhase, {bool? isEmotion}) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    bool withEmotion = isEmotion ?? false;

    String uid = auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not logged in');
    }

    try {
      switch (currentPhase) {
        case 1:
          print("CASE 1 ENTERED!");

          if (!withEmotion && await isPhaseLocked(2)) {
            int? totalWithoutEmotions = 0;
            int? independentWithoutEmotions = 0;
            // Fetch counts for total cards without Emotions
            totalWithoutEmotions = (await firestore
                    .collection("cards")
                    .where("userId", isEqualTo: uid)
                    .where("category", isNotEqualTo: "Emotions")
                    .count()
                    .get())
                .count;

            // Fetch counts for independent cards without Emotions
            independentWithoutEmotions = (await firestore
                    .collection("cards")
                    .where("userId", isEqualTo: uid)
                    .where("phase1_independence", isEqualTo: true)
                    .where("category", isNotEqualTo: "Emotions")
                    .count()
                    .get())
                .count;
            print(
                "totalWithoutEmotions: $totalWithoutEmotions | independentWithoutEmotions: $independentWithoutEmotions");
            print(
                "PERCENT: ${independentWithoutEmotions! / totalWithoutEmotions!}");

            if (totalWithoutEmotions > 3 &&
                ((independentWithoutEmotions / totalWithoutEmotions) * 100)
                        .round() >=
                    70) {
              await updateStudentPhase(uid, 2);
              return true;
            }
          } else if (await isPhaseLocked(3)) {
            int? totalWithEmotions = 0;
            int? independentWithEmotions = 0;

            // Fetch counts for total cards with Emotions
            totalWithEmotions = (await firestore
                    .collection("cards")
                    .where("userId", isEqualTo: uid)
                    .where("category", isEqualTo: "Emotions")
                    .count()
                    .get())
                .count;

            // Fetch counts for independent cards with Emotions
            independentWithEmotions = (await firestore
                    .collection("cards")
                    .where("userId", isEqualTo: uid)
                    .where("phase1_independence", isEqualTo: true)
                    .where("category", isEqualTo: "Emotions")
                    .count()
                    .get())
                .count;
            print(
                "totalWithEmotions: $totalWithEmotions | independentWithEmotions: $independentWithEmotions");
            print(
                "PERCENT: ${((independentWithEmotions! / totalWithEmotions!) * 100).round()}");

            if (totalWithEmotions > 3 &&
                ((independentWithEmotions / totalWithEmotions) * 100).round() >=
                    70) {
              await updateStudentPhase(uid, 3);
              return true;
            }
          }

          break;

        case 2:
        case 3:
          if (await isPhaseLocked(4)) {
            int? phase2Total = 0;
            int? phase2Independent = 0;
            int? phase3Total = 0;
            int? phase3Independent = 0;

            // Fetch counts for phase 2 (without Emotions)
            phase2Total = (await firestore
                    .collection("cards")
                    .where("userId", isEqualTo: uid)
                    .where("category", isNotEqualTo: "Emotions")
                    .count()
                    .get())
                .count;

            phase2Independent = (await firestore
                    .collection("cards")
                    .where("userId", isEqualTo: uid)
                    .where("phase2_independence", isEqualTo: true)
                    .where("category", isNotEqualTo: "Emotions")
                    .count()
                    .get())
                .count;

            // Fetch counts for phase 3 (Emotions)
            phase3Total = (await firestore
                    .collection("cards")
                    .where("userId", isEqualTo: uid)
                    .where("category", isEqualTo: "Emotions")
                    .count()
                    .get())
                .count;

            phase3Independent = (await firestore
                    .collection("cards")
                    .where("userId", isEqualTo: uid)
                    .where("phase3_independence", isEqualTo: true)
                    .where("category", isEqualTo: "Emotions")
                    .count()
                    .get())
                .count;

            // Check if both Phase 2 and Phase 3 independence conditions are met
            bool phase2Complete =
                phase2Total! > 0 && phase2Independent! / phase2Total >= 0.7;
            bool phase3Complete =
                phase3Total! > 0 && phase3Independent! / phase3Total >= 0.7;

            if (phase2Complete && phase3Complete) {
              await updateStudentPhase(uid, 4);
              return true;
            }
          }

          break;

        default:
          return false;
      }
    } catch (e) {
      print("Error in autoUpdatePhase: $e");
      return false;
    }
    return false;
  }

  Future<bool> isEmotion(String? cardID) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot cardDoc =
          await firestore.collection('cards').doc(cardID).get();

      if (!cardDoc.exists) {
        print('Card with ID $cardID does not exist.');
        return false;
      }

      Map<String, dynamic>? cardData = cardDoc.data() as Map<String, dynamic>?;

      String? category = cardData?['category'];

      return category == 'Emotions';
    } catch (e) {
      print('Error while checking card category: $e');
      return false;
    }
  }

  Future<int> getCurrentPhase() async {
    try {
      // Get the current authenticated user
      final FirebaseAuth auth = FirebaseAuth.instance;
      String studentID = await Future.value(auth.currentUser?.uid ?? '');

      if (studentID.isEmpty) {
        throw Exception('User not logged in');
      }

      // Retrieve the user's document snapshot
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentID)
          .get();

      // Check if the document exists
      if (userSnapshot.exists) {
        // Extract the phase value safely
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        int phase =
            userData?['phase'] ?? 0; // Default to 0 if phase is not found
        return phase;
      } else {
        print("User document does not exist.");
        return 1;
      }
    } catch (e) {
      // Handle any errors
      print("Error fetching phase: $e");
      return 1; // Default phase value
    }
  }

  Future<bool> isPhaseLocked(int phase) async {
    try {
      int currentPhase = await getCurrentPhase();
      return currentPhase < phase;
    } catch (e) {
      print('Error while checking if phase $phase is unlocked: $e');
      return true;
    }
  }
}
