// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:speakbright_mobile/Screens/auth/auth_controller.dart';
import 'package:speakbright_mobile/Screens/guardian/build_profile.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';
import '../../Widgets/waiting_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationStudent extends ConsumerStatefulWidget {
  static const String route = "/registerstudent";
  static const String name = "Student Registration";
  const RegistrationStudent({super.key});

  @override
  ConsumerState<RegistrationStudent> createState() =>
      _RegistrationStudentState();
}

class _RegistrationStudentState extends ConsumerState<RegistrationStudent> {
  late GlobalKey<FormState> formKey;
  late TextEditingController email, password, password2, name, birthday;
  late FocusNode emailFn, passwordFn, password2Fn, nameFn, birthdayFn;
  DateTime? selectedBirthday;
  String? userType;
  String? guardianID;

  bool obfuscate = true;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    email = TextEditingController();
    emailFn = FocusNode();
    password = TextEditingController();
    passwordFn = FocusNode();
    password2 = TextEditingController();
    password2Fn = FocusNode();
    name = TextEditingController();
    nameFn = FocusNode();
    birthday = TextEditingController();
    birthdayFn = FocusNode();

    fetchGuardianID();
  }

  Future<void> fetchGuardianID() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        guardianID = currentUser.uid;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    emailFn.dispose();
    password.dispose();
    passwordFn.dispose();
    password2.dispose();
    password2Fn.dispose();
    name.dispose();
    nameFn.dispose();
    birthday.dispose();
    birthdayFn.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(RegistrationStudent.name),
        backgroundColor: kwhite,
      ),
      backgroundColor: kwhite,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          height: 150,
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
                Image.asset('assets/SpeakBright_P.png', height: 120),
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
                    focusNode: emailFn,
                    controller: email,
                    onEditingComplete: () {
                      passwordFn.requestFocus();
                    },
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Please fill out the email'),
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
                ElevatedButton(
                  onPressed: () {
                    // Assuming you want to navigate to BuildProfile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BuildProfile()),
                    );
                  },
                  child: const Text('Register and Go to Build Profile'),
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
        // Ask for facilitator password
        String? facilitatorPassword =
            await showFacilitatorPasswordDialog(context);

        if (facilitatorPassword == null || facilitatorPassword.isEmpty) {
          // If no password was entered or dialog was canceled
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facilitator password is required')),
          );
          return;
        }

        // Get facilitator's credentials (email)
        User? currentUser = FirebaseAuth.instance.currentUser;
        String? facilitatorEmail = currentUser?.email;

        if (facilitatorEmail == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facilitator is not logged in')),
          );
          return;
        }

        // Re-authenticate the facilitator with their password
        AuthCredential credential = EmailAuthProvider.credential(
          email: facilitatorEmail,
          password: facilitatorPassword,
        );

        try {
          await currentUser?.reauthenticateWithCredential(credential);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid facilitator password')),
          );
          return; // Stop the registration process if re-authentication fails
        }

        // Proceed with student registration if re-authentication is successful
        UserCredential? userCredential = await WaitingDialog.show(
          context,
          future: FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text.trim(),
          ),
        );

        if (userCredential?.user != null) {
          String? studentID = userCredential?.user?.uid;
          if (studentID != null) {
            await storeStudentData();
            await initializePromptData();

            // Ensure studentID is not null before assigning
            ref.read(studentIdProvider.notifier).state =
                studentID; // studentID is guaranteed to be non-null here

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BuildProfile()),
            );

            // Sign out the student account
            await FirebaseAuth.instance.signOut();

            // Re-sign in the facilitator
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: facilitatorEmail,
              password: facilitatorPassword,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Student Account Created')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Student ID is null')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Failed to create user')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> storeStudentData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    String userId = user.uid;

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    CollectionReference userGuardianRef =
        FirebaseFirestore.instance.collection('user_guardian');
    DocumentReference userGuardianDoc = userGuardianRef.doc(guardianID);
    CollectionReference studentsRef = userGuardianDoc.collection('students');

    DateTime birthdayDate = selectedBirthday ?? DateTime.now();
    Timestamp birthdayTimestamp = Timestamp.fromDate(DateTime(
        birthdayDate.year, birthdayDate.month, birthdayDate.day, 0, 0, 0));

    Map<String, dynamic> studentData = {
      'name': name.text.trim(),
      'email': email.text.trim(),
      'birthday': birthdayTimestamp,
      'userID': userId,
      'userType': 'student',
      'phase': 1
    };
    print(userId);

    await users.doc(userId).set(studentData);
    await studentsRef.doc(userId).set(studentData);
  }

  Future<void> initializePromptData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    String userId = user.uid;

    CollectionReference prompt =
        FirebaseFirestore.instance.collection('prompt');

    Map<String, dynamic> promptData = {
      'userID': userId,
      'email': email.text.trim(),
      'Physical': 0,
      'Modeling': 0,
      'Gestural': 0,
      'Verbal': 0,
      'Independent': 0,
    };
    print(userId);

    await prompt.doc(userId).set(promptData);
  }

  final OutlineInputBorder _baseBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: kLightPruple),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  Future<String?> showFacilitatorPasswordDialog(BuildContext context) async {
    String? facilitatorPassword;
    bool obfuscate = true; // Controls the visibility of the password
    TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Facilitator Password'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextFormField(
                controller: passwordController,
                obscureText: obfuscate,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.password, color: mainpurple),
                  suffixIcon: IconButton(
                    color: mainpurple,
                    onPressed: () {
                      setState(() {
                        obfuscate = !obfuscate;
                      });
                    },
                    icon: Icon(obfuscate
                        ? Icons.remove_red_eye_rounded
                        : CupertinoIcons.eye_slash),
                  ),
                ),
                validator: RequiredValidator(errorText: 'Password is required'),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, null), // Cancel the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                facilitatorPassword = passwordController.text;
                Navigator.pop(context, facilitatorPassword);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

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
