// ignore_for_file: avoid_print, unrelated_type_equality_checks

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speakbright_mobile/Screens/home/addcard.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../Routing/router.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});
  static const String route = '/home';
  static const String path = "/home";
  static const String name = "Dashboard";

  @override
  // ignore: library_private_types_in_public_api
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final FlutterTts flutterTts = FlutterTts();
  List<QueryDocumentSnapshot> cards = [];
  late StreamController<List<QueryDocumentSnapshot>> cardStreamController;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _setupTTS();
    _fetchCards();
    _initializeStreamController();
  }

  void _initializeStreamController() {
    cardStreamController =
        StreamController<List<QueryDocumentSnapshot>>(sync: false);
    _fetchCardsAsStream();
  }

  Future<void> _fetchCardsAsStream() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      cardStreamController.addStream(FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs));
    }
  }

  Future<void> _setupTTS() async {
    await flutterTts.setLanguage("en-US");
    await _setDefaultVoice();
  }

  Future<void> _setDefaultVoice() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      await flutterTts.setVoice({
        "name": "Microsoft Aria Online (Natural) - English (United States)",
        "locale": "en-US"
      });
    } else {
      await flutterTts.setVoice({
        "name": "Microsoft Zira - English (United States)",
        "locale": "en-US"
      });
    }
    await flutterTts.setPitch(1.0);
  }

  Future<void> _fetchCards() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('cards')
            .where('userId', isEqualTo: user.uid)
            .get();
        setState(() {
          cards = querySnapshot.docs;
        });
      }
    } catch (e) {
      print('Error fetching cards: $e');
    }
  }

  Future<void> _deleteCard(String docId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cardDoc = await FirebaseFirestore.instance
            .collection('cards')
            .doc(docId)
            .get();
        if (cardDoc.exists && cardDoc.data()?['userId'] == user.uid) {
          await FirebaseFirestore.instance
              .collection('cards')
              .doc(docId)
              .delete();
          await _fetchCards();
        }
      }
    } catch (e) {
      print('Error deleting card: $e');
    }
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
    List<Color> boxcolors = [
      Colors.red,
      Colors.orange,
      const Color.fromARGB(255, 237, 195, 7),
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    return Scaffold(
      backgroundColor: kwhite,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // GlobalRouter.I.router.go(AddCardPage.route);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCardPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              Container(
                height: 115,
                decoration: BoxDecoration(
                  color: boxcolors[0],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: boxcolors[1],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                height: 105,
                decoration: BoxDecoration(
                  color: boxcolors[2],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: boxcolors[3],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                height: 95,
                decoration: BoxDecoration(
                  color: boxcolors[4],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: boxcolors[5],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                height: 85,
                decoration: BoxDecoration(
                  color: boxcolors[6],
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: kwhite,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    color: kwhite,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Text(
                          "HI DONNA!",
                        )
                      ],
                    ),
                  )),
            ]),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            flex: 3,
            child:
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cards')
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading cards'));
                }

                final cards = snapshot.data?.docs ?? [];

                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 25.0,
                      mainAxisSpacing: 25.0,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      int colorIndex = index % boxcolors.length;
                      String title = cards[index]['title'];
                      String imageUrl = cards[index]['imageUrl'];

                      return GestureDetector(
                        onTap: () {
                          _speak(title);
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: kwhite,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 1,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.topLeft,
                                    children: [
                                      Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    color: Colors.transparent,
                                  ),
                                  child: imageUrl != null && imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'Error loading image: $error');
                                              return  Icon(
                                                  Icons.image_not_supported,
                                                  color: boxcolors[colorIndex]);
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      :  Icon(Icons.image,
                                          color: boxcolors[colorIndex]),
                                ),
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(100),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.music_note,
                                          color: boxcolors[colorIndex],
                                          size: 40,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Container(
                                      height: 30,
                                      child: Image.network(imageUrl)),
                                  Center(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        color: boxcolors[colorIndex],
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _deleteCard(cards[index].id);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          ),
        ]),
      ),
    );
  }
}
