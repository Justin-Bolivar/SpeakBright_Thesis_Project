// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Screens/home/header_container.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const String route = "/home";
  static const String path = "/home";
  static const String name = "HomePage";

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FlutterTts flutterTts = FlutterTts();
  final intro = "You have selected";
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
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  // Calculate relative font sizes and image heights based on screen width
  double baseFontSize = screenWidth * 0.03; // Base font size as 3% of the screen width
  double imageHeight = screenWidth * 0.2; // Image height as 20% of the screen width

  return Scaffold(
    backgroundColor: kwhite,
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: screenHeight * 0.2,
                child: const RainbowContainer(),
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: SizedBox(
              width: screenWidth * 0.85, 
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 15, 25, 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  'Communicate',
                                  'Explore',
                                  'Play a Game',
                                  'Test'
                                ][index],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: baseFontSize),
                              ),
                              Text(
                                [
                                  'Tap on cards you want',
                                  'Discover new cards',
                                  'Enjoy learning',
                                  'Let’s test what you know'
                                ][index],
                                style: TextStyle(fontSize: baseFontSize * 0.8), // Smaller relative font size
                              ),
                            ],
                          ),
                          Image.asset(
                              [
                                'assets/communicate.png',
                                'assets/train.png',
                                'assets/play.png',
                                'assets/test_books.png'
                              ][index],
                              height: imageHeight,
                              fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
