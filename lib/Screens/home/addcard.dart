import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';

// ignore: must_be_immutable
class AddCardPage extends ConsumerWidget {
  AddCardPage({super.key});

  static const String route = '/addcard';
  static const String path = "/addcard";
  static const String name = "Add Card";

  // String newCardTitle = '';
  // String? imageUrl;
  // String? selectedCategory;
  final newCardTitleProvider = StateProvider<String>((ref) => '');
  final selectedCategoryProvider = StateProvider<String?>((ref) => null);
  final imageUrlProvider = StateProvider<String?>((ref) => null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? imageUrl = ref.read(imageUrlProvider);
    String? selectedCategory = ref.read(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              height: 350,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kwhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  imageUrl == null
                      ? Image.asset(
                          'assets/add_image_icon.png',
                          fit: BoxFit.cover,
                          height: 150,
                        )
                      : Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          height: 150,
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
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      hint: const Text('Select Category'),
                      items: <String>[
                        'Toys',
                        'Food',
                        'School',
                        'Clothing',
                        'Activities',
                        'Persons',
                        'Places',
                        'Chores'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        ref.read(selectedCategoryProvider.notifier).state = newValue;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  height: 80,
                  width: 150,
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
                                  color: Color.fromARGB(255, 7, 14, 93)),
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
                const SizedBox(width: 10),
                SizedBox(
                  height: 80,
                  width: 150,
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
                            onPressed: () =>
                                _pickImage(ImageSource.gallery, ref),
                            icon: const Icon(
                              Icons.photo_library,
                              color: Color.fromARGB(255, 137, 61, 7),
                            ),
                            label: const Text(
                              'Gallery',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 137, 61, 7)),
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
            if (imageUrl != null) Image.network(imageUrl!),
            ElevatedButton.icon(
                icon: const Icon(Icons.add, color: kwhite),
                onPressed: () => _submitCard(context, ref),
                label: const Text(
                  'Add Card',
                  style: TextStyle(color: kwhite),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainpurple,
                )),
          ],
        ),
      ),
    );
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
        ref1.read(imageUrlProvider.notifier).state = imageUrl;
      } catch (e) {
        print(e);
      }
    }
  }

  void _submitCard(BuildContext context, WidgetRef ref) {
    String newCardTitle = ref.read(newCardTitleProvider);
    String? imageUrl = ref.read(imageUrlProvider);
    String? selectedCategory = ref.read(selectedCategoryProvider);

    if (newCardTitle.isNotEmpty && imageUrl != null) {
      String studentID = ref.watch(studentIdProvider);
      if (studentID != '') {
        print('Selected Category: $selectedCategory'); // for debugging

        FirebaseFirestore.instance.collection('cards').add({
          'title': newCardTitle,
          'userId': studentID,
          'imageUrl': imageUrl,
          'category': selectedCategory,
          'tapCount': 0,
        }).then((_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card added successfully')));
        }).catchError((e) {
          print('Error adding card: $e');
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all fields')));
    }
  }
}
