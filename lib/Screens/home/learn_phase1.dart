import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/Widgets/cards/phase1Card.dart';
import 'package:speakbright_mobile/Widgets/cards/topFavorite.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/prompt/prompt_button.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Learn1 extends ConsumerStatefulWidget {
  const Learn1({super.key});

  static const String route = "/learn1";
  static const String path = "/learn1";
  static const String name = "Learn1";

  @override
  ConsumerState<Learn1> createState() => _Learn1State();
}

class _Learn1State extends ConsumerState<Learn1> {
  final TTSService _ttsService = TTSService();
  final FirestoreService _firestoreService = FirestoreService();

  List<String> categories = [];
  int currentUserPhase = 1;
  int selectedCategory = -1;
  bool _isMenuCollapsed = true;
  String? _selectedTargetCard;
  int _trials = 5;

  @override
  void initState() {
    super.initState();
    _firestoreService.fetchCategories().then((value) {
      setState(() {
        categories.addAll(value);
      });
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<CardModel?> _fetchFavoriteCardWithPhaseCheck() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final favoritesRef =
        FirebaseFirestore.instance.collection('favorites').doc(userId);
    final favoritesSnapshot = await favoritesRef.get();

    if (!favoritesSnapshot.exists) {
      print('No favorite snapshot found for this user.');
      return null;
    }

    List<Map<String, dynamic>>? favoriteData =
        favoritesSnapshot.data()?['cards'];

    if (favoriteData != null && favoriteData.isNotEmpty) {
      favoriteData
          .sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));

      for (var favorite in favoriteData) {
        String cardId = favorite['cardID'];

        Map<String, dynamic>? cardData = await fetchDataFromFirestore(cardId);
        if (cardData != null && cardData['phase1Independence'] == false) {
          return CardModel(
            id: cardId,
            title: cardData['title'] ?? '',
            imageUrl: cardData['imageUrl'] ?? '',
            userId: cardData['userId'] ?? '',
            category: cardData['category'] ?? '',
            tapCount: cardData['tapCount'] ?? 0,
            isFavorite: cardData['isFavorite'] ?? false,
            phase1_independence: cardData['phase1Independence'] ?? false,
            phase2_independence: cardData['phase2Independence'] ?? false,
            phase3_independence: cardData['phase3Independence'] ?? false,
          );
        }
      }
    }

    print("No suitable favorite card found with phase1_independence as false.");
    return null;
  }

