import "dart:async";
import "package:flutter/material.dart";
import "package:get_it/get_it.dart";
import "package:go_router/go_router.dart";
import "package:speakbright_mobile/Screens/home/communicate.dart";
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

  FutureOr<String?> handleRedirect(
      BuildContext context, GoRouterState state) async {
    if (AuthController.I.state == AuthState.authenticated) {
      if (state.matchedLocation == LoginScreen.route) {
        return HomePage.route;
      }
      if (state.matchedLocation == RegistrationScreen.route) {
        return HomePage.route;
      }
      return null;
    }
    if (AuthController.I.state != AuthState.authenticated) {
      if (state.matchedLocation == LoginScreen.route) {
        return null;
      }
      if (state.matchedLocation == RegistrationScreen.route) {
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
        initialLocation: HomePage.route,
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
                  path: HomePage.route,
                  name: HomePage.name,
                  builder: (context, _) {
                    return const HomePage();
                  },
                  // routes: [
                  //   GoRoute(
                  //       parentNavigatorKey: _shellNavigatorKey,
                  //       path: Communicate.route,
                  //       name: Communicate.name,
                  //       builder: (context, _) {
                  //         return Communicate();
                  //       }),
                  // GoRoute(
                  //     parentNavigatorKey: _rootNavigatorKey,
                  //     path: Explore.route,
                  //     name: Explore.name,
                  //     builder: (context, _) {
                  //       return const Explore(
                  //          );}),
                  // GoRoute(
                  //     parentNavigatorKey: _rootNavigatorKey,
                  //     path: Play.route,
                  //     name: Play.name,
                  //     builder: (context, _) {
                  //       return const Play();
                  //     }),
                  // GoRoute(
                  //     parentNavigatorKey: _rootNavigatorKey,
                  //     path: Test.route,
                  //     name: Test.name,
                  //     builder: (context, _) {
                  //       return const Test();
                  //     }),
                  // ]
                ),
                // GoRoute(
                //     parentNavigatorKey: _shellNavigatorKey,
                //     path: Communicate.route,
                //     name: Communicate.name,
                //     builder: (context, _) {
                //       return const Communicate();
                //     }),
              ],
              builder: (context, state, child) {
                return const HomePage();
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
