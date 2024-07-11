import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter text to speak',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _speak(_textController.text);
            },
            child: const Text('Speak'),
          ),
        ],
      ),
    );
  }
}
