// ignore_for_file: unused_local_variable, avoid_print
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'enum/enum.dart';

class AuthController with ChangeNotifier {
  static void initialize() {
    GetIt.instance.registerSingleton<AuthController>(AuthController());
  }

  User? _currentUser;

  User? get currentUser => _currentUser;

  static AuthController get instance => GetIt.instance<AuthController>();
  static AuthController get I => GetIt.instance<AuthController>();

  late StreamSubscription<User?> currentAuthedUser;
  AuthState state = AuthState.unauthenticated;

  listen() {
    currentAuthedUser =
        FirebaseAuth.instance.authStateChanges().listen(handleUserChanges);
  }

  Future<void> handleUserChanges(User? user) async {
    _currentUser = user;

    if (user == null) {
      state = AuthState.unauthenticated;
    } else {
      state = AuthState.authenticated;
    }
    notifyListeners();
  }

  login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(FirebaseAuth.instance.currentUser);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Invalid credentials",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print(e.toString());
    }
  }

  register(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> registerStudent(String email, String password) async {
    try {
      UserCredential? userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Sign out the newly created user
        await FirebaseAuth.instance.signOut();

        // Update the controller with the current user (facilitator)
        handleUserChanges(FirebaseAuth.instance.currentUser);

        Fluttertoast.showToast(msg: "Student Registered Successfully!");
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Registration failed: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    // return FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }

  ///must be called in main before runApp
  loadSession() async {
    listen();
    User? user = FirebaseAuth.instance.currentUser;
    handleUserChanges(user);
  }

  ///https://pub.dev/packages/flutter_secure_storage or any caching dependency of your choice like localstorage, hive, or a db
}
