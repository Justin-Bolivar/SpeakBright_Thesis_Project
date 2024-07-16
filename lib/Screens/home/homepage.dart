// ignore_for_file: avoid_print, unrelated_type_equality_checks

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';

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

  String imageUrl = '';


  @override
  void initState() {
    super.initState();
    _setupTTS();
    _fetchCards();
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

  Future<void> _addCard(String title) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('cards').add({
          'Title': title,
          'userId': user.uid,
          //add image here??
        });
        await _fetchCards();
      }
    } catch (e) {
      print('Error adding card: $e');
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

  void _showAddCardDialog() {
    String newCardTitle = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Card'),
          content: 
          Column(
            children: [
              TextField(
                onChanged: (value) {
                  newCardTitle = value;
                },
                decoration: const InputDecoration(hintText: "Enter card title"),
              ),
              const SizedBox(height: 10,),
              IconButton.filled
              (onPressed: () async {
                ImagePicker imagePicker = ImagePicker();
                    XFile? file =
                        await imagePicker.pickImage(source: ImageSource.camera);
                    print('${file?.path}');

                    if (file == null) return;
                    //Import dart:core
                    String uniqueFileName =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    //Get a reference to storage root
                    Reference referenceRoot = FirebaseStorage.instance.ref();
                    Reference referenceDirImages =
                        referenceRoot.child('images');

                    //Create a reference for the image to be stored
                    Reference referenceImageToUpload =
                        referenceDirImages.child('name');

                    //Handle errors/success
                    try {
                      //Store the file
                      await referenceImageToUpload.putFile(File(file!.path));
                      //Success: get the download URL
                      imageUrl = await referenceImageToUpload.getDownloadURL();
                    } catch (error) {
                      //Some error occurred
                    }
              }, 
              icon: const Icon(Icons.camera_alt_rounded) )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (newCardTitle.isNotEmpty) {
                  _addCard(newCardTitle);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
        onPressed: _showAddCardDialog,
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
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 25.0,
                mainAxisSpacing: 25.0,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                int colorIndex = index % boxcolors.length;
                String title = cards[index]['Title'];
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
                            Row(
                              children: [
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
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _deleteCard(cards[index].id);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
