// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class PlayCard extends StatefulWidget {
  final String cardId;
  final String? cardValue;

  const PlayCard({super.key, required this.cardId, required this.cardValue});

  @override
  _PlayCardState createState() => _PlayCardState();
}

class _PlayCardState extends State<PlayCard> {
  bool isFlipped = false;

  void flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flipCard,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.cardValue ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
