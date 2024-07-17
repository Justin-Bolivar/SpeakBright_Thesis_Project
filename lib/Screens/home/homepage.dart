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
  List<String> categories = ['All','Toys','Food', 'School', 'Clothing', 'Activities', 'Persons', 'Favourites', 'Places', 'Chores'];
  int selectedCategory = -1;


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

            const Row(
              children: [
                 Padding(
                  padding: EdgeInsets.only(left: 20,bottom: 5),
                   child: Text(
                    "CATEGORIES",
                    textAlign: TextAlign.left, // This should align the text to the left
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 130, 113, 164)
                    ),
                                   ),
                 ),
                Spacer()
              ],
            ),

            const SizedBox(height: 8),
            

          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 35, // Minimum height
              maxHeight: 35, // Maximum height
            ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  // Calculate the color index for the current item
                  int colorIndex = index % boxColors.length;
                  // Set the background color based on the calculated color index
                  Color itemColor = boxColors[colorIndex];

                  bool isSelected = selectedCategory == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = index; // Update the selected index
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
                                    offset: Offset(0, 1), // changes position of shadow
                                  ),
                                ]
                              : [], // No shadow if not selected
                        ),
                        child: Text(
                          category,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kwhite, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            
          ),

            
            Container(
              height: 10,
              color: Colors.transparent,
            ),
            Expanded(
              flex: 3,
              child: cardsAsyncValue.when(
                data: (cards) => CardGrid(
                  cards: cards,
                  onCardTap: _speak,
                  onCardDelete: (String cardId) {
                    ref.read(cardProvider.notifier).deleteCard(cardId);
                  },
                  selectedCategory: selectedCategory == -1 ? "All" : categories[selectedCategory],
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
