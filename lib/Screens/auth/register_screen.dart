// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import '../../Widgets/waiting_dialog.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const String route = "/register";
  static const String name = "Registration Screen";
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController username, password, password2, name, birthday;
  late FocusNode usernameFn, passwordFn, password2Fn, nameFn, birthdayFn;
  DateTime? selectedBirthday;
  String? userType;

  bool obfuscate = true;
  bool _isHovering = false;
  double _userTypeSliderValue = 0.0; // 0.0 for Guardian, 1.0 for Student

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    username = TextEditingController();
    usernameFn = FocusNode();
    password = TextEditingController();
    passwordFn = FocusNode();
    password2 = TextEditingController();
    password2Fn = FocusNode();
    name = TextEditingController();
    nameFn = FocusNode();
    birthday = TextEditingController();
    birthdayFn = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    username.dispose();
    usernameFn.dispose();
    password.dispose();
    passwordFn.dispose();
    password2.dispose();
    password2Fn.dispose();
    name.dispose();
    nameFn.dispose();
    birthday.dispose();
    birthdayFn.dispose();
  }

  Widget buildUserTypeSegmentedButton() {
    return Container(
      decoration: const BoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'Student',
              label: Center(child: Text('Student')),
            ),
            ButtonSegment<String>(
              value: 'Guardian',
              label: Center(child: Text('Guardian')),
            ),
          ],
          selected: {userType ?? 'Student'},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              userType = newSelection.first;
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return mainpurple;
                }
                return Colors.grey[200]!;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.grey[200]!;
                }
                return mainpurple;
              },
            ),
            side: WidgetStateProperty.all(BorderSide.none),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kwhite,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    onSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainpurple,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Register"),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Flexible(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() => _isHovering = false),
                    child: GestureDetector(
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            ),
                        child: RichText(
                          text: const TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(color: mainpurple)),
                              TextSpan(
                                  text: 'Login here',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: mainpurple)),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset('assets/SpeakBright_P.png',
                    width: 300, height: 180),
                const SizedBox(height: 8),
                buildUserTypeSegmentedButton(),
                const SizedBox(height: 8),
                Flexible(
                  child: TextFormField(
                    decoration: decoration.copyWith(
                        labelText: "Name",
                        prefixIcon: const Icon(
                          Icons.person,
                          color: mainpurple,
                        )),
                    focusNode: nameFn,
                    controller: name,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Please enter your name'),
                    ]).call,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: TextFormField(
                    decoration: decoration.copyWith(
                      labelText: "Birthday",
                      prefixIcon: const Icon(
                        Icons.cake,
                        color: mainpurple,
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedBirthday?.toString().split(' ')[0] ?? '',
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedBirthday ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != selectedBirthday) {
                        setState(() {
                          selectedBirthday = picked;
                        });
                      }
                    },
                    validator: (value) {
                      if (selectedBirthday == null) {
                        return 'Please select your birthday';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  child: TextFormField(
                    decoration: decoration.copyWith(
                        labelText: "Email",
                        prefixIcon: const Icon(
                          Icons.person,
                          color: mainpurple,
                        )),
                    focusNode: usernameFn,
                    controller: username,
                    onEditingComplete: () {
                      passwordFn.requestFocus();
                    },
                    validator: MultiValidator([
                      RequiredValidator(
                          errorText: 'Please fill out the username'),
                      EmailValidator(errorText: "Please select a valid email"),
                    ]).call,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: obfuscate,
                    decoration: decoration.copyWith(
                        labelText: "Password",
                        prefixIcon: const Icon(
                          Icons.password,
                          color: mainpurple,
                        ),
                        suffixIcon: IconButton(
                            color: mainpurple,
                            onPressed: () {
                              setState(() {
                                obfuscate = !obfuscate;
                              });
                            },
                            icon: Icon(obfuscate
                                ? Icons.remove_red_eye_rounded
                                : CupertinoIcons.eye_slash))),
                    focusNode: passwordFn,
                    controller: password,
                    onEditingComplete: () {
                      password2Fn.requestFocus();
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Password is required"),
                      MinLengthValidator(12,
                          errorText:
                              "Password must be at least 12 characters long"),
                      MaxLengthValidator(128,
                          errorText: "Password cannot exceed 72 characters"),
                      PatternValidator(
                          r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+?\-=[\]{};':,.<>]).*$",
                          errorText:
                              'Password must contain at least one symbol, one uppercase letter, one lowercase letter, and one number.')
                    ]).call,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Flexible(
                  child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: obfuscate,
                      decoration: decoration.copyWith(
                          labelText: "Confirm Password",
                          prefixIcon: const Icon(
                            Icons.password,
                            color: mainpurple,
                          ),
                          suffixIcon: IconButton(
                              color: mainpurple,
                              onPressed: () {
                                setState(() {
                                  obfuscate = !obfuscate;
                                });
                              },
                              icon: Icon(obfuscate
                                  ? Icons.remove_red_eye_rounded
                                  : CupertinoIcons.eye_slash))),
                      focusNode: password2Fn,
                      controller: password2,
                      onEditingComplete: () {
                        password2Fn.unfocus();
                      },
                      validator: (v) {
                        String? doesMatchPasswords =
                            password.text == password2.text
                                ? null
                                : "Passwords doesn't match";
                        if (doesMatchPasswords != null) {
                          return doesMatchPasswords;
                        } else {
                          return MultiValidator([
                            RequiredValidator(
                                errorText: "Password is required"),
                            MinLengthValidator(12,
                                errorText:
                                    "Password must be at least 12 characters long"),
                            MaxLengthValidator(128,
                                errorText:
                                    "Password cannot exceed 72 characters"),
                            PatternValidator(
                                r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+?\-=[\]{};':,.<>]).*$",
                                errorText:
                                    'Password must contain at least one symbol, one uppercase letter, one lowercase letter, and one number.'),
                          ]).call(v);
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        UserCredential? userCredential = await WaitingDialog.show(
          context,
          future: FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: username.text.trim(),
            password: password.text.trim(),
          ),
        );

        if (userCredential?.user != null) {
          await _storeUserData(userCredential!.user!.uid);
          // Navigate to next screen or show success message
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _storeUserData(String userId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    String userId = user.uid;

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    DateTime birthdayDate = selectedBirthday ?? DateTime.now();
    Timestamp birthdayTimestamp = Timestamp.fromDate(DateTime(
        birthdayDate.year, birthdayDate.month, birthdayDate.day, 0, 0, 0));

    await users.doc(userId).set({
      'name': name.text.trim(),
      'email': username.text.trim(),
      'birthday': birthdayTimestamp,
      'userID': userId,
      'userType': userType,
    });
  }

  final OutlineInputBorder _baseBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: kLightPruple),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  InputDecoration get decoration => InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      errorMaxLines: 3,
      disabledBorder: _baseBorder,
      enabledBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: kLightPruple, width: 1),
      ),
      focusedBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: mainpurple, width: 1),
      ),
      errorBorder: _baseBorder.copyWith(
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 255, 64, 64), width: 1),
      ));
}
