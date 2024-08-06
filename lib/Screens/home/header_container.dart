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
                                              // return BackdropFilter(
                                              //   filter: ImageFilter.blur(
                                              //       sigmaX: 5.0,
                                              //       sigmaY:
                                              //           5.0), // Apply blur effect
                                              //   child: SizedBox(
                                              //     width:
                                              //         250, // Specify the width of the dialog
                                              //     height:
                                              //         200, // Specify the height of the dialog
                                              //     child: Center(
                                              //       child: Container(
                                              //         constraints:
                                              //             const BoxConstraints(
                                              //                 maxWidth: 300,
                                              //                 maxHeight:
                                              //                     400), // Ensure the dialog doesn't exceed the specified dimensions
                                              //         child: Stack(
                                              //           children: <Widget>[
                                              //             Positioned.fill(
                                              //               child: Container(
                                              //                 decoration:
                                              //                     BoxDecoration(
                                              //                   color: Colors
                                              //                       .transparent, // Dialog background color
                                              //                   borderRadius:
                                              //                       BorderRadius
                                              //                           .circular(
                                              //                               15), // Rounded corners
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             Center(
                                              //               child: Container(
                                              //                 height:
                                              //                     200, // Adjust the height as needed
                                              //                 decoration:
                                              //                     BoxDecoration(
                                              //                   color: Colors
                                              //                       .white, // White background for content visibility
                                              //                   borderRadius:
                                              //                       BorderRadius
                                              //                           .circular(
                                              //                               15), // Rounded corners
                                              //                 ),
                                              //                 child: Padding(
                                              //                   padding:
                                              //                       const EdgeInsets
                                              //                           .all(
                                              //                           25.0),
                                              //                   child: Column(
                                              //                     mainAxisAlignment:
                                              //                         MainAxisAlignment
                                              //                             .start,
                                              //                     crossAxisAlignment:
                                              //                         CrossAxisAlignment
                                              //                             .stretch,
                                              //                     children: <Widget>[
                                              //                       Text(
                                              //                           userName,
                                              //                           style: const TextStyle(
                                              //                               fontWeight:
                                              //                                   FontWeight.bold,
                                              //                               fontSize: 20)),
                                              //                       const Text(
                                              //                           'Name',
                                              //                           style: TextStyle(
                                              //                               fontWeight:
                                              //                                   FontWeight.w200,
                                              //                               fontSize: 15)),
                                              //                       const SizedBox(
                                              //                         height:
                                              //                             12,
                                              //                       ),

                                              //                       Text(
                                              //                         DateFormat(
                                              //                                 'MMM dd, yyyy')
                                              //                             .format(
                                              //                                 userBirthday),
                                              //                         style: const TextStyle(
                                              //                             fontSize:
                                              //                                 17,
                                              //                             color:
                                              //                                 Colors.amber),
                                              //                       ),
                                              //                       const Text(
                                              //                           'Birthday',
                                              //                           style: TextStyle(
                                              //                               fontWeight:
                                              //                                   FontWeight.w200,
                                              //                               fontSize: 15)), // Format date
                                              //                     ],
                                              //                   ),
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             Positioned(
                                              //               right: 5,
                                              //               top: 55,
                                              //               child:
                                              //                   GestureDetector(
                                              //                 onTap: () async {
                                              //                   _speak(
                                              //                       "Your name is $userName");
                                              //                 },
                                              //                 child:
                                              //                     Image.asset(
                                              //                   'assets/profile.png',
                                              //                   fit: BoxFit
                                              //                       .cover,
                                              //                   height: 170,
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             Positioned(
                                              //               bottom: 0,
                                              //               left: 0,
                                              //               right: 0,
                                              //               child: Padding(
                                              //                   padding:
                                              //                       const EdgeInsets
                                              //                           .all(
                                              //                           16.0),
                                              //                   child:
                                              //                       TextButton(
                                              //                     child: const Text(
                                              //                         'Close'),
                                              //                     onPressed:
                                              //                         () {
                                              //                       Navigator.of(
                                              //                               context)
                                              //                           .pop();
                                              //                     },
                                              //                     style: TextButton
                                              //                         .styleFrom(
                                              //                       foregroundColor:
                                              //                           Colors
                                              //                               .white,
                                              //                       backgroundColor:
                                              //                           const Color
                                              //                               .fromARGB(
                                              //                               255,
                                              //                               198,
                                              //                               65,
                                              //                               56), // Background color
                                              //                       shape:
                                              //                           RoundedRectangleBorder(
                                              //                         borderRadius:
                                              //                             BorderRadius.circular(
                                              //                                 8), // Rounded corners
                                              //                       ),
                                              //                     ),
                                              //                   )),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ),
                                              // );
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
                      height: 100,
                    ),
                  ),
                  Positioned(
                    right: 240,
                    top: 40,
                    child: Image.asset(
                      'assets/explore.png',
                      fit: BoxFit.cover,
                      height: 128,
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
