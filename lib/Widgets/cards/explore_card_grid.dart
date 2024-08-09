import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

import 'explore_card_item.dart';

class ExploreCardGrid extends StatelessWidget {
  final List<CardModel> cards;
  final Function(String) onCardTap;

  const ExploreCardGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return ExploreCardItem(
          card: cards[index],
          colorIndex: index,
          onTap: () => onCardTap(cards[index].title),
        );
      },
    );
  }
}
