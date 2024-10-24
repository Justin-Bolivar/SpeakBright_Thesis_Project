import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WaitingDialog(),
      ),
    );
  }
}
