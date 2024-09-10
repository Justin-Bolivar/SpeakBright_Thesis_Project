import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'explore_card_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchRecommendations(String userId) async {
  final url = Uri.parse('https://speakbright-recommender-sys.onrender.com/recommendations/');
  try {
    print(userId);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['error'] != null) {
        throw Exception(jsonData['error']);
      }
      print('Raw response body: ${response.body}');
      return jsonData['recommendations'] ?? [];
    } else {
      throw Exception('Failed to load recommendations. Status code: ${response.statusCode}');
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
      List<dynamic> recommendationsData =
          await fetchRecommendations(widget.userId);

      // Check if the response contains the expected data structure
      if (recommendationsData.isNotEmpty) {
        // Cast each item in the list to Map<String, dynamic>
        List<Map<String, dynamic>> recommendationsMap =
            recommendationsData.map((e) => e as Map<String, dynamic>).toList();

        List recommendationTitles =
            recommendationsMap.map((rec) => rec['title']).toList();

        List<CardModel> allCards = widget.cards
            .where((card) =>
                recommendationTitles.contains(card.title) ||
                card.userId != widget.userId)
            .toList();

        setState(() {
          isLoading = false;
          recommendations = allCards;
        });
      } else {
        // Handle case where recommendations are empty
        print("Returned Empty Reco");
        List<CardModel> allCards =
            widget.cards.where((card) => card.userId != widget.userId).toList();
        setState(() {
          isLoading = false;
          recommendations = allCards;
        });
      }
    } catch (e) {
      print('Error fetching recommendations: $e');
      setState(() {
        isLoading = false;
        recommendations =
            widget.cards.where((card) => card.userId != widget.userId).toList();
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
          // colorIndex: recommendations[index],
          colorIndex: index % 7,
          onTap: () => widget.onCardTap(card.title),
        );
      },
    );
  }
}
