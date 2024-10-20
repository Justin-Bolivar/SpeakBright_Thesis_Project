import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_item.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class CardList extends StatelessWidget {
  final List<CardModel> cards;
  final Function(String, String, String) onCardTap;
  final Function(String) onCardDelete;
  final String selectedCategory;

  const CardList({
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

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CardItem(
            card: filteredCards[index],
            colorIndex: index,
            onTap: () => onCardTap(filteredCards[index].title,
                filteredCards[index].category, filteredCards[index].id),
            onDelete: onCardDelete,
          ),
        );
      },
    );
  }
}
