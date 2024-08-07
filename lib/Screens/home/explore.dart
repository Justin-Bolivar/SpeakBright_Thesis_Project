// Explore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:speakbright_mobile/Widgets/cards/explore_card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/card_provider.dart';

class Explore extends ConsumerStatefulWidget {
  const Explore({super.key});

  static const String route = "/explore";
  static const String path = "/explore";
  static const String name = "Explore";

  @override
  ConsumerState<Explore> createState() => _ExploreState();
}

class _ExploreState extends ConsumerState<Explore> {
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
              colors: [Color(0xFF8E2DE2), mainpurple], // Your gradient colors
            ),
          ),
        ),
        elevation: 5,
        title: const Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Explore",
                style: TextStyle(
                  color: kwhite,
                  fontSize: 20,
                ),
              ),
            ),
            Spacer(),
           
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8, top: 20),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/Binoculars.png',
                      height: 40,
                      width: 40,
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Discover Cards",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 24, color: kblack),
                        ),
                        Text(
                          "Explore new cards and tap on cards you want",
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
          
          Expanded(
            child: cardsAsyncValue.when(
              data: (cards) => ExploreCardGrid(
                cards: cards,
                onCardTap: _speak,
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
