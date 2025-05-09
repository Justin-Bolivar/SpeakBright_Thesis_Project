// communicate.dart
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/cards/card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/card_transition.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';


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
  List<String> words = [];
  List<String> categories = [];
  int currentUserPhase = 1;
  int selectedCategory = -1;
  String sentencePrefix = "I feel";
  bool pressSpeak = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _firestoreService.fetchCategories().then((value) {
      setState(() {
        categories.addAll(value);
      });
    });
    fetchPhase();
    initializeHive();
  }

  void _clearSentence() {
    setState(() {
      pressSpeak = false;
      sentence.clear();
      words.clear();

      if (currentUserPhase == 2) {
        sentence.add("I want");
        sentence.add("____");
      } else if (currentUserPhase == 3) {
        sentence.add("I feel");
        sentence.add("____");
      }
    });
  }

  Future<void> initializeHive() async {
      if (!Hive.isBoxOpen('transitionsBox')) {
        await Hive.initFlutter();
        Hive.registerAdapter(CardTransitionAdapter());
        await Hive.openBox<CardTransition>('transitionsBox');
      }
  }

  void addCardTitleToSentence(String title, String category) {
    setState(() {
      if (sentence.length >= 4) {
        _clearSentence();
      }

      String prefix = "";
      String formattedTitle = title;

      // Determine prefix and format title based on category
      if (category == "Emotions") {
        prefix = "I feel";
      } else if (category == "Activities") {
        prefix = "I want";
        // Add "to" before the activity title
        formattedTitle = "to $title";
      } else {
        prefix = "I want";
        // Add "a" or "an" based on the title
        if (_startsWithVowel(title)) {
          formattedTitle = "an $title";
        } else {
          formattedTitle = "a $title";
        }
      }

      if (sentence.isNotEmpty) {
        // Replace the first card title if the sentence already has 2 parts
        if (sentence.length > 2) {
          sentence[0] = prefix;
          sentence[1] = formattedTitle;
          words[0] = formattedTitle;
        } else {
          // Add the new title with the prefix
          sentence.addAll([prefix, formattedTitle]);
          words.add(formattedTitle);
        }
      } else {
        // If the sentence is empty, add the new title with the prefix
        sentence.addAll([prefix, formattedTitle]);
        words.add(formattedTitle);
      }
    });
  }

