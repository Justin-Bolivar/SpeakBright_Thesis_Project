import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WaitingDialog(),
      ),
    );
  }
}
