import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key); // Corrected here
  static const String route = '/home';
  static const String path = "/home";
  static const String name = "Dashboard";

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _setupTTS();
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

  Future<void> _addCard(String title, String imageUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('cards').add({
          'title': title, // Changed 'Title' to 'title'
          'userId': user.uid,
          'imageUrl': imageUrl,
        });
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
          String? imageUrl = cardDoc.data()?['imageUrl'];
          if (imageUrl != null) {
            await FirebaseStorage.instance.refFromURL(imageUrl).delete();
          }
          await FirebaseFirestore.instance
              .collection('cards')
              .doc(docId)
              .delete();
        }
      }
    } catch (e) {
      print('Error deleting card: $e');
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _showAddCardDialog() {
    String newCardTitle = '';
    String imageUrl = '';
    dynamic imageFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Card'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      newCardTitle = value;
                    },
                    decoration: InputDecoration(hintText: "Enter card title"),
                  ),
                  const SizedBox(height: 10),
                  imageFile != null
                      ? kIsWeb
                          ? Image.memory(imageFile,
                              height: 100, width: 100, fit: BoxFit.cover)
                          : Image.file(imageFile,
                              height: 100, width: 100, fit: BoxFit.cover)
                      : const SizedBox(),
                  IconButton(
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? pickedFile = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (pickedFile == null) return;

                      if (kIsWeb) {
                        imageFile = await pickedFile.readAsBytes();
                      } else {
                        imageFile = File(pickedFile.path);
                      }
                    },
                    icon: const Icon(Icons.image),
                  )
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
                  onPressed: () async {
                    if (newCardTitle.isNotEmpty && imageFile != null) {
                      String uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages =
                          referenceRoot.child('images');
                      Reference referenceImageToUpload =
                          referenceDirImages.child(uniqueFileName);

                      try {
                        UploadTask uploadTask;
                        if (kIsWeb) {
                          uploadTask = referenceImageToUpload.putData(imageFile,
                              SettableMetadata(contentType: 'image/jpeg'));
                        } else {
                          uploadTask = referenceImageToUpload.putFile(imageFile,
                              SettableMetadata(contentType: 'image/jpeg'));
                        }

                        TaskSnapshot snapshot = await uploadTask;
                        imageUrl = await snapshot.ref.getDownloadURL();
                        await _addCard(newCardTitle, imageUrl);
                        Navigator.of(context).pop();
                      } catch (error) {
                        print('Error uploading image: $error');
                      }
                    }
                  },
                ),
              ],
            );
          },
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
      backgroundColor: Colors.white,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                ),
              ),
              Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
            child: StreamBuilder<QuerySnapshot>(
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 25.0,
                    mainAxisSpacing: 25.0,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    int colorIndex = index % boxcolors.length;
                    String title = cards[index]['title'];
                    String? imageUrl = cards[index]['imageUrl'];

                    // Add print statement to debug image URL
                    print('Image URL: $imageUrl');

                    return GestureDetector(
                      onTap: () {
                        _speak(title);
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    color: Colors.purple[100],
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
                                              return const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white);
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
                                      : const Icon(Icons.image,
                                          color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: boxcolors[colorIndex],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
