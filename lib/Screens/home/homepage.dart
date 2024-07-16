import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});
  static const String route = '/home';
  static const String path = "/home";
  static const String name = "Dashboard";

  @override
  // ignore: library_private_types_in_public_api
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final FlutterTts flutterTts = FlutterTts();
  List<dynamic> voices = [];
  String selectedVoice = "";
  List<String> words = [];

  @override
  void initState() {
    super.initState();
    _getVoices();
    _fetchCards();
  }

  Future<void> _getVoices() async {
    voices = await flutterTts.getVoices;
    if (voices.isNotEmpty) {
      voices = voices.where((voice) {
        String locale = voice['locale'] ?? '';
        String name = voice['name'] ?? '';
        return locale.toLowerCase().contains('us') &&
            !name.toLowerCase().contains('network') &&
            !name.toLowerCase().contains('neural');
      }).toList();

      setState(() {
        if (voices.isNotEmpty) {
          selectedVoice = voices[0]["name"];
        }
      });
    }
  }

  Future<void> _fetchCards() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('cards').get();
      setState(() {
        words =
            querySnapshot.docs.map((doc) => doc['Title'] as String).toList();
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching cards: $e');
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVoice({"name": selectedVoice, "locale": "en-US"});
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> boxcolors = [
      Colors.red,
      Colors.orange,
      const Color.fromARGB(255, 237, 195, 7),
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    return Scaffold(
        backgroundColor: kwhite,
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: Stack(children: [
                Container(
                  height: 115,
                  decoration: BoxDecoration(
                    color: boxcolors[0],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
                  ),
                ),
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: boxcolors[1],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
                  ),
                ),
                Container(
                  height: 105,
                  decoration: BoxDecoration(
                    color: boxcolors[2],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
                  ),
                ),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: boxcolors[3],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
                  ),
                ),
                Container(
                  height: 95,
                  decoration: BoxDecoration(
                    color: boxcolors[4],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
                  ),
                ),
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: boxcolors[5],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
                  ),
                ),
                Container(
                  height: 85,
                  decoration: BoxDecoration(
                    color: boxcolors[6],
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
                  ),
                ),
                Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: kwhite,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                          bottomRight: Radius.circular(100)),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Text(
                            "HI DONNA!",
                          )
                        ],
                      ),
                    )),
              ]),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 3,
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25.0,
                  mainAxisSpacing: 25.0,
                ),
                itemCount: words.length,
                itemBuilder: (context, index) {
                  int colorIndex = index % boxcolors.length;
                  return GestureDetector(
                    onTap: () {
                      _speak(words[index]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: kwhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 1,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(100),
                                  ),
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  color: boxcolors[colorIndex],
                                  size: 40,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: Text(
                              words[index],
                              style: TextStyle(
                                color: boxcolors[colorIndex],
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedVoice,
                items: voices.map<DropdownMenuItem<String>>((dynamic voice) {
                  return DropdownMenuItem<String>(
                    value: voice["name"],
                    child: Text(voice["name"]),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedVoice = newValue!;
                  });
                },
                isExpanded: true,
              ),
            ),
          ]),
        ));
  }
}
