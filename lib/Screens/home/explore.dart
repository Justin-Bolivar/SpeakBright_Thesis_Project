import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/cards/explore_card_grid.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/tts_service.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
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
  final TTSService _ttsService = TTSService();
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _ttsService.setupTTS();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsyncValue = ref.watch(cardsExploreProvider);
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
          Expanded(
            child: cardsAsyncValue.when(
              data: (cards) => ExploreCardGrid(
                userId: uid ?? '', //cause uid is String? userId is String
                cards: cards,
                onCardTap: _ttsService.speak,
              ),
              loading: () => const Center(child: WaitingDialog()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
