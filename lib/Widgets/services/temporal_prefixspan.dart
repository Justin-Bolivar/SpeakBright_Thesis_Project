import 'package:flutter/material.dart';

class TemporalPrefixSpan {
  List<List<Map<String, dynamic>>> sequenceDatabase;
  TemporalPrefixSpan({required this.sequenceDatabase});

  DateTime _convertToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  // Function to mine frequent sequences within an automatic time window (30 min before and after current time)
  List<String> mineFrequentSequences(int supportThreshold) {
    List<String> recommendedCards = [];

    final now = DateTime.now();

    for (var sequence in sequenceDatabase) {
      List<Map<String, dynamic>> filteredSequence = sequence.where((entry) {
        DateTime timestamp = entry['timestamp'].toDate();

        DateTime startDateTime = DateTime(
          timestamp.year,
          timestamp.month,
          timestamp.day,
          now.subtract(Duration(minutes: 30)).hour,
          now.subtract(Duration(minutes: 30)).minute,
        );

        DateTime endDateTime = DateTime(
          timestamp.year,
          timestamp.month,
          timestamp.day,
          now.add(Duration(minutes: 30)).hour,
          now.add(Duration(minutes: 30)).minute,
        );

        return timestamp.isAfter(startDateTime) &&
            timestamp.isBefore(endDateTime);
      }).toList();

      print('filteredSequence: ${filteredSequence}');

      if (filteredSequence.isNotEmpty) {
        // Get frequent cardIDs
        Map<String, int> cardFrequency = {};

        for (var entry in filteredSequence) {
          String cardID = entry['cardID'];
          if (!cardFrequency.containsKey(cardID)) {
            cardFrequency[cardID] = 0;
          }
          cardFrequency[cardID] = cardFrequency[cardID]! + 1;
        }

        // Check if cardFrequency meets the support threshold
        cardFrequency.forEach((cardID, frequency) {
          if (frequency >= supportThreshold) {
            recommendedCards.add(cardID);
          }
        });
      }
    }
    print('recommended cards: ${recommendedCards}');
    return recommendedCards;
  }
}
