import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';
import 'dart:math';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});
  static const String route = '/home';
  static const String path = "/home";
  static const String name = "Dashboard";

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final FlutterTts flutterTts = FlutterTts();
  List<dynamic> voices = [];
  String selectedVoice = "";

  @override
  void initState() {
    super.initState();
    _getVoices();
  }

  Future<void> _getVoices() async {
    voices = await flutterTts.getVoices;
    if (voices.isNotEmpty) {
      // Filter voices to only include natural voices from the United States
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
    List<String> words = ["Charger", "Pencil", "Table", "Dice"];
     
      List<Color> boxcolors = [
      Colors.red,
      Colors.orange,
      const Color.fromARGB(255, 237, 195, 7),
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    List<double> containerHeights = List.generate(7, (index) => index*50 * 0.5 + 1);

    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Dashboard'),
        // ),
        backgroundColor: kwhite,
        body: SafeArea(
          child: Column(children: [
            // Expanded(
            //   flex: 1,
            //   child: Container(
            //     decoration: const BoxDecoration(
            //         color: mainpurple,
            //         borderRadius:
            //             BorderRadius.only(bottomLeft: Radius.circular(60))),
            //   ),
            // ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white, // Initial container is white
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60))),
              ),
            ),
            ...List.generate(6, (index) { // Generate the rainbow containers
              double height = containerHeights[index + 1]; // Skip the first index for the initial white container
              Color color = boxcolors[index]; // Cycle through colors starting from red
              return Container(
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
                ),
              );
            }),
            const SizedBox(
              height: 10,
            ),
            //cards area
            Expanded(
              flex: 5,
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
                                color:boxcolors[colorIndex],
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
