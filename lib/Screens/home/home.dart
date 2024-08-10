// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Screens/home/guardian_homepage.dart';
import 'package:speakbright_mobile/Screens/home/student_homepage.dart';
import '../auth/auth_controller.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  static const String route = "/";
  static const String path = "/";
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
      body: FutureBuilder<bool>(
        future: isUserAGuardian(AuthController.I.currentUser?.uid),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data == true) {
              return const GuardianHomepage();
            } else {
              return const StudentHomepage();
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}