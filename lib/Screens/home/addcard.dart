// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});
  static const String route = '/addcard';
  static const String path = "/addcard";
  static const String name = "Add Card";

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  String newCardTitle = '';
  String? imageUrl;
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  newCardTitle = value;
                });
              },
              decoration: const InputDecoration(hintText: "Enter card title"),
            ),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text('Select Category'),
              items: <String>['Toys', 'Food', 'School', 'Clothing', 'Activities', 'Persons', 'Favourites', 'Places', 'Chores']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  height: 80, // Enforce a minimum height for the button area
                  width: 220, // Take full width, adjust as needed
                  child: Stack(
                    alignment: Alignment.center, // Center the container within the stack
                    children: [
                      Container(
                        height: 60, // Smaller height for the button container
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8), // Optional: Adds rounded corners
                          gradient: const LinearGradient(
                            colors: [
                              Colors.blue, // Gradient starts with blue
                              Color.fromARGB(137, 24, 51, 186), // Gradient transitions to skyBlue
                            ],
                          ),
                        ),
                        child: Center( // Center the button within the container
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded, color: Color.fromARGB(255, 7, 14, 93),),
                            label: const Text('Take Photo', style: TextStyle(color: Color.fromARGB(255, 7, 14, 93)),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Make the button transparent to show the gradient
                              shadowColor: Colors.transparent, // Remove shadow
                              elevation: 0, // Remove elevation
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
                const SizedBox(width: 20),

                SizedBox(
                  height: 80, // Enforce a minimum height for the button area
                  width: 220, // Take full width, adjust as needed
                  child: Stack(
                    alignment: Alignment.center, // Center the container within the stack
                    children: [
                      Container(
                        height: 60, // Smaller height for the button container
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8), // Optional: Adds rounded corners
                          gradient: const LinearGradient(
                            colors: [
                              Colors.yellow, // Gradient starts with yellow
                              Colors.orange, // Gradient transitions towards orange for a dandelion effect
                            ],
                          ),
                        ),
                        child: Center( // Center the button within the container
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, color: Color.fromARGB(255, 137, 61, 7),),
                            label: const Text('Browse Gallery', style: TextStyle(color: Color.fromARGB(255, 137, 61, 7)),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Make the button transparent to show the gradient
                              shadowColor: Colors.transparent, // Remove shadow
                              elevation: 0, // Remove elevation
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        // left: 10,
                        right: 0,
                        top: 0,
                        child: Image.asset(
                          'assets/album.png',
                          fit: BoxFit.cover,
                          height: 55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (imageUrl != null) Image.network(imageUrl!),
            ElevatedButton(
              onPressed: _submitCard,
              child: const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);

    if (photo != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/$uniqueFileName');
      try {
        await ref.putFile(File(photo.path));
        imageUrl = await ref.getDownloadURL();
        setState(() {});
      } catch (e) {
        print(e);
      }
    }
  }

  void _submitCard() {
    if (newCardTitle.isNotEmpty && imageUrl != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Selected Category: $selectedCategory');

        FirebaseFirestore.instance.collection('cards').add({
          'title': newCardTitle,
          'userId': user.uid,
          'imageUrl': imageUrl,
          'category': selectedCategory,

          
        }).then((_) {
          Navigator.pop(context); // Close the AddCardPage
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
