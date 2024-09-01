import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        BoxDecoration getCardDecoration(int index) {
          final colors = <Color>[
            _getColorByIndex(index),
            _getColorByIndex(index).withOpacity(0.3)
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/${_getImagePath(index)}.png',
                    height: MediaQuery.of(context).size.width * 0.2,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 14),
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
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
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
    switch (index % 7) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return const Color.fromARGB(255, 255, 209, 59);
      case 3:
        return Colors.green;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.indigo;
      default:
        return Colors.purple;
    }
  }

  String _getImagePath(int index) {
    switch (index % 7) {
      case 0:
        return 'oct';
      case 1:
        return 'bear';
      case 2:
        return 'chick';
      case 3:
        return 'turtle';
      case 4:
        return 'whale';
      case 5:
        return 'pengu';
      default:
        return 'capi';
    }
  }

}
