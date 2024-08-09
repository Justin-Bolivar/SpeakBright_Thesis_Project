// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  TTSService() {
    setupTTS();
  }

  Future<void> setupTTS() async {
    await _flutterTts.setLanguage("en-US");
    await setDefaultVoice();
  }

  Future<void> setDefaultVoice() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    String voiceName = connectivityResult != ConnectivityResult.none
        ? "Microsoft Aria Online (Natural) - English (United States)"
        : "Microsoft Zira - English (United States)";

    await _flutterTts.setVoice({"name": voiceName, "locale": "en-US"});
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await setDefaultVoice();
    await _flutterTts.speak(text);
  }

  void stop() {
    _flutterTts.stop();
  }
}
