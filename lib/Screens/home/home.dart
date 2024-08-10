// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/auth_provider.dart';
import '../auth/auth_controller.dart';
import '../../Widgets/waiting_dialog.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  static const String route = "/h";
  static const String path = "/h";
  static const String name = "Home";

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider); 
    final isGuardian = authController.isGuardian; 

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: isGuardian ? const GuardianLayout() : const StudentLayout(),
    );
  }
}

class GuardianLayout extends StatelessWidget {
  const GuardianLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: Text('Welcome, Guardian!')),
        IconButton(
          icon: const Icon(Icons.logout, color: mainpurple, size: 20),
          onPressed: () {
            WaitingDialog.show(context, future: AuthController.I.logout());
          },
        ),
      ],
    );
  }
}

class StudentLayout extends StatelessWidget {
  const StudentLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: Text('Welcome, Student!')),
        IconButton(
          icon: const Icon(Icons.logout, color: mainpurple, size: 20),
          onPressed: () {
            WaitingDialog.show(context, future: AuthController.I.logout());
          },
        ),
      ],
    );
  }
}