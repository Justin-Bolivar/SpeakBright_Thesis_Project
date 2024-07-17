import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_item.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class CardGrid extends StatelessWidget {
  final List<CardModel> cards;
  final Function(String) onCardTap;
  final Function(String) onCardDelete;

  const CardGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
    required this.onCardDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 25.0,
        mainAxisSpacing: 25.0,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return CardItem(
          card: cards[index],
          colorIndex: index,
          onTap: () => onCardTap(cards[index].title),
          onDelete: () => onCardDelete(cards[index].id),
        );
      },
    );
  }
}
