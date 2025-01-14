// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/cards/card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/prompt/prompt_button.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Learn4 extends ConsumerStatefulWidget {
  const Learn4({super.key});

  static const String route = "/learn4";
  static const String path = "/learn4";
  static const String name = "Learn4";

  @override
  ConsumerState<Learn4> createState() => _Learn4State();
}

class _Learn4State extends ConsumerState<Learn4> {
  final TTSService _ttsService = TTSService();
  final FirestoreService _firestoreService = FirestoreService();

  List<String> sentence = [];
  List<String> words = [];
  List<String> categories = [];
  String finalSentence = "";
  int currentUserPhase = 4;
  int selectedCategory = -1;
  bool pressSpeak = false;

  @override
  void initState() {
    super.initState();
    _firestoreService.fetchCategories().then((value) {
      setState(() {
        categories.addAll(value);
      });
    });
  }

  void _clearSentence() {
    setState(() {
      pressSpeak = false;
      sentence.clear();
      words.clear();
    });
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
  //   String sentenceString = "I";
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
  //     String urlPhase4 =
  //         'https://speakbright-api-sentence-creation.onrender.com/complete_sentence';

  //     final response = await http.post(
  //       Uri.parse(urlPhase4),
  //       headers: {'Content-Type': 'application/json; charset=UTF-8'},
  //       body: jsonEncode(<String, dynamic>{'words': words}),
  //     );

  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> responseBody = jsonDecode(response.body);

  //       setState(() {
  //         sentence.clear();
  //         sentence.addAll(responseBody['sentence'].split(' '));
  //         words.clear();
  //       });

  //       sentenceString = sentence.join(' ');
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to create sentence: ${response.body}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       Map<String, dynamic> errorResponse = jsonDecode(response.body);
  //       String errorMessage =
  //           errorResponse['detail'].replaceFirst('Error: ', '');
  //       _ttsService.speak(errorMessage);
  //       setState(() {
  //         _clearSentence();
  //       });
  //     }

  //     //_firestoreService.storeSentence(sentence);
  //     _ttsService.speak(sentenceString);
  //     pressSpeak = true;
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   } finally {
  //     Navigator.of(context).pop();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsListProviderPhase4);
    return Scaffold(
      backgroundColor: kwhite,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 5, top: 10),
            child: Image.asset(
              'assets/phase/phase4.png',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                      child: pressSpeak == false
                          ? Center(
                              child: Text(
                                sentence.isEmpty
                                    ? "Tap on cards to create a Sentence"
                                    : sentence.join(' '),
                                style: TextStyle(
                                    color: kLightPruple,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          : Center(
                              child: Text(
                                sentence.join(' '),
                                style: TextStyle(
                                    color: kLightPruple,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: mainpurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () => constructSentenceAndSpeak(sentence),
                          icon: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: mainpurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: _clearSentence,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          Expanded(
            child: cardsAsyncValue.when(
              data: (cards) {
                print('Cards fetched successfully: ${cards.length}');
                return CardGrid(
                  phase: 4,
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
}
