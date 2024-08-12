import 'package:flutter/material.dart';

class StudentsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> students;

  const StudentsGrid({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: students.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
      ),
      itemBuilder: (BuildContext context, int index) {
        final student = students[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
              Text(student['userID'], style: const TextStyle(fontSize: 14)), 
            ],
          ),
        );
      },
    );
  }
}