  Future<Map<String, dynamic>?> fetchDataFromFirestore(
      String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('cards')
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        String title = data['title'] ?? '';
        String imageUrl = data['imageUrl'] ?? '';
        String userId = data['userId'] ?? '';
        String category = data['category'] ?? '';
        int tapCount = data['tapCount'] ?? 0;
        bool isFavorite = data['isFavorite'] ?? false;
        bool phase1Independence = data['phase1_independence'] ?? false;
        bool phase2Independence = data['phase2_independence'] ?? false;
        bool phase3Independence = data['phase3_independence'] ?? false;

        Map<String, dynamic> cardData = {
          'title': title,
          'imageUrl': imageUrl,
          'userId': userId,
          'category': category,
          'tapCount': tapCount,
          'isFavorite': isFavorite,
          'phase1Independence': phase1Independence,
          'phase2Independence': phase2Independence,
          'phase3Independence': phase3Independence,
        };

        return cardData;
      } else {
        print("Document does not exist");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  Future<Widget> showCardWithPhaseCheck() async {
    try {
      CardModel? favoriteCard = await _fetchFavoriteCardWithPhaseCheck();
      if (favoriteCard != null) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                favoriteCard.imageUrl,
                width: 200,
                height: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Text(
                favoriteCard.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      } else {
        print("No suitable favorite card found");
        return Container(
          child: Text("No suitable favorite card found"),
        );
      }
    } catch (e) {
      print("Error: $e");
      return Container(
        child: Text("Error: $e"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsListProvider);

    return Scaffold(
      backgroundColor: kwhite,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF8E2DE2), mainpurple],
            ),
          ),
        ),
        elevation: 5,
        title: const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Learn",
                style: TextStyle(
                  color: kwhite,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
              ),
              PromptButton(phaseCurrent: currentUserPhase),
            ],
          ),
        ),
      ),
      body: cardsAsyncValue.when(
        data: (cards) {
          List<String> availableCards =
              cards.map((card) => card.title).toList();
          List<CardModel> filteredCards = cards.cast<CardModel>();
          if (_selectedTargetCard != null) {
            filteredCards = cards
                .where((card) => card.title == _selectedTargetCard)
                .cast<CardModel>()
                .toList();
          }
          return Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.20,
                          // color: scoreYellow,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Center(
                              child: _isMenuCollapsed
                                  ? Stack(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Phase',
                                              style:
                                                  GoogleFonts.rubikSprayPaint(
                                                      color: phase1Color,
                                                      fontSize: 50,
                                                      letterSpacing: 0.5),
                                            ),
                                            Image.asset(
                                              'assets/phase/1.png',
                                              height: 80,
                                            )
                                          ],
                                        ),
                                        Positioned(
                                          left: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isMenuCollapsed =
                                                    !_isMenuCollapsed;
                                              });
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(20.0),
                                                bottomRight:
                                                    Radius.circular(20.0),
                                              ),
                                              child: Container(
                                                width: 30.0,
                                                height: 80.0,
                                                color: dullpurple,
                                                child: Center(
                                                  child: Image.asset(
                                                    'assets/option_expand.png',
                                                    width: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            border: Border.all(
                                              color: lGray,
                                              width: 2.0,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: const Offset(3, 3),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '1 ',
                                                        style:
                                                            GoogleFonts.roboto(
                                                                color:
                                                                    boxColors[
                                                                        0],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 24),
                                                      ),
                                                      Text(
                                                        'Choose a Category',
                                                        style: GoogleFonts
                                                            .singleDay(
                                                                color: lGray,
                                                                fontSize: 20),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 50,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          categories.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final category =
                                                            categories[index];
                                                        int colorIndex = index %
                                                            boxColors.length;
                                                        Color itemColor =
                                                            boxColors[
                                                                colorIndex];

                                                        //temporary, to be added in firebase
                                                        List<IconData> icons = [
                                                          Icons.category,
                                                          MdiIcons
                                                              .foodAppleOutline,
                                                          MdiIcons.teddyBear,
                                                          MdiIcons
                                                              .emoticonHappyOutline,
                                                          MdiIcons
                                                              .schoolOutline,
                                                          MdiIcons.weightLifter,
                                                          MdiIcons.broom,
                                                          MdiIcons.sunglasses,
                                                          MdiIcons
                                                              .accountGroupOutline,
                                                          MdiIcons.earth,
                                                        ];
                                                        bool isSelected =
                                                            selectedCategory ==
                                                                index;

                                                        return GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              selectedCategory =
                                                                  index;
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: itemColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              boxShadow: isSelected
                                                                  ? <BoxShadow>[
                                                                      BoxShadow(
                                                                        color:
                                                                            itemColor,
                                                                        spreadRadius:
                                                                            1,
                                                                        blurRadius:
                                                                            2,
                                                                        offset: const Offset(
                                                                            0,
                                                                            1),
                                                                      ),
                                                                    ]
                                                                  : [],
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  category,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  icons[index %
                                                                      icons
                                                                          .length],
                                                                  color: Colors
                                                                      .white,
                                                                  size: 15,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ), //end of category list
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '2 ',
                                                                style: GoogleFonts.roboto(
                                                                    color:
                                                                        boxColors[
                                                                            1],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        24),
                                                              ),
                                                              Text(
                                                                'Select a Target Card',
                                                                style: GoogleFonts
                                                                    .singleDay(
                                                                        color:
                                                                            lGray,
                                                                        fontSize:
                                                                            20),
                                                              )
                                                            ],
                                                          ),
                                                          DropdownButton<
                                                              String>(
                                                            value:
                                                                _selectedTargetCard,
                                                            hint: const Text(
                                                                "Select a card"),
                                                            onChanged: (String?
                                                                newValue) {
                                                              setState(() {
                                                                _selectedTargetCard =
                                                                    newValue;
                                                              });
                                                            },
                                                            items: availableCards.map<
                                                                DropdownMenuItem<
                                                                    String>>(
                                                              (String value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                      value),
                                                                );
                                                              },
                                                            ).toList(),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '3 ',
                                                                style: GoogleFonts.roboto(
                                                                    color:
                                                                        boxColors[
                                                                            4],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        24),
                                                              ),
                                                              Text(
                                                                'Number of Trials',
                                                                style: GoogleFonts
                                                                    .singleDay(
                                                                        color:
                                                                            lGray,
                                                                        fontSize:
                                                                            20),
                                                              )
                                                            ],
                                                          ),
                                                          DropdownButton<int>(
                                                            value: _trials,
                                                            onChanged: (int?
                                                                newValue) {
                                                              setState(() {
                                                                _trials =
                                                                    newValue!;
                                                              });
                                                            },
                                                            items: List
                                                                .generate(
                                                                    16,
                                                                    (index) =>
                                                                        index +
                                                                        5).map<
                                                                DropdownMenuItem<
                                                                    int>>(
                                                              (int value) {
                                                                return DropdownMenuItem<
                                                                    int>(
                                                                  value: value,
                                                                  child: Text(value
                                                                      .toString()),
                                                                );
                                                              },
                                                            ).toList(),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 18.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            print(
                                                                'Container clicked');
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: addGreen,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40.0),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'Set',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: kwhite,
                                                                ),
                                                              ),
                                                            ),
                                                            width: 100,
                                                            height: 50,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isMenuCollapsed =
                                                  !_isMenuCollapsed;
                                            });
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0),
                                            ),
                                            child: Container(
                                              width: 30.0,
                                              height: 80.0,
                                              color: dullpurple,
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/option_collapse.png',
                                                  width: 30,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Expanded(
                    //   child: CardList(
                    //     cards: filteredCards,
                    //     onCardTap:
                    //         (String cardTitle, String category, String cardId) {
                    //       _ttsService.speak(cardTitle);
                    //       _firestoreService.storeTappedCards(
                    //           cardTitle, category, cardId);
                    //       print('title: $cardTitle, cat: $category');
                    //     },
                    //     onCardDelete: (String cardId) {
                    //       ref.read(cardProvider.notifier).deleteCard(cardId);
                    //     },
                    //     selectedCategory: selectedCategory == -1
                    //         ? "All"
                    //         : categories[selectedCategory],
                    //   ),
                    // ),
                    FutureBuilder<CardModel?>(
                      future: TopFavoriteCard.fetchTopFavoriteCard(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final CardModel? topFavoriteCard = snapshot.data;

                        if (topFavoriteCard == null) {
                          return Center(child: Text('No favorite card found.'));
                        }

                        return Phase1Card(
                          card: topFavoriteCard,
                          onTap: () {
                            
                            final cardTitle = topFavoriteCard.title;
                            final category = topFavoriteCard
                                .category; 
                            final cardId = topFavoriteCard
                                .id; 
                            print('title: $cardTitle, cat: $category');

                            _ttsService.speak(cardTitle);
                            _firestoreService.storeTappedCards(
                                cardTitle, category, cardId);
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        },
        loading: () {
          print('Loading cards...');
          return const Center(child: WaitingDialog());
        },
        error: (error, stack) {
          print('Error fetching cards: $error');
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }
}

// Define the CardModel class
// class CardModel {
//   final String id;
//   final String title;
//   final String imageUrl;
//   final String userId;
//   final String category;
//   final int tapCount;
//   final bool isFavorite;
//   final bool phase1Independence;
//   final bool phase2Independence;
//   final bool phase3Independence;

//   CardModel({
//     required this.id,
//     required this.title,
//     required this.imageUrl,
//     required this.userId,
//     required this.category,
//     required this.tapCount,
//     required this.isFavorite,
//     required this.phase1Independence,
//     required this.phase2Independence,
//     required this.phase3Independence,
//   });
// }
