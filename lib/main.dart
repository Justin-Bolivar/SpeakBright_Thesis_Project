import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Routing/router.dart';
import 'Screens/auth/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AuthController.initialize();
  GlobalRouter.initialize();

  await AuthController.I.loadSession();
  runApp(const MyApp());
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 158, 70, 195)),
        useMaterial3: true,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'Screens/home/homepage.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: DashBoard(),
//     );
//   }
// }