import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';

final studentIdProvider = StateProvider<String>((ref) => '');
final firestoreServiceProvider = Provider((ref) => FirestoreService());

final phaseProvider = StateNotifierProvider<PhaseNotifier, int>((ref) {
  return PhaseNotifier(ref.read(firestoreServiceProvider));
});

class PhaseNotifier extends StateNotifier<int> {
  final FirestoreService _firestoreService;

  PhaseNotifier(this._firestoreService) : super(1);

  void update(int value) {
    state = value;
  }

  Future<void> savePhase(String studentID) async {
    await _firestoreService.updateStudentPhase(studentID, state);
  }
}

final currentUserPhaseProvider = StateProvider<int>((ref) => 1);

final freqProvider = StateProvider<List<double>?>((ref) => []);

class FrequencyProvider extends ChangeNotifier {
  List<double>? _frequencies;
  String studentID;

  var ref;

  FrequencyProvider(this.ref) : studentID = ref.watch(studentIdProvider);

  Future<List<double>> get frequencies async {
    if (_frequencies != null) return _frequencies!;

    try {
      final frequenciesMap =
          await FirestoreService().getPromptFrequencies(studentID);

      List<double> frequenciesList = frequenciesMap.entries.map((entry) {
        int value = entry.value;
        if (value == 0) {
          return 0.0;
        }
        return ((value / frequenciesMap.values.reduce((a, b) => a + b)) * 100)
            .roundToDouble();
      }).toList();

      // Ensure the list has at least one element
      if (frequenciesList.isEmpty) {
        frequenciesList.add(0.0);
      }

      _frequencies = frequenciesList;
      print(_frequencies);
      notifyListeners();
      return frequenciesList;
    } catch (e) {
      print('Error calculating frequencies: $e');
      rethrow;
    }
  }
}
