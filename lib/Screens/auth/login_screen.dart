import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../Routing/router.dart';
import '../../Widgets/constants.dart';
import '../../Widgets/waiting_dialog.dart';
import 'auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String route = "/login";
  static const String name = "Login Screen";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController username, password;
  late FocusNode usernameFn, passwordFn;

  bool obfuscate = true;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    username = TextEditingController();
    password = TextEditingController();
    usernameFn = FocusNode();
    passwordFn = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    username.dispose();
    password.dispose();
    usernameFn.dispose();
    passwordFn.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kwhite,
      body: SafeArea(
        child: SingleChildScrollView(
          // Wrap everything in SingleChildScrollView
          child: Column(
            children: [
              Image.asset('assets/SpeakBright_P.png', width: 450, height: 250),
              const SizedBox(height: 30),
              Form(
                key: formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            decoration: decoration.copyWith(
                              labelText: "Username",
                              prefixIcon:
                                  const Icon(Icons.person, color: mainpurple),
                              labelStyle: const TextStyle(color: mainpurple),
                              hintStyle: const TextStyle(color: mainpurple),
                            ),
                            focusNode: usernameFn,
                            controller: username,
                            onEditingComplete: () {
                              passwordFn.requestFocus();
                            },
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: 'Please fill out the username'),
                              MaxLengthValidator(32,
                                  errorText:
                                      "Username cannot exceed 32 characters"),
                              EmailValidator(
                                  errorText: "Please select a valid email"),
                            ]).call,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: obfuscate,
                            decoration: decoration.copyWith(
                              labelText: "Password",
                              prefixIcon:
                                  const Icon(Icons.password, color: mainpurple),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obfuscate = !obfuscate;
                                    });
                                  },
                                  icon: Icon(
                                      obfuscate
                                          ? Icons.remove_red_eye_rounded
                                          : CupertinoIcons.eye_slash,
                                      color: mainpurple)),
                              labelStyle: const TextStyle(color: mainpurple),
                              hintStyle: const TextStyle(color: mainpurple),
                            ),
                            focusNode: passwordFn,
                            controller: password,
                            onEditingComplete: () {
                              passwordFn.unfocus();
                            },
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: "Password is required"),
                              MaxLengthValidator(128,
                                  errorText:
                                      "Password cannot exceed 72 characters"),
                            ]).call,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    onSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainpurple,
                    foregroundColor: kwhite,
                    textStyle: const TextStyle(fontSize: 18),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Login"),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: MouseRegion(
                  child: GestureDetector(
                      onTap: () {
                        GlobalRouter.I.router.go(RegistrationScreen.route);
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'No Guardian account Yet? ',
                                style: TextStyle(color: mainpurple)),
                            TextSpan(
                                text: 'Register Here',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: mainpurple)),
                          ],
                        ),
                      )),
                ),
              ),
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/earth.png',
                        fit: BoxFit.cover,
                        height: 260,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onSubmit() {
    if (formKey.currentState?.validate() ?? false) {
      WaitingDialog.show(context,
          future: AuthController.I
              .login(username.text.trim(), password.text.trim()));
    }
  }

  final OutlineInputBorder _baseBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: kwhite),
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  InputDecoration get decoration => InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: false,
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
            const BorderSide(color: Color.fromARGB(255, 244, 0, 0), width: 1),
      ));
}
