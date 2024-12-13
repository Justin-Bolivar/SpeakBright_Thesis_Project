// ignore_for_file: avoid_print

import "dart:async";
import "package:flutter/material.dart";
import "package:get_it/get_it.dart";
import "package:go_router/go_router.dart";
import "package:speakbright_mobile/Screens/auth/register_student.dart";
import "package:speakbright_mobile/Screens/guardian/build_profile.dart";
import "package:speakbright_mobile/Screens/guardian/card_ranking_menu.dart";
import "package:speakbright_mobile/Screens/guardian/favorites_view.dart";
import "package:speakbright_mobile/Screens/guardian/student_profile.dart";
import "package:speakbright_mobile/Screens/home/addcard.dart";
import "package:speakbright_mobile/Screens/home/communicate.dart";
import "package:speakbright_mobile/Screens/home/game.dart";
import "package:speakbright_mobile/Screens/home/guardian_cardview.dart";
import "package:speakbright_mobile/Screens/home/guardian_homepage.dart";
import "package:speakbright_mobile/Screens/home/home.dart";
import "package:speakbright_mobile/Screens/home/learn_phase1.dart";
import "package:speakbright_mobile/Screens/home/learn_phase2.dart";
import "package:speakbright_mobile/Screens/home/learn_phase3.dart";
import "package:speakbright_mobile/Screens/home/learn_phase4.dart";
import "package:speakbright_mobile/Screens/home/phase_navigation.dart";
import "package:speakbright_mobile/Screens/home/play.dart";
import "package:speakbright_mobile/Screens/home/student_homepage.dart";
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
    //authenticated
    if (AuthController.I.state == AuthState.authenticated) {
      if (state.matchedLocation == LoginScreen.route) {
        return Home.route;
      }
      if (state.matchedLocation == RegistrationScreen.route) {
        return Home.route;
      }
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
                  path: StudentHomepage.route,
                  name: StudentHomepage.name,
                  builder: (context, _) {
                    return const StudentHomepage();
                  },
                ),
                GoRoute(
                  parentNavigatorKey: _shellNavigatorKey,
                  path: GuardianHomepage.route,
                  name: GuardianHomepage.name,
                  builder: (context, _) {
                    return const GuardianHomepage();
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
              path: PhaseNav.route,
              name: PhaseNav.name,
              builder: (context, _) {
                return const PhaseNav();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Learn1.route,
              name: Learn1.name,
              builder: (context, _) {
                return const Learn1();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Learn2.route,
              name: Learn2.name,
              builder: (context, _) {
                return const Learn2();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Learn3.route,
              name: Learn3.name,
              builder: (context, _) {
                return const Learn3();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Learn4.route,
              name: Learn4.name,
              builder: (context, _) {
                return const Learn4();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Game.route,
              name: Game.name,
              builder: (context, _) {
                return const Game();
              }),
          GoRoute(
              //only for testing remove later
              parentNavigatorKey: _rootNavigatorKey,
              path: AddCardPage.route,
              name: AddCardPage.name,
              builder: (context, _) {
                return AddCardPage();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Explore.route,
              name: Explore.name,
              builder: (context, _) {
                return const Explore();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: Play.route,
              name: Play.name,
              builder: (context, _) {
                return const Play();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: RegistrationStudent.route,
              name: RegistrationStudent.name,
              builder: (context, _) {
                return const RegistrationStudent();
              }),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: BuildProfile.route,
            name: BuildProfile.name,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final facilitatorEmail = extra['facilitatorEmail'] as String;
              final facilitatorPassword =
                  extra['facilitatorPassword'] as String;

              return BuildProfile(
                facilitatorEmail: facilitatorEmail,
                facilitatorPassword: facilitatorPassword,
              );
            },
          ),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: StudentProfile.route,
              name: StudentProfile.name,
              builder: (context, _) {
                return const StudentProfile();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: CardRankingMenu.route,
              name: CardRankingMenu.name,
              builder: (context, _) {
                return const CardRankingMenu();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: FavoritesView.route,
              name: FavoritesView.name,
              builder: (context, _) {
                return const FavoritesView();
              }),
          GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: GuardianCommunicate.route,
              name: GuardianCommunicate.name,
              builder: (context, _) {
                return const GuardianCommunicate();
              }),
        ]);
  }
}
