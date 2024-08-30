import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'explore_card_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


Future<List<dynamic>> fetchRecommendations(String userId) async {
  final url = Uri.parse('http://localhost:8000/recommendations/$userId');
  try {
    final response = await http.post(url);
    
    if (response.statusCode == 200) {
      return json.decode(response.body)['recommendations'];
    } else {
      throw Exception('Failed to load recommendations');
    }
  } catch (e) {
    print(e.toString());
    rethrow;
  }
}

class ExploreCardGrid extends StatefulWidget {
  final String userId;
  final List<CardModel> cards;
  final Function(String) onCardTap;

  const ExploreCardGrid({
    super.key,
    required this.userId,
    required this.cards,
    required this.onCardTap,
  });

  @override
  State<ExploreCardGrid> createState() => _ExploreCardGridState();
}

class _ExploreCardGridState extends State<ExploreCardGrid> {
  List<dynamic> recommendations = [];
  bool isLoading = false;

  void fetchAndFilterRecommendations() async {
  setState(() {
    isLoading = true;
  });

  try {
    Map<String, dynamic> response = (await fetchRecommendations(widget.userId)) as Map<String, dynamic>;

    List<dynamic> recommendations = response['recommendations']
        .map((doc) => CardModel.fromFirestore(doc))
          .toList();

    List<CardModel> nonRecommendedCards = widget.cards.where((card) => !recommendations.contains(card)).toList();

    setState(() {
      recommendations.addAll(nonRecommendedCards);
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching recommendations: $e');
    setState(() {
      isLoading = false;
    });
  }
}
  @override
  void initState() {
    super.initState();
    fetchAndFilterRecommendations();
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
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        CardModel card = recommendations[index];

        return ExploreCardItem(
          card: card,
          colorIndex: recommendations[index],
          onTap: () => widget.onCardTap(card.title),
        );
      },
    );
  }
}
