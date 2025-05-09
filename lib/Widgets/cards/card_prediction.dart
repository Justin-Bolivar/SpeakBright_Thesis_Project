// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';

class PhasePredictions extends StatefulWidget {
  final String studentID;

  const PhasePredictions({super.key, required this.studentID});

  @override
  State<PhasePredictions> createState() => _PhasePredictionsState();
}

class _PhasePredictionsState extends State<PhasePredictions> {
  late Future<List<PhaseData>?> _phaseDataFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _phaseDataFuture = _fetchPhasePredictions();
  }

  Future<List<PhaseData>?> _fetchPhasePredictions() async {
    var url = Uri.parse(
        'https://speakbright-dataanalysis.onrender.com/ema-mobile/${widget.studentID}');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<PhaseData> phases = [];

        for (var phase in jsonResponse) {
          // Fetch completion percentage for this phase
          double completion =
              await _getPhaseCompletion(phase['phase'], widget.studentID);

          phases.add(PhaseData(
            phase: phase['phase'],
            predictedString: '---',
            //predictedString: phase['predictedString'],
            completionPercentage: completion,
          ));
        }

        // Sort phases in ascending order
        phases.sort((a, b) => a.phase.compareTo(b.phase));

        return phases;
      } else {
        print('Failed to load predictions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching predictions: $e');
      return null;
    }
  }

  Future<double> _getPhaseCompletion(int phase, String studentID) async {
    // Call the appropriate function based on phase number
    switch (phase) {
      case 1:
        return await _firestoreService.calculatePhase1Completion(studentID);
      case 2:
        return await _firestoreService.calculatePhase2Completion(studentID);
      case 3:
        return await _firestoreService.calculatePhase3Completion(studentID);
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PhaseData>?>(
      future: _phaseDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No prediction data available'));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                const SizedBox(width: 16), // Left padding
                ...snapshot.data!
                    .map((phaseData) => _buildPhaseCard(phaseData)),
                const SizedBox(width: 16), // Right padding
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhaseCard(PhaseData phaseData) {
    // Handle potential infinity or NaN values - limit to valid range
    final percentage = phaseData.completionPercentage.isFinite &&
            !phaseData.completionPercentage.isNaN
        ? phaseData.completionPercentage.clamp(0.0, 100.0)
        : 0.0;

    // Calculate the safe progress value (0.0 to 1.0)
    final progressValue = percentage / 100;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Phase ${phaseData.phase}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Progress indicator section - with fixed height container
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        percentage.isFinite
                            ? '${percentage.toStringAsFixed(1)}%'
                            : '0.0%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Wrap the progress indicator in a fixed height container
                  SizedBox(
                    height: 8, // Fixed height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue.isFinite ? progressValue : 0.0,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(percentage),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Estimated completion:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phaseData.predictedString,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to determine progress bar color based on completion percentage
  Color _getProgressColor(double percentage) {
    if (percentage < 30) {
      return Colors.redAccent;
    } else if (percentage < 70) {
      return Colors.orangeAccent;
    } else {
      return Colors.greenAccent;
    }
  }
}

class PhaseData {
  final int phase;
  final String predictedString;
  final double completionPercentage;

  PhaseData({
    required this.phase,
    required this.predictedString,
    this.completionPercentage = 0.0,
  });
}