// Helper function to check if a word starts with a vowel
  bool _startsWithVowel(String word) {
    if (word.isEmpty) return false;
    final vowels = ['a', 'e', 'i', 'o', 'u'];
    return vowels.contains(word[0].toLowerCase());
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  void constructSentenceAndSpeak(List<String> sentence) {
    if (sentence.isEmpty) {
      _ttsService.speak("The sentence list is empty.");
      pressSpeak = true;
      return;
    }

    List<String> emotions = [];
    List<String> objects = [];

    for (int i = 0; i < sentence.length - 1; i += 2) {
      if (sentence[i] == "I feel") {
        emotions.add(sentence[i + 1]);
      } else if (sentence[i] == "I want") {
        objects.add(sentence[i + 1]);
      }
    }

    String emotionPart = "";
    if (emotions.isNotEmpty) {
      if (emotions.length == 1) {
        emotionPart = "I am ${emotions[0]}";
      } else {
        String lastEmotion = emotions.removeLast();
        emotionPart = "I am ${emotions.join(', ')} and $lastEmotion";
      }
    }

    String objectPart = "";
    if (objects.isNotEmpty) {
      if (objects.length == 1) {
        objectPart = "I want ${objects[0]}";
      } else {
        String lastObject = objects.removeLast();
        objectPart = "I want ${objects.join(', ')} and $lastObject";
      }
    }

    String finalSentence = "$emotionPart $objectPart".trim();
    setState(() {
      sentence.clear();
      sentence.addAll(finalSentence.split(' '));
    });
    _ttsService.speak(finalSentence);
    pressSpeak = true;
  }

  // Future<void> _sendSentenceAndSpeak() async {
  //   String sentenceString = sentence.join(' ');
  //   String pronoun = "I";
  //   words.add(pronoun);
  //   print(words);

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Center(
  //         child: LoadingAnimationWidget.staggeredDotsWave(
  //           color: kLightPruple,
  //           size: 50.0,
  //         ),
  //       );
  //     },
  //   );

  //   try {
  //     if (currentUserPhase == 4) {
  //       String urlPhase4 =
  //           'https://speakbright-api-sentence-creation.onrender.com/complete_sentence';

  //       final response = await http.post(
  //         Uri.parse(urlPhase4),
  //         headers: {'Content-Type': 'application/json; charset=UTF-8'},
  //         body: jsonEncode(<String, dynamic>{'words': words}),
  //       );

  //       if (response.statusCode == 200) {
  //         Map<String, dynamic> responseBody = jsonDecode(response.body);

  //         setState(() {
  //           sentence.clear();
  //           sentence.addAll(responseBody['sentence'].split(' '));
  //           words.clear();
  //         });

  //         sentenceString = sentence.join(' ');
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Failed to create sentence: ${response.body}'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //         Map<String, dynamic> errorResponse = jsonDecode(response.body);
  //         String errorMessage =
  //             errorResponse['detail'].replaceFirst('Error: ', '');
  //         _ttsService.speak(errorMessage);
  //         setState(() {
  //           _clearSentence();
  //         });
  //       }

  //       //_firestoreService.storeSentence(sentence);
  //       _ttsService.speak(sentenceString);
  //       pressSpeak = true;
  //     } else {
  //       //_firestoreService.storeSentence(sentence);
  //       _ttsService.speak(sentenceString);
  //       pressSpeak = true;
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   } finally {
  //     Navigator.of(context).pop();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsStreamProvider);
    final recommendedCards = ref.watch(recommendedCardsProvider);
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
      body: Column(
        children: [
          if (showSentenceWidget)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.98,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          DottedBorder(
                            color: dullpurple,
                            strokeWidth: 1,
                            dashPattern: const [6, 7],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(20.0),
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * .8,
                              decoration: BoxDecoration(
                                color: kwhite,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: Text(
                                  sentence.join(' '),
                                  style: const TextStyle(
                                      color: kLightPruple,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ),
                          //if (showSentenceWidget)
                          Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.10,
                                height:
                                    MediaQuery.of(context).size.width * 0.10,
                                decoration: BoxDecoration(
                                  color: mainpurple,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: () =>
                                      constructSentenceAndSpeak(sentence),
                                  icon: Icon(
                                    Icons.volume_up,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width *
                                        0.06,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                // width: 30,
                                height: 15,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.10,
                                height:
                                    MediaQuery.of(context).size.width * 0.10,
                                decoration: BoxDecoration(
                                  color: mainpurple,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: _clearSentence,
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width *
                                        0.06,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                      margin: const EdgeInsets.only(left: 10),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Recommended Cards',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                firstChild: const SizedBox.shrink(),
                secondChild: recommendedCards.isEmpty
                    ? const Center(
                        child: Text(
                          'No recommended cards available',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      )
                    : SizedBox(
                        height: 280, // or whatever height suits your grid
                        child: CardGrid(
                          cards: recommendedCards,
                          isRecommended: true,
                          onCardTap: (cardTitle, category, cardId) async {
                            if (pressSpeak == true) {
                              _clearSentence();
                              pressSpeak = false;
                            }
                            addCardTitleToSentence(cardTitle, category);
                            _ttsService.speak(cardTitle);
                            _firestoreService.storeTappedCards(cardTitle, category, cardId);
                            
                            print('cardId before calling update: $cardId');
                            // await ref.read(recommendedCardsProvider.notifier).updateRecommendedCardsWithToCard(cardId);

                          },
                          onCardDelete: (cardId) {
                            ref.read(cardProvider.notifier).deleteCard(cardId, '0');
                          },
                          selectedCategory: selectedCategory == -1
                              ? "All"
                              : categories[selectedCategory],
                        ),
                      ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
            ],
          ),

          
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft, // Aligns the text to the left
              child: Text(
                'All Cards',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Makes the text bold
                ),
              ),
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
                    if (pressSpeak == true) {
                      _clearSentence();
                      pressSpeak = false;
                      addCardTitleToSentence(cardTitle, category);
                      _ttsService.speak(cardTitle);
                      _firestoreService.storeTappedCards(
                          cardTitle, category, cardId);
                      print('title: $cardTitle, cat: $category');
                    } else {
                      addCardTitleToSentence(cardTitle, category);
                      _ttsService.speak(cardTitle);
                      _firestoreService.storeTappedCards(
                          cardTitle, category, cardId);
                      print('title: $cardTitle, cat: $category');
                    }
                  },
                  onCardDelete: (String cardId) {
                    ref.read(cardProvider.notifier).deleteCard(cardId, '0');
                  },
                  selectedCategory: selectedCategory == -1
                      ? "All"
                      : categories[selectedCategory],
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
        } else if (currentUserPhase == 3) {
          sentence.clear();
        }
      });
    } else {
      print('User document not found.');
    }
  }
}
