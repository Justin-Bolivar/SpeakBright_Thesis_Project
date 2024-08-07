import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Screens/home/profile_dialogue.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Widgets/waiting_dialog.dart';
import '../auth/auth_controller.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RainbowContainer extends StatefulWidget {
  const RainbowContainer({super.key});

  @override
  _RainbowContainerState createState() => _RainbowContainerState();
}

class _RainbowContainerState extends State<RainbowContainer> {
  late Future<DocumentSnapshot> _userDoc;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _setupTTS();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userDoc = FirebaseFirestore.instance.collection('users').doc(uid).get();
    } else {
      _userDoc = Future.error('User not found');
    }
  }

  Future<void> _setupTTS() async {
    await flutterTts.setLanguage("en-US");
    await _setDefaultVoice();
  }

  Future<void> _setDefaultVoice() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    String voiceName = connectivityResult != ConnectivityResult.none
        ? "Microsoft Aria Online (Natural) - English (United States)"
        : "Microsoft Zira - English (United States)";

    await flutterTts.setVoice({"name": voiceName, "locale": "en-US"});
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _setDefaultVoice();
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userDoc,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          String userName = userData['name'] ?? 'User';
          DateTime userBirthday =
              DateTime.parse(userData['birthday'].toDate().toString());

          return Expanded(
            child: SizedBox(
              height: 146,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 145,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8E2DE2), mainpurple],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.logout,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                WaitingDialog.show(context,
                                    future: AuthController.I.logout());
                              },
                            ),
                          ],
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "Hello $userName!",
                                        style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors
                                                .transparent, // Transparent barrier color
                                            builder: (BuildContext context) {
                                              return ProfileDialogue(
                                                name: userName,
                                                birthday: userBirthday,
                                                onTap: () async {
                                                  _speak(
                                                      "Your name is $userName");
                                                },
                                              );
                                            },
                                          );
                                        },
                                        style: ButtonStyle(
                                          elevation:
                                              WidgetStateProperty.all<double>(
                                                  0),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  dullpurple),
                                        ),
                                        child: const Text('View Profile',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 70,
                    child: Image.asset(
                      'assets/dash_bg.png',
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.width*0.2,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 40,
                    child: Image.asset(
                      'assets/explore.png',
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.width*0.3,
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          // While waiting for the future to complete
          return const CircularProgressIndicator(); // Or a similar loading indicator
        }
      },
    );
  }
}
