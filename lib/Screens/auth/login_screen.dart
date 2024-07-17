import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../Routing/router.dart';
import '../../Widgets/colors.dart';
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
    username = TextEditingController(text: "firebase@gmail.com");
    password = TextEditingController(text: "123456Abc!");
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

  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kwhite,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    onSubmit();
                  },
                  // ignore: sort_child_properties_last
                  child: const Text("Login"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainpurple,
                    foregroundColor: kwhite,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Flexible(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() => _isHovering = false),
                    child: GestureDetector(
                      onTap: () {
                        GlobalRouter.I.router.go(RegistrationScreen.route);
                      },
                      child: Text(
                        "No account? Register",
                        style: TextStyle(
                            color: _isHovering ? kLightPruple : dullpurple),
                      ),
                    ),
                  ),
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
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset('assets/SpeakBright_P.png',
                          width: 450, height: 250),
                      const SizedBox(height: 30),
                      Flexible(
                        child: TextFormField(
                          decoration: decoration.copyWith(
                            labelText: "Username",
                            prefixIcon: const Icon(
                              Icons.person,
                              color: mainpurple,
                            ),
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
                      ),
                      const SizedBox(
                        height: 15,
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
                                onPressed: () {
                                  setState(() {
                                    obfuscate = !obfuscate;
                                  });
                                },
                                icon: Icon(
                                  obfuscate
                                      ? Icons.remove_red_eye_rounded
                                      : CupertinoIcons.eye_slash,
                                  color: mainpurple,
                                )),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      // prefixIconColor: AppColors.primary.shade700,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: false,
      // fillColor: mainpurple,
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
