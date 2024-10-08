import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_item.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class CardGrid extends StatelessWidget {
  final List<CardModel> cards;
  final Function(String, String, String) onCardTap;
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

    if (filteredCards.isEmpty) {
      return const Center(
        child: Text(
          'No cards available',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        return CardItem(
          card: filteredCards[index],
          colorIndex: index,
          onTap: () => onCardTap(filteredCards[index].title,
              filteredCards[index].category, filteredCards[index].id),
          onDelete: onCardDelete,
        );
      },
    );
  }
}
