import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';

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
        crossAxisCount: 2,
        crossAxisSpacing: 8.0, 
        mainAxisSpacing: 8.0, 
      ),
      padding: const EdgeInsets.all(16.0), 
      itemBuilder: (BuildContext context, int index) {
        final student = students[index];
        return InkWell(
          onTap: () => onStudentTap(student['userID']),
          child: Card(
            child: Padding( 
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    student['name'],
                    textAlign: TextAlign.center, 
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainpurple,
                    ),
                  ),
                  Text(
                    student['userID'],
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 10), 
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
