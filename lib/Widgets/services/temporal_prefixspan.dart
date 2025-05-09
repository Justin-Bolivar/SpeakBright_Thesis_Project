// ignore_for_file: unused_element, avoid_print

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speakbright_mobile/Widgets/services/card_transition.dart';

class TemporalPrefixSpan {
  List<List<Map<String, dynamic>>> sequenceDatabase;
  TemporalPrefixSpan({required this.sequenceDatabase});

  List<List<String>> splitIntoSessions(
      List<Map<String, dynamic>> filteredSequence) {
    List<List<String>> sessions = [];
    List<String> currentSession = [];

    for (int i = 0; i < filteredSequence.length; i++) {
      final cardId = filteredSequence[i]['cardID'];
      final timestamp = filteredSequence[i]['timestamp'].toDate();

      if (i == 0) {
        currentSession.add(cardId);
      } else {
        final previousTimestamp = filteredSequence[i - 1]['timestamp'].toDate();
        final gap = timestamp.difference(previousTimestamp);

        if (gap.inMinutes > 10) {
          if (currentSession.isNotEmpty) sessions.add(currentSession);
          currentSession = [cardId];
        } else {
          currentSession.add(cardId);
        }
      }
    }

    if (currentSession.isNotEmpty) sessions.add(currentSession);

    return sessions;
  }

  bool _passesSoftConstraints(
      List<String> pattern, List<String> requiredItems) {
    for (var item in requiredItems) {
      if (!pattern.contains(item)) return false;
    }
    return true;
  }

//minePrefixSpanPatterns

  List<List<String>> constraintOptimizedPrefixSpan(
    List<List<String>> sessions,
    double supportThreshold, {
    int minSequenceSize = 2,
    int maxSequenceSize = 5,
    List<String> softInclusionConstraints = const [],
  }) {
    final totalSessions = sessions.length;
    final List<List<String>> minedPatterns = [];
    final Map<String, int> prefixCount = {};

    void prefixSpan(
        List<List<String>> projectedDB, List<String> currentPrefix) {
      final Map<String, int> itemSupport = {};

      for (var sequence in projectedDB) {
        final seen = <String>{};
        for (var item in sequence) {
          if (seen.add(item)) {
            itemSupport[item] = (itemSupport[item] ?? 0) + 1;
          }
        }
      }

      final sortedItems = itemSupport.entries
          .where((e) => e.value / totalSessions >= supportThreshold)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final prefixKey = currentPrefix.join(',');
      prefixCount[prefixKey] = prefixCount[prefixKey] ?? 0;

      for (var entry in sortedItems) {
        if (prefixCount[prefixKey]! >= 5) break;

        final item = entry.key;
        final newPrefix = [...currentPrefix, item];

        // ✅ Depth pruning
        if (newPrefix.length > maxSequenceSize) continue;

        // ✅ Soft inclusion constraint pruning
        if (!_passesSoftConstraints(newPrefix, softInclusionConstraints))
          continue;

        // ✅ Early pruning: only add valid patterns
        if (newPrefix.length >= minSequenceSize) {
          minedPatterns.add(newPrefix);
          final support = entry.value / totalSessions;
          print('Pattern: ${newPrefix.join(' → ')} '
              '(support: ${(support * 100).toStringAsFixed(1)}%)');
        }

        prefixCount[prefixKey] = prefixCount[prefixKey]! + 1;

        // Project DB for next recursion
        final newProjectedDB = <List<String>>[];
        for (var sequence in projectedDB) {
          final index = sequence.indexOf(item);
          if (index != -1 && index + 1 < sequence.length) {
            newProjectedDB.add(sequence.sublist(index + 1));
          }
        }

        if (newProjectedDB.isNotEmpty) {
          prefixSpan(newProjectedDB, newPrefix);
        }
      }
    }

    prefixSpan(sessions, []);
    return minedPatterns;
  }

  bool isSubsequence(List<String> sequence, List<String> pattern) {
    int seqIndex = 0, patIndex = 0;

    while (seqIndex < sequence.length && patIndex < pattern.length) {
      if (sequence[seqIndex] == pattern[patIndex]) {
        patIndex++;
      }
      seqIndex++;
    }

    return patIndex == pattern.length;
  }

  void checkPatternSupport(
    List<List<String>> sessions,
    List<List<String>> patterns,
  ) {
    for (var pattern in patterns) {
      int supportCount = 0;
      List<int> supportingSessionIndexes = [];

      for (int i = 0; i < sessions.length; i++) {
        final session = sessions[i];
        if (isSubsequence(session, pattern)) {
          supportCount++;
          supportingSessionIndexes.add(i + 1);
        }
      }

      double support = supportCount / sessions.length;
      print(
          'Pattern $pattern is supported by sessions $supportingSessionIndexes '
          '(support: ${(support * 100).toStringAsFixed(1)}%)');
    }
  }

