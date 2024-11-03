// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakbright_mobile/Routing/router.dart';
import 'package:speakbright_mobile/Screens/guardian/student_profile.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class BuildProfile extends ConsumerStatefulWidget {
  const BuildProfile({
    super.key,
    required this.facilitatorEmail,
    required this.facilitatorPassword,
  });

  final String facilitatorEmail;
  final String facilitatorPassword;

  static const String route = "/buildprofile";
  static const String path = "/buildprofile";
  static const String name = "BuildProfile";

  @override
  ConsumerState<BuildProfile> createState() => _BuildProfileState();
}

class _BuildProfileState extends ConsumerState<BuildProfile> {
  final newCardTitleProvider = StateProvider<String>((ref) => '');
  final selectedCategoryProvider = StateProvider<String?>((ref) => null);
  final imageUrlProvider = StateProvider<String?>((ref) => null);

  final addedCardCountProvider = StateProvider<int>((ref) => 0);

  @override
  Widget build(BuildContext context) {
    String? imageUrl = ref.watch(imageUrlProvider);
    String? selectedCategory = ref.watch(selectedCategoryProvider);

    String facilitatorEmail = widget.facilitatorEmail;
    String facilitatorPassword = widget.facilitatorPassword;

    int addedCardCount = ref.watch(addedCardCountProvider);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              'assets/add-bg.png',
              fit: BoxFit.cover,
            )),
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center(
                  child: Container(
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height * 0.70,
                width: MediaQuery.of(context).size.width * 0.80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                      Text(
                        'Add 3-10 favorite objects (${addedCardCount + 1}/10)',
                        style: TextStyle(
                          color: scoreYellow,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          // fontWeight: FontWeight.w500
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: imageUrl == null
                            ? Image.asset(
                                'assets/add_image_icon.png',
                                fit: BoxFit.cover,
                                height: 150,
                              )
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                height: 150,
                              ),
                      ),
                      TextField(
                        onChanged: (value) {
                          ref.read(newCardTitleProvider.notifier).state = value;
                        },
                        decoration:
                            const InputDecoration(hintText: "Enter card title"),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: FutureBuilder<List<String>>(
                          future: fetchCategories(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<String>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              List<String> categories = snapshot.data!;

                              return DropdownButtonFormField<String>(
                                value: selectedCategory,
                                hint: const Text('Select Category'),
                                items: categories.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state = newValue;
                                },
                              );
                            } else {
                              return const Text('No categories available');
                            }
                          },
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Color.fromARGB(137, 24, 51, 186),
                                        ],
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _pickImage(ImageSource.camera, ref),
                                        icon: const Icon(
                                          Icons.camera_alt_rounded,
                                          color: Color.fromARGB(255, 7, 14, 93),
                                        ),
                                        label: const Text(
                                          'Camera',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 7, 14, 93)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Image.asset(
                                      'assets/camera.png',
                                      fit: BoxFit.cover,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(width: 10),
                            Spacer(), //between
                            SizedBox(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.yellow,
                                          Colors.orange,
                                        ],
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _pickImage(
                                            ImageSource.gallery, ref),
                                        icon: const Icon(
                                          Icons.photo_library,
                                          color:
                                              Color.fromARGB(255, 137, 61, 7),
                                        ),
                                        label: const Text(
                                          'Gallery',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 137, 61, 7)),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Image.asset(
                                      'assets/album.png',
                                      fit: BoxFit.cover,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // if (imageUrl != null) Image.network(imageUrl),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      ElevatedButton(
                          onPressed: () => _submitCard(context, ref,
                              facilitatorEmail, facilitatorPassword),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: addGreen,
                          ),
                          child: Text(
                            'Add +',
                            style: GoogleFonts.rubikSprayPaint(
                                color: kwhite, fontSize: 20, letterSpacing: .5),
                          )),

                      //skip button
                      (addedCardCount >= 3)
                          ? TextButton(
                              onPressed: () async {
                                // Sign out the student account
                                await FirebaseAuth.instance.signOut();

                                // Re-sign in the facilitator
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: facilitatorEmail,
                                  password: facilitatorPassword,
                                );
                                GlobalRouter.I.router
                                    .push(StudentProfile.route);
                              },
                              child: Text(
                                'Add more later',
                                style: GoogleFonts.roboto(
                                    color: Color(0xFF55ADFF), fontSize: 15),
                              ),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                    ],
                  ),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Positioned(
                    top: MediaQuery.of(context).size.height * 0.10,
                    child: Image.asset(
                      'assets/favoriteBox.png',
                      height: 200,
                    ),
                  )),
            )
          ],
        ));
  }

  Future<void> _pickImage(ImageSource source, WidgetRef ref1) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);

    if (photo != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/$uniqueFileName');
      try {
        await ref.putFile(File(photo.path));
        String? imageUrl = await ref.getDownloadURL();
        ref1.watch(imageUrlProvider.notifier).state = imageUrl;
      } catch (e) {
        print(e);
      }
    }
  }

  void _submitCard(
    BuildContext context,
    WidgetRef ref,
    String facilitatorEmail,
    String facilitatorPassword,
  ) async {
    String newCardTitle = ref.read(newCardTitleProvider);
    String? imageUrl = ref.watch(imageUrlProvider);
    String? selectedCategory = ref.read(selectedCategoryProvider);

    if (newCardTitle.isNotEmpty && imageUrl != null) {
      String studentID = ref.watch(studentIdProvider);
      if (studentID.isNotEmpty) {
        print('Selected Category: $selectedCategory');

        FirebaseFirestore.instance.collection('cards').add({
          'title': newCardTitle,
          'userId': studentID,
          'imageUrl': imageUrl,
          'category': selectedCategory,
          'tapCount': 0,
          'isFavorite': true,
          'phase1_independence': false,
          'phase2_independence': false,
          'phase3_independence': false,
        }).then((cardRef) async {
          String newCardID = cardRef.id;

          int currentCount = ref.read(addedCardCountProvider.notifier).state;
          if (currentCount < 9) {
            ref.read(addedCardCountProvider.notifier).state = currentCount + 1;
          } else {
            // Sign out the student account
            await FirebaseAuth.instance.signOut();

            // Re-sign in the facilitator
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: facilitatorEmail,
              password: facilitatorPassword,
            );

            GlobalRouter.I.router.push(StudentProfile.route);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All cards added successfully')),
            );
          }

          FirebaseFirestore.instance
              .collection('cards')
              .doc(newCardID)
              .get()
              .then((cardDoc) async {
            if (cardDoc.exists && cardDoc['isFavorite'] == true) {
              CollectionReference favoritesCollection = FirebaseFirestore
                  .instance
                  .collection('favorites')
                  .doc(studentID)
                  .collection('cards');

              FirebaseFirestore.instance.runTransaction((transaction) async {
                DocumentReference favoritesDoc =
                    favoritesCollection.doc(newCardID);
                // DocumentSnapshot favoritesSnapshot =
                //     await transaction.get(favoritesDoc);
                DocumentReference studentFavoritesDoc = FirebaseFirestore
                    .instance
                    .collection('favorites')
                    .doc(studentID);

                DocumentSnapshot studentFavoritesSnapshot =
                    await transaction.get(studentFavoritesDoc);

                if (!studentFavoritesSnapshot.exists) {
                  transaction.set(studentFavoritesDoc, {
                    'studentID': studentID,
                  });
                }

                QuerySnapshot querySnapshot = await favoritesCollection
                    .orderBy('rank', descending: true)
                    .limit(1)
                    .get();

                int newRank = 1;
                if (querySnapshot.docs.isNotEmpty) {
                  int highestRank = querySnapshot.docs.first['rank'];
                  newRank = highestRank + 1;
                }

                transaction.set(favoritesDoc, {
                  'cardID': newCardID,
                  'title': newCardTitle,
                  'imageUrl': imageUrl,
                  'category': selectedCategory,
                  'rank': newRank,
                  'addDistractor': false,
                });
              }).then((_) {
                print('Card added to favorites');
              }).catchError((e) {
                print('Error adding card to favorites: $e');
              });
            }
          }).catchError((e) {
            print('Error checking isFavorite: $e');
          });
        }).catchError((e) {
          print('Error adding card: $e');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all fields')));
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      List<String> allCategories =
          querySnapshot.docs.map((doc) => doc['category'] as String).toList();

      // Define the priority categories, but do not include 'All'
      final priorityCategories = ['Food', 'Toys', 'Emotions', 'School'];

      allCategories.sort((a, b) {
        final indexA = priorityCategories.indexOf(a);
        final indexB = priorityCategories.indexOf(b);

        if (indexA != -1 && indexB != -1) {
          return indexA.compareTo(indexB);
        } else if (indexA != -1) {
          return -1;
        } else if (indexB != -1) {
          return 1;
        } else {
          return a.compareTo(b);
        }
      });

      // Exclude the "All" category
      allCategories.remove('All');

      return allCategories;
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
