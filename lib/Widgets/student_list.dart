// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Routing/router.dart';
import 'package:speakbright_mobile/Screens/guardian/student_profile.dart';
import 'package:speakbright_mobile/Screens/home/guardian_cardview.dart';
import 'package:speakbright_mobile/Widgets/studentsgrid.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';

class StudentList extends ConsumerStatefulWidget {
  const StudentList({super.key});

  static const String route = "/studentList";
  static const String path = "/studentList";
  static const String name = "Student List";

  @override
  ConsumerState<StudentList> createState() => _StudentListState();
}

class _StudentListState extends ConsumerState<StudentList> {
  late Future<List<Map<String, dynamic>>> studentsFuture;
  @override
  void initState() {
    super.initState();
    studentsFuture = getStudents();
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    User? guardian = FirebaseAuth.instance.currentUser;
    if (guardian == null) {
      throw Exception('No user is currently signed in.');
    }
    String guardianUid = guardian.uid;
    print(guardianUid);

    final studentsRef = FirebaseFirestore.instance
        .collection('user_guardian')
        .doc(guardianUid)
        .collection('students');

    final snapshots = await studentsRef.get();
    return snapshots.docs.map((doc) => doc.data()).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: studentsFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return StudentsGrid(
              students: snapshot.data!,
              onStudentTap: (studentID) {
                ref.read(studentIdProvider.notifier).state = studentID;
                GlobalRouter.I.router.push(StudentProfile.route);
              },
            );
          }
        },
    );
  }
}