  Future<List<String>> mineFrequentSequences() async {
    print('ENTERED MINE FREQ SEQ');
    List<String> recommendedCards = [];
    final now = DateTime.now();
    final totalSequences = sequenceDatabase.length;
    double supportThreshold;
    List<List<String>> patterns = [];
    // final box = await Hive.openBox<CardTransition>('cardTransitions');

    // if (totalSequences < 5) {
    //   supportThreshold = 1.0;
    // } else if (totalSequences < 10) {
    //   supportThreshold = 0.6;
    // } else {
    //   supportThreshold = 0.5;
    // }
    supportThreshold = 0.3;

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
      List<List<String>> sessions = [];

      if (filteredSequence.isNotEmpty) {
        // Split the filtered sequence into sessions
        sessions = splitIntoSessions(filteredSequence);

        // For each session, create a sequence of card IDs
        for (var session in sessions) {
          if (session.length >= 2) {
            // Convert cardIDs in session to cardTitles using filteredSequence
            List<String> cardTitlesInSession = session.map((cardID) {
              final entry = filteredSequence.firstWhere(
                (e) => e['cardID'] == cardID,
                orElse: () => {'cardTitle': 'Unknown'},
              );
              return entry['cardTitle'] as String;
            }).toList();

            print('Let 𝑆 = {$cardTitlesInSession}');
            dailySequencePatterns.add(session);
          }
        }

        List<List<String>> patterns =
            constraintOptimizedPrefixSpan(sessions, 0.5);
        // checkPatternSupport(sessions, patterns);

        // Get the last 3 unique tapped cards---------
        List<Map<String, dynamic>> allEntries = [];

        for (var sequence in sequenceDatabase) {
          allEntries.addAll(sequence);
        }

        // Sort all entries by timestamp in descending order
        allEntries.sort((a, b) =>
            b['timestamp'].toDate().compareTo(a['timestamp'].toDate()));

// Group entries by day
        Map<String, List<Map<String, dynamic>>> entriesByDay = {};

        for (var entry in allEntries) {
          DateTime timestamp = entry['timestamp'].toDate();
          String dayKey = timestamp
              .toLocal()
              .toString()
              .split(' ')[0]; // Format: YYYY-MM-DD

          if (!entriesByDay.containsKey(dayKey)) {
            entriesByDay[dayKey] = [];
          }

          entriesByDay[dayKey]!.add(entry);
        }

// Get the most recent day (latest date)
        String mostRecentDay = entriesByDay.keys.first;

// Sort entries of the most recent day by timestamp in ascending order to get the earliest card
        entriesByDay[mostRecentDay]!.sort((a, b) =>
            a['timestamp'].toDate().compareTo(b['timestamp'].toDate()));

// Get the earliest card from the most recent day
        final recentCard = <String>{};
        final lastCard = <String>[];

        lastCard.add(entriesByDay[mostRecentDay]!.first['cardID']);
        recentCard.add(entriesByDay[mostRecentDay]!.first['cardID']);

        print('Earliest card from the most recent day: $recentCard');

        Map<String, String> cardIdToTitle = {};

        for (var sequence in sequenceDatabase) {
          for (var entry in sequence) {
            final id = entry['cardID'];
            final title = entry['cardTitle'];
            if (id != null && title != null) {
              cardIdToTitle[id] = title;
            }
          }
        }

        for (final pattern in patterns) {
          final readablePattern =
              pattern.map((id) => cardIdToTitle[id] ?? id).toList();
          print('Mined Pattern: ${readablePattern.join(' -> ')}');
        }
        

        String lastTappedCardID = 'fcVqJJlsNHYqeP65P4iK';

        for (var pattern in patterns) {
          // Ensure that the pattern is long enough to proceed
          if (pattern.length <= lastCard.length) continue;

          // Check if the 'lastTappedCardID' is part of the sequence
          bool matchesPrefix = true;

          // Loop through the last tapped cards and check for matching sequence
          for (int i = 0; i < lastCard.length; i++) {
            if (pattern[i] != lastTappedCardID) {
              matchesPrefix = false;
              break;
            }
            print("Pattern: ${pattern[i]} | Recent: $lastTappedCardID");
          }

          // If a match is found, recommend the next card
          if (matchesPrefix) {
            // Get the next card in the sequence
            String nextCard = pattern[lastCard.length];

            // Check if the next card is available and recommend it
            if (!recommendedCards.contains(nextCard)) {
              recommendedCards.add(nextCard);
              print('Matched pattern: $pattern => Recommend: $nextCard');
            }
          }
        }
      }
    });

    print('RECOMMENDED CARDS IN SEQUENCE: $recommendedCards');
    return recommendedCards;
    // return arrangeCardsInSequence(recommendedCards);
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
