// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';

class FavoriteRankingList extends ConsumerStatefulWidget {
  const FavoriteRankingList({super.key});

  @override
  ConsumerState<FavoriteRankingList> createState() =>
      _FavoriteRankingListState();
}

class _FavoriteRankingListState extends ConsumerState<FavoriteRankingList> {
  List<DocumentSnapshot> _cards = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String studentID;
  List<DocumentSnapshot> categoryData = [];

  @override
  void initState() {
    super.initState();
    studentID = ref.read(studentIdProvider.notifier).state;
    _loadCards();
  }

  // Load the cards from Firestore
  Future<void> _loadCards() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('favorites')
          .doc(studentID)
          .collection('cards')
          .orderBy('rank')
          .get();
      setState(() {
        _cards = snapshot.docs;
      });
    } catch (e) {
      print('Error loading cards: $e');
    }
  }

  // Update card ranks in Firestore
  Future<void> _updateCardRanks() async {
    try {
      for (int i = 0; i < _cards.length; i++) {
        await _firestore
            .collection('favorites')
            .doc(studentID)
            .collection('cards')
            .doc(_cards[i].id)
            .update({
          'rank': i + 1,
        });
      }
    } catch (e) {
      print('Error updating card ranks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg-4.png',
              fit: BoxFit.cover, // Ensure the image covers the screen
            ),
          ),
          // Container with 70% height and 80% width of screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height:
                      MediaQuery.of(context).size.height * 0.7, // 70% height
                  width: MediaQuery.of(context).size.width * 0.8, // 80% width
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.9), // Slight opacity for the container
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Dialog Title
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Favorite Cards',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: lGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(height: 1, color: Colors.grey),

                      // List Content
                      Expanded(
                        child: _cards.isEmpty
                            ? const Center(
                                child: Text(
                                  'Add Favorite Cards First!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ReorderableListView(
                                  shrinkWrap: true,
                                  children: _cards.map((DocumentSnapshot card) {
                                    final colorIndex =
                                        _cards.indexOf(card) % boxColors.length;
                                    return Container(
                                      key: Key(card.id),
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        color: boxColors[colorIndex],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: Text(
                                          (_cards.indexOf(card) + 1).toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        title: Text(
                                          card['title'],
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        trailing: const Icon(Icons.drag_handle,
                                            color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                  onReorder: (int oldIndex, int newIndex) {
                                    setState(() {
                                      if (oldIndex < newIndex) {
                                        newIndex -= 1;
                                      }
                                      final DocumentSnapshot item =
                                          _cards.removeAt(oldIndex);
                                      _cards.insert(newIndex, item);
                                    });
                                    _updateCardRanks();
                                  },
                                ),
                              ),
                      ),
                      // Done Button
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF1C40F), // Dandelion color (Yellow)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
