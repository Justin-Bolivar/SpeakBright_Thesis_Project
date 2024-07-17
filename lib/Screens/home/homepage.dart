// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:speakbright_mobile/Screens/home/addcard.dart';
import 'package:speakbright_mobile/Widgets/cards/card_grid.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';
import 'package:speakbright_mobile/Screens/home/header_container.dart';

class DashBoard extends ConsumerStatefulWidget {
  const DashBoard({super.key});

  static const String route = '/home';
  static const String path = "/home";
  static const String name = "Dashboard";

  @override
  ConsumerState<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends ConsumerState<DashBoard> {
  final FlutterTts flutterTts = FlutterTts();
  List<String> categories = ['Food', 'School', 'Clothing', 'Activities', 'Persons', 'Favourites', 'Places', 'Chores'];


  @override
  void initState() {
    super.initState();
    _setupTTS();
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

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsStreamProvider);
    return Scaffold(
      backgroundColor: kwhite,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddCardPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const RainbowContainer(),
            const SizedBox(height: 10),
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 56, 49, 70)
              ),
            ),
            const SizedBox(height: 10,),

            
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 10,),
            Expanded(
              flex: 3,
              child: cardsAsyncValue.when(
                data: (cards) => CardGrid(
                  cards: cards,
                  onCardTap: _speak,
                  onCardDelete: (String cardId) {
                    ref.read(cardProvider.notifier).deleteCard(cardId);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
