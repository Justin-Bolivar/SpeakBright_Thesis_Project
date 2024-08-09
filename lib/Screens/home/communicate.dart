// communicate.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/cards/card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';
import 'package:dotted_border/dotted_border.dart';

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
  List<String> categories = ['All'];
  int selectedCategory = -1;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _clearSentence() {
    setState(() {
      sentence.clear();
    });
  }

  Future<void> _fetchCategories() async {
    try {
      List<String> fetchedCategories =
          await _firestoreService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print(e);
    }
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
    final cardsAsyncValue = ref.watch(cardsStreamProvider);
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
                _firestoreService.storeSentence(sentence);
                _ttsService.speak(sentence.join(' '));
              },
              icon: const Icon(
                Icons.volume_up,
                color: kwhite,
              ),
            ),
            IconButton(
              onPressed: _clearSentence,
              icon: const Icon(
                Icons.delete_outline,
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
          Expanded(
            child: cardsAsyncValue.when(
              data: (cards) => CardGrid(
                cards: cards,
                onCardTap: _ttsService.speak,
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
