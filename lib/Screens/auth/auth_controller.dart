// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'enum/enum.dart';



class AuthController with ChangeNotifier {
  static void initialize() {
    GetIt.instance.registerSingleton<AuthController>(AuthController());
  }

  User? _currentUser;
  bool _isGuardian = false;

  User? get currentUser => _currentUser;
  bool get isGuardian => _isGuardian;

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
      _isGuardian = await isUserAGuardian(user.uid); 
    }
    notifyListeners();
  }

  login(String userName, String password) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: userName, password: password);

  }

  Future<bool> isUserAGuardian(String? uid) async {
    CollectionReference userGuardianCollection =
        FirebaseFirestore.instance.collection('user_guardian');
    final DocumentSnapshot userDocument =
        await userGuardianCollection.doc(uid).get();

    //debigging delete later

    if (FirebaseAuth.instance.currentUser?.uid != null) {
      // ignore: avoid_print
      print('uid:${FirebaseAuth.instance.currentUser?.uid}');
      print('$uid');
    } else {
      // ignore: avoid_print
      print('error no uid');
    }

    return userDocument.exists;
  }

  register(String userName, String password) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: userName, password: password);
  }

  logout() {
    return FirebaseAuth.instance.signOut();
  }

  ///must be called in main before runApp
  loadSession() async {
    listen();
    User? user = FirebaseAuth.instance.currentUser;
    handleUserChanges(user);
  }

  ///https://pub.dev/packages/flutter_secure_storage or any caching dependency of your choice like localstorage, hive, or a db
}
