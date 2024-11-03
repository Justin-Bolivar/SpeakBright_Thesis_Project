import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/cards/play_card.dart';

class Play extends ConsumerStatefulWidget {
  const Play({super.key});

  static const String route = "/play";
  static const String path = "/play";
  static const String name = "Play";

  @override
  ConsumerState<Play> createState() => _PlayState();
}

class _PlayState extends ConsumerState<Play> {
  List<dynamic> cards = [];
  List<bool> flippedCards = [];
  int matchedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCardsFromFirestore();
  }

  Future<void> fetchCardsFromFirestore() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser?.uid ?? '';

    try {
      final cardsRef = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(uid)
          .collection('cards')
          .get();

      setState(() {
        cards = cardsRef.docs.map((doc) => doc.data()['cardID']).toList();
        cards.shuffle(); // Shuffle the cards
        cards.insertAll(
            cards.length ~/ 2, cards.take(cards.length ~/ 2).toList());

        // Initialize flippedCards with false values
        flippedCards = List.filled(cards.length, false);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void flipCard(int index) {
    setState(() {
      if (!flippedCards[index]) {
        flippedCards[index] = true;
        if (index + 1 < cards.length && !flippedCards[index + 1]) {
          flippedCards[index + 1] = true;
        }
      }
    });
  }

  void checkMatch(int index) {
    if (cards[index] == cards[index + 1]) {
      setState(() {
        matchedCount++;
        if (matchedCount >= cards.length ~/ 2) {
          // Game won!
          showAlertDialog(context);
        }
      });
    } else {
      // Cards don't match, flip them back
      setState(() {
        flippedCards[index] = false;
        flippedCards[index + 1] = false;
      });
    }
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Congratulations! You won the game!'),
          actions: [
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  matchedCount = 0;
                  flippedCards.fillRange(0, flippedCards.length, false);
                  fetchCardsFromFirestore();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return PlayCard(
          cardId: cards[index],
          cardValue: cards[index].substring(0, 1),
        );
      },
    );
  }
}
