import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:speakbright_mobile/Routing/router.dart';
import 'package:speakbright_mobile/Screens/home/phase_navigation.dart';
import 'package:speakbright_mobile/Widgets/cards/card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/prompt/prompt_button.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
import 'package:speakbright_mobile/providers/card_activity_provider.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';
import 'package:dotted_border/dotted_border.dart';

class Learn2 extends ConsumerStatefulWidget {
  const Learn2({super.key});

  static const String route = "/learn2";
  static const String path = "/learn2";
  static const String name = "Learn2";

  @override
  ConsumerState<Learn2> createState() => _Learn2State();
}

class _Learn2State extends ConsumerState<Learn2> {
  final TTSService _ttsService = TTSService();
  final FirestoreService _firestoreService = FirestoreService();

  List<String> sentence = [];
  List<String> categories = [];
  int currentUserPhase = 2;
  int selectedCategory = -1;

  @override
  void initState() {
    super.initState();
    _firestoreService.fetchCategories().then((value) {
      setState(() {
        categories.addAll(value.where((category) => category != 'Emotions'));
        sentence.add("I want");
      });
    });
  }

  void _clearSentence() {
    setState(() {
      sentence.clear();
      sentence.add("I want");
    });
  }

  void _addCardTitleToSentence(String title, String category) {
    setState(() {
      if (category == "Activities") {
        if (sentence.length > 1) {
          sentence[sentence.length - 1] = "to $title";
        } else {
          sentence.add("to $title");
        }
      } else {
        if (sentence.length > 1) {
          sentence[sentence.length - 1] = title;
        } else {
          sentence.add(title);
        }
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
      _firestoreService.storeSentence(sentence);
      _ttsService.speak(sentenceString);
      _clearSentence();
    } catch (e) {
      print('Error occurred: $e');
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardActivity = ref.watch(cardActivityProvider);
    final cardsAsyncValue = ref.watch(cardsListProviderPhase2);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: phase2Color, onPressed: () {
            GlobalRouter.I.router.push(PhaseNav.route);
          },),
        backgroundColor: Colors.white,
      ),
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
              'assets/phase/phase2.png',
            ),
          ),
          GestureDetector(
                        onTap: () {
                          // Check the current bufferSize and toggle its value
                          if (cardActivity.bufferSize == 20) {
                            cardActivity.setbufferSize(10);
                          } else if (cardActivity.bufferSize == 10) {
                            cardActivity.setbufferSize(20);
                          }
                        },
                        child: Container(
                          height: 30,
                          width: 150,
                          decoration: BoxDecoration(
                            color: cardActivity.bufferSize == 20? phase2Color.withOpacity(0.5):Color.fromARGB(204, 116, 27, 106),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "${cardActivity.trial} of ${cardActivity.bufferSize} trials",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
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
                      child: sentence.isEmpty
                          ? Center(
                              child: Text(
                                "TAP CARDS TO CREATE A SENTENCE",
                                style: TextStyle(
                                    color: kLightPruple,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: sentence.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(5, 20, 5, 20),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: kwhite,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      sentence[index],
                                      style: const TextStyle(
                                          color: dullpurple, fontSize: 24.0),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  Container(
                    child: Column(
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
                        const SizedBox(
                          height: 15,
                        ),
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
                  phase: 2,
                  cards: cards,
                  onCardTap:
                      (String cardTitle, String category, String cardId) {
                    cardActivity.setCardId(cardId);
                    _addCardTitleToSentence(cardTitle, category);
                    _ttsService.speak(cardTitle);
                    _firestoreService.storeTappedCards(
                        cardTitle, category, cardId);
                    print('title: $cardTitle, cat: $category');
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
