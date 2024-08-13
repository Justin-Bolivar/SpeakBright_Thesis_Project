import 'package:flutter/material.dart';

class StudentsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final Function(String) onStudentTap;
  // final WidgetRef ref;

  const StudentsGrid({
    super.key,
    required this.students,
    required this.onStudentTap,
    // required this.ref,
  });


  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: students.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
      ),
      itemBuilder: (BuildContext context, int index) {
        final student = students[index];
        return InkWell(
          // Wrap the Card with InkWell to detect taps
          onTap: () => onStudentTap(student['userID']),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(student['userID'], style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }
}
