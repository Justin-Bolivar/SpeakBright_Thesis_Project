// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
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

Future<bool> isUserAGuardian(String? uid) async {
  CollectionReference userGuardianCollection =
      FirebaseFirestore.instance.collection('user_guardian');
  final DocumentSnapshot userDocument =
      await userGuardianCollection.doc(uid).get();

  return userDocument.exists && userDocument.get('userType') == 'guardian';
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    Future<bool> isGuardian =
        isUserAGuardian(AuthController.I.currentUser?.uid);
    print('home: $isGuardian');

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: FutureBuilder<bool>(
        // Pass the future to FutureBuilder
        future: isUserAGuardian(AuthController.I.currentUser?.uid),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          // Check if the future is resolved
          if (snapshot.connectionState == ConnectionState.done) {
            // Use snapshot.data to determine which layout to show
            if (snapshot.hasData && snapshot.data == true) {
              return const GuardianLayout();
            } else {
              return const StudentLayout();
            }
          } else {
            // Show a loading indicator while waiting for the future to complete
            return const CircularProgressIndicator();
          }
        },
      ),
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
