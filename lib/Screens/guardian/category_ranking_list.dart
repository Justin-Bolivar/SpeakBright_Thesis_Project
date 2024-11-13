import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';

class CardRankingList extends ConsumerStatefulWidget {
  final String selectedCategory;  // Receive selectedCategory from CardRankingMenu

  const CardRankingList({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  ConsumerState<CardRankingList> createState() => _CardRankingListState();
}

class _CardRankingListState extends ConsumerState<CardRankingList> {
  List<DocumentSnapshot> categoryData = [];
  late String studentID;

  @override
  void initState() {
    super.initState();
    studentID = ref.read(studentIdProvider.notifier).state;  // Get the student ID from provider
    _loadCategoryData(widget.selectedCategory);  // Load category data for selected category
  }

  // Function to load category data based on selectedCategory
  Future<void> _loadCategoryData(String selectedCategory) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categoryRanking')
          .doc(studentID)  // Access the student's document
          .collection(selectedCategory)
          .orderBy('rank')  // Ensure the order is by rank
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          categoryData = snapshot.docs;  // Store the list of documents (cards)
        });
      } else {
        setState(() {
          categoryData = [];  // No category data found, store an empty list
        });
      }
    } catch (e) {
      print('Error loading category data: $e');
    }
  }

  // Function to update the rank of a specific card within the selected category
  Future<void> _updateRank(String cardID, int rank) async {
    try {
      await FirebaseFirestore.instance
          .collection('categoryRanking')
          .doc(studentID)  // Access the student's document
          .collection(widget.selectedCategory)
          .doc(cardID)  // Access the specific card
          .update({'rank': rank});  // Update the rank of the card
    } catch (e) {
      print('Error updating card rank: $e');
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
              'assets/bg-4.png',  // Adjust with your own background asset
              fit: BoxFit.cover,   // Ensure the image covers the screen
            ),
          ),
          // Container with 70% height and 80% width of screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,  // 70% height
                  width: MediaQuery.of(context).size.width * 0.8,     // 80% width
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // Slight opacity for the container
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Dialog Title
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Cards in ${widget.selectedCategory}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Divider(height: 1, color: Colors.grey),
                      // List Content
                      Expanded(
                        child: categoryData.isEmpty
                            ? const Center(
                                child: Text(
                                  'No cards available for this category!',
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
                                  children: categoryData.map((DocumentSnapshot card) {
                                    final colorIndex = categoryData.indexOf(card) % boxColors.length;
                                    return Container(
                                      key: Key(card.id),
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: boxColors[colorIndex],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: Text(
                                          (categoryData.indexOf(card) + 1).toString(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        title: Text(
                                          card['cardTitle'],
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        trailing: const Icon(Icons.drag_handle, color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                  onReorder: (int oldIndex, int newIndex) {
                                    setState(() {
                                      if (oldIndex < newIndex) {
                                        newIndex -= 1;
                                      }
                                      final DocumentSnapshot item = categoryData.removeAt(oldIndex);
                                      categoryData.insert(newIndex, item);
                                    });
                                    _updateRank(categoryData[newIndex].id, newIndex + 1);  // Update the rank of the moved card
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Done Button
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);  // Close the screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1C40F),  // Dandelion color (Yellow)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
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
