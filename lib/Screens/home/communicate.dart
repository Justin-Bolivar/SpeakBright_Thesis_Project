// communicate.dart
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speakbright_mobile/Widgets/cards/card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/prompt/prompt_button.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Communicate extends ConsumerStatefulWidget {
  const Communicate({super.key});

  static const String route = "/communicate";
  static const String path = "/communicate";
  static const String name = "Communicate";

  @override
  ConsumerState<Communicate> createState() => _CommunicateState();
}

class _CommunicateState extends ConsumerState<Communicate> {
  final TTSService _ttsService = TTSService();
  final FirestoreService _firestoreService = FirestoreService();

  List<String> sentence = [];
  List<String> categories = [];
  int currentUserPhase = 1;
  int selectedCategory = -1;

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

  void _clearSentence() {
    setState(() {
      sentence.clear();

      if (currentUserPhase == 2) {
        sentence.add("I want");
      } else if (currentUserPhase == 3) {
        sentence.add("I feel");
      }
    });
  }

  void _addCardTitleToSentence(String title) {
    setState(() {
      if (currentUserPhase == 2 || currentUserPhase == 3) {
        if (sentence.length > 1) {
          sentence[sentence.length - 1] = title;
        } else {
          sentence.add(title);
        }
      } else {
        sentence.add(title);
      }
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _sendSentenceAndSpeak() async {
    String sentenceString = sentence.join(' ');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: kLightPruple,
            size: 50.0,
          ),
        );
      },
    );

    try {
      if (currentUserPhase == 4) {
        String url =
            'https://speakbright-api-sentence-creation.onrender.com/complete_sentence';

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(<String, dynamic>{'text': sentenceString}),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseBody = jsonDecode(response.body);

          setState(() {
            sentence.clear();
            sentence.addAll(responseBody['sentence'].split(' '));
          });

          sentenceString = sentence.join(' ');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create sentence: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            sentence.clear();
          });
        }
      }

      _firestoreService.storeSentence(sentence);
      _ttsService.speak(sentenceString);
      _clearSentence();
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      // Hide the loading animation
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsStreamProvider);
    bool showSentenceWidget = currentUserPhase > 1;

    return Scaffold(
      backgroundColor: kwhite,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
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
                "Communicate",
                style: TextStyle(
                  color: kwhite,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
              ),
              PromptButton(),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (showSentenceWidget)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: DottedBorder(
                  color: dullpurple,
                  strokeWidth: 1,
                  dashPattern: const [6, 7],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(20.0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: kwhite,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sentence.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.fromLTRB(5, 30, 5, 30),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: dullpurple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              sentence[index],
                              style: const TextStyle(
                                  color: dullpurple, fontSize: 14.0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (showSentenceWidget)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: mainpurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: _sendSentenceAndSpeak,
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: mainpurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: _clearSentence,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
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
                          style: const TextStyle(fontSize: 24, color: kblack),
                        ),
                        const Text(
                          "Select a category and tap on cards you want",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 12, color: kblack),
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
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 35,
              maxHeight: 35,
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
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
                  child: SizedBox(
                    height: 30,
                    child: Container(
                      margin: const EdgeInsets.only(left: 18),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            icons[index % icons.length],
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: cardsAsyncValue.when(
              data: (cards) {
                print('Cards fetched successfully: ${cards.length}');
                return CardGrid(
                  cards: cards,
                  onCardTap:
                      (String cardTitle, String category, String cardId) {
                    if (currentUserPhase > 1) {
                      _addCardTitleToSentence(cardTitle);
                      _firestoreService.tapCountIncrement(cardId);
                      _ttsService.speak(cardTitle);
                      _firestoreService.storeTappedCards(cardTitle, category);
                      print('title: $cardTitle, cat: $category');
                    } else {
                      _firestoreService.tapCountIncrement(cardId);
                      _ttsService.speak(cardTitle);
                      _firestoreService.storeTappedCards(cardTitle, category);
                      print('title: $cardTitle, cat: $category');
                    }
                  },
                  onCardDelete: (String cardId) {
                    ref.read(cardProvider.notifier).deleteCard(cardId);
                  },
                  selectedCategory: selectedCategory == -1
                      ? "All"
                      : categories[selectedCategory],
                );
              },
              loading: () {
                print('Loading cards...');
                return const Center(child: CircularProgressIndicator());
              },
              error: (error, stack) {
                print('Error fetching cards: $error');
                return Center(child: Text('Error: $error'));
              },
            ),
          ),
        ],
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
