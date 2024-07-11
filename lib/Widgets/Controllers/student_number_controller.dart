import 'package:flutter/material.dart';

class StudentNumField extends StatelessWidget {
  final TextEditingController controller;

  const StudentNumField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Student Number',
        border: OutlineInputBorder(),
      ),
    );
  }
}
