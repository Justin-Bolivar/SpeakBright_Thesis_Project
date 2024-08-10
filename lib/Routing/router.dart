// ignore_for_file: avoid_print

import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:get_it/get_it.dart";
import "package:go_router/go_router.dart";
import "package:speakbright_mobile/Screens/guardian_screens/guradian_homepage.dart";
import "package:speakbright_mobile/Screens/home/communicate.dart";
import "package:speakbright_mobile/Screens/home/home.dart";
import "package:speakbright_mobile/Screens/home/homepage.dart";
import "../Screens/auth/auth_controller.dart";
import "../Screens/auth/enum/enum.dart";
import "../Screens/auth/login_screen.dart";
import "../Screens/auth/register_screen.dart";
import "../Screens/home/explore.dart";

class GlobalRouter {
  static void initialize() {
    GetIt.instance.registerSingleton<GlobalRouter>(GlobalRouter());
  }

  static GlobalRouter get instance => GetIt.instance<GlobalRouter>();
  static GlobalRouter get I => GetIt.instance<GlobalRouter>();

  late GoRouter router;
  late GlobalKey<NavigatorState> _rootNavigatorKey;
  late GlobalKey<NavigatorState> _shellNavigatorKey;

  Future<bool> _isUserAGuardian(String? uid) async {
    final CollectionReference userGuardianCollection =
        FirebaseFirestore.instance.collection('user_guardian');
    final DocumentSnapshot userDocument =
        await userGuardianCollection.doc(uid).get();
//for debugging only delete later
    // print('Checking document ID: $uid');
    // print('user: ${AuthController.I.currentUser}');
    // print('Document data: ${userDocument.data()}');
    // print('Document exists: ${userDocument.exists}');

   
    if (userDocument.exists) {
      print('Document data: ${userDocument.data()}');
    }

    return userDocument.exists;
  }

  FutureOr<String?> handleRedirect(
      BuildContext context, GoRouterState state) async {
    //authenticated
    if (AuthController.I.state == AuthState.authenticated) {
      bool isGuardian =
          await _isUserAGuardian(AuthController.I.currentUser?.uid);

      if (isGuardian && state.matchedLocation == LoginScreen.route) {
        print("guardian");
        return Home.route;
      }
      if (!isGuardian && state.matchedLocation == LoginScreen.route) {
        print("student");
        return HomePage.route;
      }

      if (state.matchedLocation == RegistrationScreen.route) {
        return Home.route;
      }

      // if (state.matchedLocation == LoginScreen.route) {
      //   return HomePage.route;
      // }
      return null;
    }

    //not authenticated
    if (AuthController.I.state != AuthState.authenticated) {
      if (state.matchedLocation == LoginScreen.route ||
          state.matchedLocation == RegistrationScreen.route) {
        return null;
      }

      return LoginScreen.route;
    }
    return null;
  }

  GlobalRouter() {
    _rootNavigatorKey = GlobalKey<NavigatorState>();
    _shellNavigatorKey = GlobalKey<NavigatorState>();
    router = GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: Home.route,
        redirect: handleRedirect,
        refreshListenable: AuthController.I,
        routes: [
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: LoginScreen.route,
              name: LoginScreen.name,
              builder: (context, _) {
                return const LoginScreen();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: RegistrationScreen.route,
              name: RegistrationScreen.name,
              builder: (context, _) {
                return const RegistrationScreen();
              }),
          ShellRoute(
              navigatorKey: _shellNavigatorKey,
              routes: [
                GoRoute(
                  parentNavigatorKey: _shellNavigatorKey,
                  path: Home.route,
                  name: Home.name,
                  builder: (context, _) {
                    return const Home();
                  },
                ),
                GoRoute(
                  parentNavigatorKey: _shellNavigatorKey,
                  path: HomePage.route,
                  name: HomePage.name,
                  builder: (context, _) {
                    return const HomePage();
                  },
                ),
              ],
              builder: (context, state, child) {
                return const Home();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Communicate.route,
              name: Communicate.name,
              builder: (context, _) {
                return const Communicate();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Explore.route,
              name: Explore.name,
              builder: (context, _) {
                return const Explore();
              }),
        ]);
  }
}
