import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:speakbright_mobile/Widgets/cards/card_game_item.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class CardGameGrid extends StatefulWidget {
  final List<CardModel> cards;
  final Function(String, String, String) onCardTap;

  const CardGameGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
  });

  @override
  _CardGameGridState createState() => _CardGameGridState();
}

class _CardGameGridState extends State<CardGameGrid> {
  final List<CardModel> _selectedCards = [];
  late List<CardModel> _duplicatedCards;
  final List<bool> _revealedCards = [];
  final List<bool> _matchedCards = [];
  bool _allowSelection = true;
  bool _allMatched = false;

  @override
  void initState() {
    super.initState();
    _shuffleCards();
  }

  void _shuffleCards() {
    final random = Random();
    Set<CardModel> selectedCards = {};

    // Ensure we get 3 unique cards
    while (selectedCards.length < 3) {
      CardModel card = widget.cards[random.nextInt(widget.cards.length)];
      selectedCards.add(card);
    }

    // Create 3 copies of each unique card
    _duplicatedCards = [];
    for (var card in selectedCards) {
      _duplicatedCards.addAll(List.filled(3, card));
    }

    // Shuffle the list of duplicated cards
    _duplicatedCards.shuffle();

    // Initialize the revealed and matched state for each card
    _revealedCards.clear();
    _revealedCards.addAll(List<bool>.filled(_duplicatedCards.length, false));
    _matchedCards.clear();
    _matchedCards.addAll(List<bool>.filled(_duplicatedCards.length, false));
    _allMatched = false;
  }

  void _onCardTap(int index) {
    if (!_allowSelection || _revealedCards[index] || _matchedCards[index])
      return;

    setState(() {
      _revealedCards[index] = true;
      _selectedCards.add(_duplicatedCards[index]);

      if (_selectedCards.length == 3) {
        _allowSelection = false;
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            // Check if ALL three selected cards match
            bool allMatch = _selectedCards[0].id == _selectedCards[1].id &&
                _selectedCards[1].id == _selectedCards[2].id;

            if (allMatch) {
              Confetti.launch(context,
                  options: const ConfettiOptions(
                      particleCount: 400, spread: 70, y: 0.6));
              // Mark matched cards
              for (int i = 0; i < _duplicatedCards.length; i++) {
                if (_selectedCards.contains(_duplicatedCards[i])) {
                  _matchedCards[i] = true;
                }
              }
              // Check if all cards are matched
              _allMatched = _matchedCards.every((matched) => matched);
            } else {
              // Hide all non-matched cards
              for (int i = 0; i < _duplicatedCards.length; i++) {
                if (_selectedCards.contains(_duplicatedCards[i])) {
                  _revealedCards[i] = false;
                }
              }
            }

            // Reset selection
            _selectedCards.clear();
            _allowSelection = true;
          });
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      _shuffleCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: _duplicatedCards.length,
          itemBuilder: (context, index) {
            return CardGameItem(
              card: _duplicatedCards[index],
              colorIndex: index,
              revealed: _revealedCards[index] || _matchedCards[index],
              onTap: () => _onCardTap(index),
            );
          },
        ),
        if (_allMatched)
          Center(
            child: ElevatedButton(
              onPressed: _resetGame,
              child: Text('Play Again'),
            ),
          ),
      ],
    );
  }
}
