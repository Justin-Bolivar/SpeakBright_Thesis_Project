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
