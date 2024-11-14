// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakbright_mobile/Routing/router.dart';
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
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            'assets/add-bg.png',
            fit: BoxFit.cover,
          )),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width * 0.80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Flexible(
                      child: TextFormField(
                        decoration: decoration.copyWith(
                            labelText: "Name",
                            prefixIcon: Icon(
                              Icons.person,
                              color: boxColors[0],
                            )),
                        focusNode: nameFn,
                        controller: name,
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: 'Please enter your name'),
                        ]).call,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: TextFormField(
                        decoration: decoration.copyWith(
                          labelText: "Birthday",
                          prefixIcon: Icon(
                            Icons.cake,
                            color: boxColors[1],
                          ),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              selectedBirthday?.toString().split(' ')[0] ?? '',
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
                            prefixIcon: Icon(
                              Icons.email,
                              color: boxColors[2],
                            )),
                        focusNode: emailFn,
                        controller: email,
                        onEditingComplete: () {
                          passwordFn.requestFocus();
                        },
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: 'Please fill out the email'),
                          EmailValidator(
                              errorText: "Please select a valid email"),
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
                            prefixIcon: Icon(
                              Icons.password,
                              color: boxColors[3],
                            ),
                            suffixIcon: IconButton(
                                color: boxColors[3],
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
                              errorText:
                                  "Password cannot exceed 72 characters"),
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
                              prefixIcon: Icon(
                                Icons.password,
                                color: boxColors[4],
                              ),
                              suffixIcon: IconButton(
                                  color: boxColors[4],
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
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Assuming you want to navigate to BuildProfile
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => const BuildProfile()),
                    //     );
                    //   },
                    //   child: const Text('Register and Go to Build Profile'),
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(85.0),
                      child: ElevatedButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const BuildProfile()),
                            // );
                            onSubmit();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(
                              'Next',
                              style: GoogleFonts.rubikSprayPaint(
                                  color: kwhite,
                                  fontSize: 26,
                                  letterSpacing: .9),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainpurple,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Align(
                alignment: Alignment.topCenter,
                child: Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  child: Image.asset(
                    'assets/wood_register.png',
                    height: 300,
                  ),
                )),
          )
        ],
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

            ref.read(studentIdProvider.notifier).state = studentID;

            GlobalRouter.I.router.push(
              BuildProfile.route,
              extra: {
                'facilitatorEmail': facilitatorEmail,
                'facilitatorPassword': facilitatorPassword,
              },
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
    CollectionReference phaseRef = 
        FirebaseFirestore.instance.collection('activity_log').doc(userId).collection('phase').doc('1');

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

    Map<String, dynamic> phaseData = {
      'phase': 1,
      'entryTimestamps': [FieldValue.serverTimestamp()],
      'exitTimestamps': [],
    };

    await users.doc(userId).set(studentData);
    await studentsRef.doc(userId).set(studentData);
    await phaseRef.set(phaseData);
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
        borderSide: const BorderSide(color: lGray, width: 1),
      ),
      focusedBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: lGray, width: 1),
      ),
      errorBorder: _baseBorder.copyWith(
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 255, 64, 64), width: 1),
      ));
}
