import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speakbright_mobile/Widgets/services/card_transition.dart';

class TemporalPrefixSpan {
  List<List<Map<String, dynamic>>> sequenceDatabase;
  TemporalPrefixSpan({required this.sequenceDatabase});

  Future<List<String>> mineFrequentSequences() async {
    print('ENTERED MINE FREQ SEQ');
    List<String> recommendedCards = [];
    final now = DateTime.now();
    final totalSequences = sequenceDatabase.length;
    double supportThreshold;
    final box = await Hive.openBox<CardTransition>('cardTransitions');

    if (totalSequences < 5) {
      supportThreshold = 1.0;
    } else if (totalSequences < 10) {
      supportThreshold = 0.6;
    } else {
      supportThreshold = 0.5;
    }

    print('min support: $supportThreshold');

    // Store sequences of cardIDs (to detect patterns) separated by day
    List<List<String>> dailySequencePatterns = [];

    // Group sequences by day
    Map<String, List<Map<String, dynamic>>> sequencesByDay = {};

    // Group all sequences by their respective days
    for (var sequence in sequenceDatabase) {
      for (var entry in sequence) {
        DateTime timestamp = entry['timestamp'].toDate();
        String dayKey =
            timestamp.toLocal().toString().split(' ')[0]; // Format: YYYY-MM-DD

        if (!sequencesByDay.containsKey(dayKey)) {
          sequencesByDay[dayKey] = [];
        }
        sequencesByDay[dayKey]!.add(entry);
      }
    }
    print("sequenceDatabase: $sequenceDatabase");

    // Process each day's sequences, applying the 30-minute filter
    sequencesByDay.forEach((dayKey, daySequences) {
      List<Map<String, dynamic>> filteredSequence = daySequences.where((entry) {
        DateTime timestamp = entry['timestamp'].toDate();
        DateTime testTime = DateTime(2025, 4, 20, 17, 00);
        DateTime startDateTime = DateTime(
          timestamp.year,
          timestamp.month,
          timestamp.day,
          testTime.subtract(Duration(minutes: 30)).hour,
          testTime.subtract(Duration(minutes: 30)).minute,
        );

        DateTime endDateTime = DateTime(
          timestamp.year,
          timestamp.month,
          timestamp.day,
          testTime.add(Duration(minutes: 30)).hour,
          testTime.add(Duration(minutes: 30)).minute,
        );

        return timestamp.isAfter(startDateTime) &&
            timestamp.isBefore(endDateTime);
      }).toList();

      if (filteredSequence.isNotEmpty) {
        // Extract the list of cardIDs in order for this day
        List<String> cardSequence = [];
        List<String> cardSequenceName = [];

        for (var entry in filteredSequence) {
          cardSequence.add(entry['cardID']);
          cardSequenceName.add(entry['cardTitle']);
        }
        print('koala Let 𝑆 = {$cardSequenceName}');
        // Add this sequence for this day to our list
        dailySequencePatterns.add(cardSequence);
      }
    });

    // Now let's calculate the support for each sequence (card patterns)
    Map<String, int> sequenceSupport = {};

    // Count how often each sequential pattern (pair of cards) appears
    for (var sequence in dailySequencePatterns) {
      for (int i = 0; i < sequence.length - 1; i++) {
        // Create sequential patterns (e.g., Milk → Cookie)
        String pattern = '${sequence[i]} → ${sequence[i + 1]}';

        if (!sequenceSupport.containsKey(pattern)) {
          sequenceSupport[pattern] = 0;
        }
        sequenceSupport[pattern] = sequenceSupport[pattern]! + 1;
      }
    }

    // Now calculate support and recommend patterns based on threshold
    for (var entry in sequenceSupport.entries) {
      String pattern = entry.key;
      int patternSupportCount = entry.value;

      // Calculate the support as the fraction of total sequences
      double support = patternSupportCount / totalSequences;
      bool passed = support >= supportThreshold;
      print('seq (card ID): $entry | support: $support | passed: $passed');
      print(entry);

      if (passed) {
        recommendedCards.add(pattern);

        // Split the pattern back into fromCard and toCard
        final parts = pattern.split(' → ');
        if (parts.length == 2) {
          final fromCard = parts[0];
          final toCard = parts[1];

          final transition = CardTransition(fromCard: fromCard, toCard: toCard);

          // Add to Hive box
          box.add(transition);
        }
        // print('Box length: ${box.length}');
        // for (var item in box.values) {
        //   print('fromCard: ${item.fromCard}, toCard: ${item.toCard}');
        // }
      }
    }  

    print('RECOMMENDED CARDS IN SEQUENCE: $recommendedCards');
    return arrangeCardsInSequence(recommendedCards);
  }
}

List<String> arrangeCardsInSequence(List<String> recommendedCards) {
  List<String> arrangedCards = [];

  // Iterate through each recommended card sequence
  for (String cardSequence in recommendedCards) {
    // Split the sequence by the arrow symbol to extract individual card IDs
    List<String> cards = cardSequence.split(' → ');

    // Add each card to the arrangedCards list if it hasn't been added already
    for (String card in cards) {
      if (!arrangedCards.contains(card)) {
        arrangedCards.add(card);
      }
    }
  }

  print('RECOMMENDED CARDS: $arrangedCards');
  return arrangedCards;
}
