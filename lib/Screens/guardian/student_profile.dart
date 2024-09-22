// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';

class StudentProfile extends ConsumerStatefulWidget {
  const StudentProfile({super.key});
  static const String route = "/StudentProfile";
  static const String path = "/StudentProfile";
  static const String name = "StudentProfile";

  @override
  // ignore: no_logic_in_create_state
  ConsumerState<StudentProfile> createState() =>
      _StudentProfileState();
}

class _StudentProfileState extends ConsumerState<StudentProfile> {

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final cardsAsyncValue = ref.watch(cardsGuardianProvider);
    return Scaffold(
        backgroundColor: kwhite,
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF8E2DE2), mainpurple],
              ),
            ),
          ),
          elevation: 5
        ),
        body: Column(
        )
        );
  }
}
