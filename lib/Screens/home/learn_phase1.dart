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
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.category, color: phase1Color),
            onSelected: (index) {
              setState(() {
                selectedCategory = index;
              });
            },
            itemBuilder: (context) =>
                List.generate(phase1Categories.length, (index) {
              final category = phase1Categories[index];
              int colorIndex = index % boxColors.length;
              Color itemColor = boxColors[colorIndex];

              return PopupMenuItem<int>(
                value: index,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: selectedCategory == index
                        ? itemColor
                        : itemColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: selectedCategory == index
                        ? [
                            BoxShadow(
                              color: itemColor,
                              spreadRadius: 3,
                              blurRadius: 6,
                              offset: const Offset(0, 0),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        phase1Icons[index % phase1Icons.length],
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
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
                  setState(() {});
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
                        padding: const EdgeInsets.all(30.0),
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
                      const SizedBox(height: 16),
                      // card part

                      // Wrap the FutureBuilder inside the widget tree properly
                      selectedCategory == 0
                          ? FutureBuilder<List<CardModel>?>(
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
                                  ));
                                }

                                final CardModel topFavoriteCard = cards[0];
                                final CardModel? distractorCard =
                                    cards.length > 1 ? cards[1] : null;

                                return FutureBuilder<bool>(
                                  future: _firestoreService
                                      .showDistractor(topFavoriteCard.id),
                                  builder: (context, distractorSnapshot) {
                                    if (distractorSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(child: WaitingDialog());
                                    }

                                    if (distractorSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error: ${distractorSnapshot.error}'));
                                    }

                                    bool showDistractor =
                                        distractorSnapshot.data ?? false;

                                    // Set the values for cardId and showDistractor

                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: showDistractor == false
                                          ? Column(
                                              children: [
                                                Phase1Card(
                                                  fontSize: 20,
                                                  card: topFavoriteCard,
                                                  onTap: () {
                                                    cardActivity.setCardId(
                                                        topFavoriteCard.id);
                                                    cardActivity
                                                        .setShowDistractor(
                                                            showDistractor);
                                                    final cardTitle =
                                                        topFavoriteCard.title;
                                                    final category =
                                                        topFavoriteCard
                                                            .category;
                                                    final cardId =
                                                        topFavoriteCard.id;
                                                    _firestoreService
                                                        .setCurrentlyLearningCard(
                                                            cardId,
                                                            phase1Categories[
                                                                selectedCategory]);

                                                    print(
                                                        'Top Favorite - title: $cardTitle, cat: $category');
                                                    _ttsService
                                                        .speak(cardTitle);
                                                    _firestoreService
                                                        .storeTappedCards(
                                                            cardTitle,
                                                            category,
                                                            cardId);
                                                  },
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Phase1Card(
                                                  fontSize: 20,
                                                  card: topFavoriteCard,
                                                  onTap: () {
                                                    cardActivity.setCardId(
                                                        topFavoriteCard.id);
                                                    cardActivity
                                                        .setShowDistractor(
                                                            showDistractor);
                                                    final cardTitle =
                                                        topFavoriteCard.title;
                                                    final category =
                                                        topFavoriteCard
                                                            .category;
                                                    final cardId =
                                                        topFavoriteCard.id;
                                                    _firestoreService
                                                        .setCurrentlyLearningCard(
                                                            cardId,
                                                            phase1Categories[
                                                                selectedCategory]);
                                                    print(
                                                        'Top Favorite - title: $cardTitle, cat: $category');

                                                    _ttsService
                                                        .speak(cardTitle);
                                                    _firestoreService
                                                        .storeTappedCards(
                                                            cardTitle,
                                                            category,
                                                            cardId);
                                                  },
                                                ),
                                                SizedBox(width: 25),
                                                if (showDistractor &&
                                                    distractorCard != null)
                                                  Phase1Card(
                                                    widthFactor: 0.35,
                                                    heightFactor: 0.35,
                                                    card: distractorCard,
                                                    onTap: () {
                                                      final cardTitle =
                                                          distractorCard.title;
                                                      final category =
                                                          distractorCard
                                                              .category;
                                                      print(
                                                          'Distractor - title: $cardTitle, cat: $category');
                                                      _ttsService
                                                          .speak(cardTitle);
                                                    },
                                                  ),
                                              ],
                                            ),
                                    );
                                  },
                                );
                              },
                            )
                          : FutureBuilder<List<CardModel>?>(
                              //other categery
                              future: TopCategoryCard
                                  .fetchTopCategoryAndDistractorCards(
                                      phase1Categories[selectedCategory]),
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(50.0),
                                      child: Text(
                                        'Category ${phase1Categories[selectedCategory]} must have at least 10 cards :(',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                  );
                                }

                                final CardModel topCategoryCard = cards[0];
                                final CardModel? distractorCard =
                                    cards.length > 1 ? cards[1] : null;

                                return FutureBuilder<bool>(
                                  future: _firestoreService
                                      .showDistractor(topCategoryCard.id),
                                  builder: (context, distractorSnapshot) {
                                    if (distractorSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(child: WaitingDialog());
                                    }

                                    if (distractorSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error: ${distractorSnapshot.error}'));
                                    }

                                    bool showDistractor =
                                        distractorSnapshot.data ?? false;

                                    // Set the values for cardId and showDistractor

                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: showDistractor == false
                                          ? Column(
                                              children: [
                                                Phase1Card(
                                                  fontSize: 20,
                                                  card: topCategoryCard,
                                                  onTap: () {
                                                    cardActivity.setCardId(
                                                        topCategoryCard.id);
                                                    cardActivity
                                                        .setShowDistractor(
                                                            showDistractor);

                                                    final cardTitle =
                                                        topCategoryCard.title;
                                                    final category =
                                                        topCategoryCard
                                                            .category;
                                                    final cardIdCategory =
                                                        topCategoryCard.id;
                                                    print(
                                                        'Top Category - title: $cardTitle, cat: $category');
                                                    _firestoreService
                                                        .setCurrentlyLearningCard(
                                                            cardIdCategory,
                                                            phase1Categories[
                                                                selectedCategory]);

                                                    _ttsService
                                                        .speak(cardTitle);
                                                    _firestoreService
                                                        .storeTappedCards(
                                                            cardTitle,
                                                            category,
                                                            cardIdCategory);
                                                  },
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Phase1Card(
                                                  fontSize: 20,
                                                  card: topCategoryCard,
                                                  onTap: () {
                                                    cardActivity.setCardId(
                                                        topCategoryCard.id);
                                                    cardActivity
                                                        .setShowDistractor(
                                                            showDistractor);
                                                    final cardTitle =
                                                        topCategoryCard.title;
                                                    final category =
                                                        topCategoryCard
                                                            .category;
                                                    final cardIdCategory =
                                                        topCategoryCard.id;
                                                    print(
                                                        'Top Category - title: $cardTitle, cat: $category');
                                                    _firestoreService
                                                        .setCurrentlyLearningCard(
                                                            cardIdCategory,
                                                            phase1Categories[
                                                                selectedCategory]);

                                                    _ttsService
                                                        .speak(cardTitle);
                                                    _firestoreService
                                                        .storeTappedCards(
                                                            cardTitle,
                                                            category,
                                                            cardIdCategory);
                                                  },
                                                ),
                                                SizedBox(width: 25),
                                                if (showDistractor &&
                                                    distractorCard != null)
                                                  Phase1Card(
                                                    widthFactor: 0.35,
                                                    heightFactor: 0.35,
                                                    card: distractorCard,
                                                    onTap: () {
                                                      final cardTitle =
                                                          distractorCard.title;
                                                      final category =
                                                          distractorCard
                                                              .category;
                                                      print(
                                                          'Distractor - title: $cardTitle, cat: $category');
                                                      _ttsService
                                                          .speak(cardTitle);
                                                    },
                                                  ),
                                              ],
                                            ),
                                    );
                                  },
                                );
                              },
                            ),
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
