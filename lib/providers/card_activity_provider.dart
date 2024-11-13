import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final cardActivityProvider = ChangeNotifierProvider<CardActivityProvider>((ref) {
  return CardActivityProvider();
});

class CardActivityProvider extends ChangeNotifier {
  String? _cardId;
  bool _showDistractor = false;

  String? get cardId => _cardId;
  bool get showDistractor => _showDistractor;

  // Update card ID
  void setCardId(String? cardId) {
    _cardId = cardId;
    notifyListeners();
  }

  // Update distractor status
  void setShowDistractor(bool value) {
    _showDistractor = value;
    notifyListeners();
  }

  // Reset values if needed
  void reset() {
    _cardId = null;
    _showDistractor = false;
    notifyListeners();
  }
}
