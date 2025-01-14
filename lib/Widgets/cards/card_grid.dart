import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_item.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';

class CardGrid extends StatelessWidget {
  final List<CardModel> cards;
  final Function(String, String, String) onCardTap;
  final Function(String) onCardDelete;
  final String selectedCategory;
  final int? phase;
  final bool isRecommended;

  const CardGrid({
    super.key,
    required this.cards,
    this.phase,
    required this.onCardTap,
    required this.onCardDelete,
    required this.selectedCategory,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    List<CardModel> filteredCards = cards.where((card) {

      

      if (phase == 2) {
        return card.phase1_independence == true && card.category != "Emotions";
      } else if (phase == 3) {
        return card.phase1_independence == true && card.category == "Emotions";
      } else if (phase == 4) {
        return card.phase2_independence == true &&
            card.phase3_independence == true;
      }

      if (selectedCategory != "All" && card.category != selectedCategory) {
        return false;
      }

      if (isRecommended) {
        return true; 
      }

      return true;
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
          onTap: () => onCardTap(
            filteredCards[index].title,
            filteredCards[index].category,
            filteredCards[index].id,
          ),
          onDelete: onCardDelete,
        );
      },
    );
  }
}
