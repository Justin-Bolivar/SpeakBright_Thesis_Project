import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentIdProvider = StateProvider<String>((ref) => '');
final currentUserPhaseProvider = StateProvider<int>((ref) => 1);
