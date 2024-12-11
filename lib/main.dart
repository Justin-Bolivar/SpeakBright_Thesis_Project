import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'Routing/router.dart';
import 'Screens/auth/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline persistence for Firestore
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  AuthController.initialize();
  GlobalRouter.initialize();

  await AuthController.I.loadSession();

  // Pre-fetch necessary data
  await prefetchData();

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> prefetchData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Fetch user data
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    //fetch categories data
    await FirebaseFirestore.instance.collection('categories').get();

    // Fetch cards data of logged in user
    await FirebaseFirestore.instance
        .collection('cards')
        .where('userId', isEqualTo: user.uid)
        .get();

    //fetch activity log data of logged in user
    await FirebaseFirestore.instance
        .collection('activity_log')
        .doc(user.uid)
        .get();

    // Fetch favorites data of logged in user
    await FirebaseFirestore.instance
        .collection('favorites')
        .doc(user.uid)
        .get();

    // Fetch currently learning data of logged in user
    await FirebaseFirestore.instance
        .collection('currently_learning')
        .doc(user.uid)
        .get();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: GlobalRouter.I.router,
      title: 'SpeakBright',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: mainpurple),
        useMaterial3: true,
      ),
    );
  }
}
