import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_item.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class CardGrid extends StatelessWidget {
  final List<CardModel> cards;
  final Function(String) onCardTap;
  final Function(String) onCardDelete;
  final String selectedCategory; 

  const CardGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
    required this.onCardDelete,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    List<CardModel> filteredCards = cards.where((card) {
      if (selectedCategory == "All") return true;
      return card.category == selectedCategory;
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 25.0,
        mainAxisSpacing: 25.0,
      ),
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        return CardItem(
          card: filteredCards[index],
          colorIndex: index,
          onTap: () => onCardTap(filteredCards[index].title),
          onDelete: onCardDelete,
        );
      },
    );
  }
}
