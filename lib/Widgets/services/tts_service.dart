// ignore_for_file: unrelated_type_equality_checks, avoid_print

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

  bool _isSpeaking = false; // Add a flag to track if TTS is speaking

  Future<void> speak(String text) async {
    if (!_isSpeaking) {
      // Check if TTS is not already speaking
      _isSpeaking = true; // Set the flag to true when speaking starts
      await setDefaultVoice();
      await _flutterTts.speak(text);

      // Wait until TTS finishes speaking
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false; // Reset the flag when speaking is finished
      });
    } else {
      print("TTS is still speaking. Please wait.");
    }
  }

  void stop() {
    _flutterTts.stop();
  }
}
