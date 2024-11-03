import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakbright_mobile/Routing/router.dart';
import 'package:speakbright_mobile/Screens/guardian/student_profile.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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

                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Color.fromARGB(137, 24, 51, 186),
                                        ],
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _pickImage(ImageSource.camera, ref),
                                        icon: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Color.fromARGB(255, 7, 14, 93),
                                        ),
                                        label: const Text(
                                          'Camera',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 7, 14, 93)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Image.asset(
                                      'assets/camera.png',
                                      fit: BoxFit.cover,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(width: 10),
                            Spacer(), //between
                            SizedBox(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.yellow,
                                          Colors.orange,
                                        ],
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _pickImage(
                                            ImageSource.gallery, ref),
                                        icon: const Icon(
                                          Icons.photo_library,
                                          color:
                                              Color.fromARGB(255, 137, 61, 7),
                                        ),
                                        label: const Text(
                                          'Gallery',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 137, 61, 7)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Image.asset(
                                      'assets/album.png',
                                      fit: BoxFit.cover,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // if (imageUrl != null) Image.network(imageUrl),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      ElevatedButton(
                          onPressed: () => _submitCard(context, ref),
                          child: Text(
                            'Add +',
                            style: GoogleFonts.rubikSprayPaint(
                                color: kwhite, fontSize: 20, letterSpacing: .5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: addGreen,
                          )),

                      //skip button
                      if (addedCardCount >= 3)
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextButton(
                            onPressed: () {
                              GlobalRouter.I.router.push(StudentProfile.route);
                            },
                            child: Text(
                              'Skip',
                              style: GoogleFonts.roboto(
                                  color: Color(0xFF55ADFF), fontSize: 10),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                    ],
                  ),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Positioned(
                    top: MediaQuery.of(context).size.height * 0.10,
                    child: Image.asset(
                      'assets/favoriteBox.png',
                      height: 200,
                    ),
                  )),
            )
          ],
        ));
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

  void _submitCard(BuildContext context, WidgetRef ref) {
    String newCardTitle = ref.read(newCardTitleProvider);
    String? imageUrl = ref.watch(imageUrlProvider);
    String? selectedCategory = ref.read(selectedCategoryProvider);

    if (newCardTitle.isNotEmpty && imageUrl != null) {
      String studentID = ref.watch(studentIdProvider);
      if (studentID != '') {
        print('Selected Category: $selectedCategory'); // for debugging

        // Add card to 'cards' collection
        FirebaseFirestore.instance.collection('cards').add({
          'title': newCardTitle,
          'userId': studentID,
          'imageUrl': imageUrl,
          'category': selectedCategory,
          'tapCount': 0,
          'isFavorite': true,
          'phase1_independence': false,
          'phase2_independence': false,
          'phase3_independence': false,
        }).then((cardRef) {
          String newCardID = cardRef.id;

          // Increment the card counter
          int currentCount = ref.read(addedCardCountProvider.notifier).state;
          if (currentCount < 9) {
            ref.read(addedCardCountProvider.notifier).state = currentCount + 1;
          } else {
            GlobalRouter.I.router.push(StudentProfile.route);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All cards added successfully')),
            );
          }

          // Check if the card is marked as favorite
          FirebaseFirestore.instance
              .collection('cards')
              .doc(newCardID)
              .get()
              .then((cardDoc) async {
            if (cardDoc.exists && cardDoc['isFavorite'] == true) {
              // Get the favorites collection for the student
              CollectionReference favoritesCollection = FirebaseFirestore
                  .instance
                  .collection('favorites')
                  .doc(studentID)
                  .collection('cards');

              // Get the highest rank value
              QuerySnapshot querySnapshot = await favoritesCollection
                  .orderBy('rank', descending: true)
                  .limit(1)
                  .get();

              int newRank = 1; // Default rank if no cards exist
              if (querySnapshot.docs.isNotEmpty) {
                int highestRank = querySnapshot.docs.first['rank'];
                newRank =
                    highestRank + 1; // New rank is one higher than highest
              }

              // Add the card to the 'favorites' collection
              favoritesCollection.doc(newCardID).set({
                'cardID': newCardID,
                'title': newCardTitle,
                'category': selectedCategory,
                'rank': newRank,
              }).then((_) {
                print('Card added to favorites');
              }).catchError((e) {
                print('Error adding card to favorites: $e');
              });
            }
          }).catchError((e) {
            print('Error checking isFavorite: $e');
          });
        }).catchError((e) {
          print('Error adding card: $e');
        });
      }
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
