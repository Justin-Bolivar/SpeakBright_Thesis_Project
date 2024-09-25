// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:speakbright_mobile/Routing/router.dart';
import 'package:speakbright_mobile/Screens/home/addcard.dart';
import 'package:speakbright_mobile/Widgets/cards/card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';
import 'package:dotted_border/dotted_border.dart';

class GuardianCommunicate extends ConsumerStatefulWidget {
  const GuardianCommunicate({super.key});
  static const String route = "/GuardianCommunicate";
  static const String path = "/GuardianCommunicate";
  static const String name = "GuardianCommunicate";

  @override
  // ignore: no_logic_in_create_state
  ConsumerState<GuardianCommunicate> createState() =>
      _GuardianCommunicateState();
}

class _GuardianCommunicateState extends ConsumerState<GuardianCommunicate> {
  final TTSService _ttsService = TTSService();
  final FirestoreService _firestoreService = FirestoreService();

  List<String> sentence = [];
  List<String> categories = [];
  int selectedCategory = -1;

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
      sentence.clear();
    });
  }

  void _addCardTitleToSentence(String title) {
    setState(() {
      sentence.add(title);
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsGuardianProvider);
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
                  "Card View",
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
                                color: dullpurple,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Categories",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 24, color: kblack),
                          ),
                          Text(
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

                  bool isSelected = selectedCategory == index;

                  //temporary, to be added in firebase
                List<IconData> icons = [
                  Icons.category,
                  MdiIcons.earth,
                  MdiIcons.emoticonHappyOutline,
                  MdiIcons.weightLifter,
                  MdiIcons.sunglasses,
                  MdiIcons.accountGroupOutline,
                  MdiIcons.broom,
                  MdiIcons.foodAppleOutline,
                  MdiIcons.schoolOutline,
                  MdiIcons.teddyBear,

                ];

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
                data: (cards) => CardGrid(
                  cards: cards,
                  onCardTap:
                      (String cardTitle, String category, String cardId) {},
                  onCardDelete: (String cardId) {
                    ref.read(cardProvider.notifier).deleteCard(cardId);
                  },
                  onCardLongPress: _addCardTitleToSentence,
                  selectedCategory: selectedCategory == -1
                      ? "All"
                      : categories[selectedCategory],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            GlobalRouter.I.router.push(AddCardPage.route);
          },
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ));
  }
}
