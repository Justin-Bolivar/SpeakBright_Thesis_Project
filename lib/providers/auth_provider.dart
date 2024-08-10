import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Screens/auth/auth_controller.dart';

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) => AuthController());