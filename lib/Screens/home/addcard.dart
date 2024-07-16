// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Take Photo'),
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

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/${uniqueFileName}');
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
        FirebaseFirestore.instance.collection('cards').add({
          'Title': newCardTitle,
          'userId': user.uid,
          'imageUrl': imageUrl,
        }).then((_) {
          Navigator.pop(context); // Close the AddCardPage
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
