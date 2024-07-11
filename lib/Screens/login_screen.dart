import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/Controllers/password_controller.dart';
import 'package:speakbright_mobile/Widgets/Controllers/student_number_controller.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StudentNumField(controller: emailController),
            const SizedBox(height: 16),
            PasswordField(controller: passwordController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle login logic here
                print('Email: ${emailController.text}');
                print('Password: ${passwordController.text}');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
