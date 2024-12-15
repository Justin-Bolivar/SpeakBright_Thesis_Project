// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/Widgets/cards/phase1Card.dart';
import 'package:speakbright_mobile/Widgets/cards/top_favorite.dart';
import 'package:speakbright_mobile/Widgets/cards/top_category.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/prompt/prompt_button.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
import 'package:speakbright_mobile/providers/card_activity_provider.dart';

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

  // List<String> categories = [];
  int currentUserPhase = 1;
  int selectedCategory = 0;

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardActivity =
        ref.watch(cardActivityProvider); // Access CardActivityProvider

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: phase1Color),
        backgroundColor: learn1bg,
        // actions: [
        //   PopupMenuButton<int>(
        //     icon: Icon(Icons.category, color: phase1Color),
        //     onSelected: (index) {
        //       setState(() {
        //         selectedCategory = index;
        //       });
        //     },
        //     itemBuilder: (context) =>
        //         List.generate(phase1Categories.length, (index) {
        //       return PopupMenuItem<int>(
        //         value: index,
        //         child: Container(),
        //       );
        //     }),
        //   ),
        // ],
      ),
      backgroundColor: learn1bg,
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Row(
            children: [
              SizedBox(width: 20),
              PromptButton(
                phaseCurrent: currentUserPhase,
                onRefresh: () {
                  setState(() {
                    ref.watch(cardActivityProvider);
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg-1.1.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10,20,10,20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Phase',
                              style: GoogleFonts.rubikSprayPaint(
                                color: phase1Color,
                                fontSize: 50,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(3, 3),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'assets/phase/1.png',
                              height: 80,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),

                      Container(
                        height: 30, 
                        width: 150, 
                        decoration: BoxDecoration(
                          color: phase1Color,
                          borderRadius:
                              BorderRadius.circular(20), 
                        ),
                        child: Center(
                          child: Text(
                            "${cardActivity.trial} out of 20 trials", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 15,
                              fontFamily: 'Roboto', 
                              fontWeight:FontWeight.w100
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // card part

                      // Wrap the FutureBuilder inside the widget tree properly

                      FutureBuilder<List<CardModel>?>(
                        future: TopFavoriteCard
                            .fetchTopFavoriteAndDistractorCards(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: WaitingDialog());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          final List<CardModel>? cards = snapshot.data;

                          if (cards == null || cards.isEmpty) {
                            return Center(
                              child: Text(
                                'No favorite card found.',
                                style: TextStyle(color: phase1Color),
                              ),
                            );
                          }

                          final CardModel topFavoriteCard = cards[0];
                          final CardModel? distractorCard =
                              cards.length > 1 ? cards[1] : null;

                          bool showDistractor = cardActivity.showDistractor;
                          bool showDistractor2 = cardActivity
                              .showDistractor2; // 2nd distractor state

                          print(
                              'LEARN1 PAGE - showDistractor: $showDistractor, showDistractor2: $showDistractor2');

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: showDistractor2
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Phase1Card(
                                          fontSize: 20,
                                          card: topFavoriteCard,
                                          onTap: () {
                                            cardActivity
                                                .setCardId(topFavoriteCard.id);
                                            final cardTitle =
                                                topFavoriteCard.title;
                                            final category =
                                                topFavoriteCard.category;
                                            print(
                                                'Top Favorite - title: $cardTitle, cat: $category');
                                            _ttsService.speak(cardTitle);
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      if (distractorCard != null)
                                        Expanded(
                                          child: Phase1Card(
                                            fontSize: 20,
                                            card: distractorCard,
                                            onTap: () {
                                              final cardTitle =
                                                  distractorCard.title;
                                              final category =
                                                  distractorCard.category;
                                              print(
                                                  'Distractor - title: $cardTitle, cat: $category');
                                              _ttsService.speak(cardTitle);
                                            },
                                          ),
                                        ),
                                    ],
                                  )
                                : (showDistractor
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Phase1Card(
                                            fontSize: 20,
                                            card: topFavoriteCard,
                                            onTap: () {
                                              cardActivity.setCardId(
                                                  topFavoriteCard.id);
                                              final cardTitle =
                                                  topFavoriteCard.title;
                                              final category =
                                                  topFavoriteCard.category;
                                              print(
                                                  'Top Favorite - title: $cardTitle, cat: $category');
                                              _ttsService.speak(cardTitle);
                                            },
                                          ),
                                          SizedBox(width: 25),
                                          if (distractorCard != null)
                                            Phase1Card(
                                              widthFactor: 0.35,
                                              heightFactor: 0.35,
                                              card: distractorCard,
                                              onTap: () {
                                                final cardTitle =
                                                    distractorCard.title;
                                                final category =
                                                    distractorCard.category;
                                                print(
                                                    'Distractor - title: $cardTitle, cat: $category');
                                                _ttsService.speak(cardTitle);
                                              },
                                            ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Phase1Card(
                                            fontSize: 20,
                                            card: topFavoriteCard,
                                            onTap: () {
                                              cardActivity.setCardId(
                                                  topFavoriteCard.id);
                                              final cardTitle =
                                                  topFavoriteCard.title;
                                              final category =
                                                  topFavoriteCard.category;
                                              print(
                                                  'Top Favorite - title: $cardTitle, cat: $category');
                                              _ttsService.speak(cardTitle);
                                            },
                                          ),
                                        ],
                                      )),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
