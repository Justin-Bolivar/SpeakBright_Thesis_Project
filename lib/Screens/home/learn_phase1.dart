import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/cards/card_list.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
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

  List<String> sentence = [];
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
    fetchPhase();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsListProvider);

    return Scaffold(
      backgroundColor: kwhite,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(_isMenuCollapsed ? Icons.menu : Icons.close,
              color: Colors.white),
          onPressed: () {
            setState(() {
              _isMenuCollapsed = !_isMenuCollapsed;
            });
          },
        ),
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
          List<CardModel> filteredCards = cards;
          if (_selectedTargetCard != null) {
            filteredCards = cards
                .where((card) => card.title == _selectedTargetCard)
                .toList();
          }
          return Row(
            children: [
              if (!_isMenuCollapsed)
                Container(
                  width: 200,
                  color: Colors.grey[200],
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            int colorIndex = index % boxColors.length;
                            Color itemColor = boxColors[colorIndex];

                            //temporary, to be added in firebase
                            List<IconData> icons = [
                              Icons.category,
                              MdiIcons.foodAppleOutline,
                              MdiIcons.teddyBear,
                              MdiIcons.emoticonHappyOutline,
                              MdiIcons.schoolOutline,
                              MdiIcons.weightLifter,
                              MdiIcons.broom,
                              MdiIcons.sunglasses,
                              MdiIcons.accountGroupOutline,
                              MdiIcons.earth,
                            ];
                            bool isSelected = selectedCategory == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = index;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: itemColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: isSelected
                                      ? <BoxShadow>[
                                          BoxShadow(
                                            color: itemColor,
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      icons[index % icons.length],
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Target Card",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedTargetCard,
                              hint: const Text("Select a card"),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTargetCard = newValue;
                                });
                              },
                              items:
                                  availableCards.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Number of Trials",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<int>(
                              value: _trials,
                              onChanged: (int? newValue) {
                                setState(() {
                                  _trials = newValue!;
                                });
                              },
                              items: List.generate(16, (index) => index + 5)
                                  .map<DropdownMenuItem<int>>(
                                (int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );
                                },
                              ).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 5),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/Diversity.png',
                                height: 40,
                                width: 40,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Phase $currentUserPhase",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 24, color: kblack),
                                  ),
                                  const Text(
                                    "Select a category and tap on cards you want",
                                    textAlign: TextAlign.left,
                                    style:
                                        TextStyle(fontSize: 12, color: kblack),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer()
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CardList(
                        cards: filteredCards,
                        onCardTap:
                            (String cardTitle, String category, String cardId) {
                          _firestoreService.tapCountIncrement(cardId);
                          _ttsService.speak(cardTitle);
                          _firestoreService.storeTappedCards(
                              cardTitle, category, cardId);
                          print('title: $cardTitle, cat: $category');
                        },
                        onCardDelete: (String cardId) {
                          ref.read(cardProvider.notifier).deleteCard(cardId);
                        },
                        selectedCategory: selectedCategory == -1
                            ? "All"
                            : categories[selectedCategory],
                      ),
                    ),
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

  Future<void> fetchPhase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    String userId = user.uid;

    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    DocumentSnapshot userDoc = await userRef.doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        currentUserPhase = userDoc.get('phase');
        if (currentUserPhase == 2) {
          sentence.clear();
          sentence.add("I want");
        } else if (currentUserPhase == 3) {
          sentence.clear();
          sentence.add("I feel");
        }
      });
    } else {
      print('User document not found.');
    }
  }
}
