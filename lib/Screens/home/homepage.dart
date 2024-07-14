import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: words.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _speak(words[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        words[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
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
        ],
      ),
    );
  }
}
