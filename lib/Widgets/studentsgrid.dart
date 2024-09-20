import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      padding: const EdgeInsets.all(20.0),
      itemBuilder: (BuildContext context, int index) {
        final student = students[index];
        BoxDecoration getCardDecoration(int index) {
          final colors = <Color>[
            const Color.fromARGB(255, 202, 160, 255),
            _getColorByIndex(index).withOpacity(0.5)
          ];

          return BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          );
        }

        return InkWell(
          onTap: () => onStudentTap(student['userID']),
          child: Container(
            decoration: getCardDecoration(index),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/${_getImagePath(index)}.png',
                    height: MediaQuery.of(context).size.width * 0.14,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    student['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    student['userID'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Color.fromARGB(218, 255, 255, 255)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorByIndex(int index) {
    switch (index % 6) {
      case 0:
        return const Color.fromARGB(255, 235, 58, 58);
      case 1:
        return const Color.fromARGB(255, 249, 128, 41);
      case 2:
        return const Color.fromARGB(255, 231, 163, 33);
      case 3:
        return const Color.fromARGB(255, 68, 163, 67);
      case 4:
        return const Color.fromARGB(255,58, 150, 235);
      default:
        return const Color.fromARGB(255, 253, 139, 255);
    }
  }

  String _getImagePath(int index) {
    switch (index % 5) {
      case 0:
        return 'studcard_dino';
      case 1:
        return 'studcard_kitty';
      case 2:
        return 'studcard_noodle';
      case 3:
        return 'studcard_bunny';
      default:
        return 'studcard_monster';
    }
  }

}
