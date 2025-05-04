// ignore_for_file: library_private_types_in_public_api

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
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _shuffleCards();
  }

  void _shuffleCards() {
    final random = Random();
    Set<CardModel> selectedCards = {};

    // Select cards based on the current level
    int numCards = _level + 1;
    while (selectedCards.length < numCards) {
      CardModel card = widget.cards[random.nextInt(widget.cards.length)];
      selectedCards.add(card);
    }

    // Create duplicates of each selected card
    _duplicatedCards = [];
    for (var card in selectedCards) {
      _duplicatedCards.addAll(List.filled(2, card));
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
    if (!_allowSelection || _revealedCards[index] || _matchedCards[index]) {
      return;
    }

    setState(() {
      _revealedCards[index] = true;
      _selectedCards.add(_duplicatedCards[index]);

      if (_selectedCards.length == 2) {
        _allowSelection = false;
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            // Check if both selected cards match
            bool allMatch = _selectedCards[0].id == _selectedCards[1].id;

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

            if (_allMatched) {
              _showEndLevelDialog();
            }
          });
        });
      }
    });
  }

  void _nextLevel() {
    setState(() {
      _level++;
      _shuffleCards();
    });
    Navigator.of(context).pop();
  }

  void _resetGame() {
    setState(() {
      _level = 1;
      _shuffleCards();
    });
    Navigator.of(context).pop();
  }

  void _showEndLevelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_level < 3 ? 'Level Complete!' : 'Congratulations!'),
          content: Text(_level < 3
              ? 'You have completed level $_level. Ready for the next level?'
              : 'You have completed all levels. Play again?'),
          actions: <Widget>[
            TextButton(
              onPressed: _level < 3 ? _nextLevel : _resetGame,
              child: Text(_level < 3 ? 'Next Level' : 'Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
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
    );
  }
}
