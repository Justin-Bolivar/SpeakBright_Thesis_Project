// communicate.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:speakbright_mobile/Widgets/cards/card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';

class DashBoard extends ConsumerStatefulWidget {
  const DashBoard({super.key});

  static const String route = "/communicate";
  static const String path = "/communicate";
  static const String name = "Communicate";

  @override
  ConsumerState<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends ConsumerState<DashBoard> {
  final FlutterTts flutterTts = FlutterTts();
  List<String> sentence = [];
  List<String> categories = ['All'];
  int selectedCategory = -1;

  @override
  void initState() {
    super.initState();
    _setupTTS();
    _fetchCategories();
  }

  void _clearSentence() {
    setState(() {
      sentence.clear();
    });
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        categories =
            querySnapshot.docs.map((doc) => doc['category'] as String).toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _setupTTS() async {
    await flutterTts.setLanguage("en-US");
    await _setDefaultVoice();
  }

  Future<void> _setDefaultVoice() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    String voiceName = connectivityResult != ConnectivityResult.none
        ? "Microsoft Aria Online (Natural) - English (United States)"
        : "Microsoft Zira - English (United States)";

    await flutterTts.setVoice({"name": voiceName, "locale": "en-US"});
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _setDefaultVoice();
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _addCardTitleToSentence(String title) {
    setState(() {
      sentence.add(title);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsStreamProvider);
    return Scaffold(
      backgroundColor: kwhite,
      appBar: AppBar(
        backgroundColor: mainpurple,
        elevation: 5,
        title: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Communicate",
                style: TextStyle(
                  color: kwhite,
                  fontSize: 20,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                _speak(sentence.join(' ')); // Speak the current sentence
              },
              icon: const Icon(
                Icons.volume_up,
                color: kwhite,
              ),
            ),
            IconButton(
              onPressed: _clearSentence, // Add this line
              icon: const Icon(
                Icons
                    .delete_outline, // Change the icon to something suitable for clearing
                color: kwhite,
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
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: kgrey,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sentence.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: mainpurple,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: Text(
                          sentence[index],
                          style: const TextStyle(
                            color: kwhite,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    );
                  },
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
                      child: Text(
                        category,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: kwhite,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
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
                onCardTap: _speak,
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
    );
  }
}
