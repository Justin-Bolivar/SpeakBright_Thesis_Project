import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speakbright_mobile/Screens/auth/auth_controller.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardItem extends StatefulWidget {
  final CardModel card;
  final int colorIndex;
  final VoidCallback onTap;
  final Function(String) onDelete;

  const CardItem({
    super.key,
    required this.card,
    required this.colorIndex,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  Future<bool> isUserAGuardian(String? uid) async {
    CollectionReference userGuardianCollection =
        FirebaseFirestore.instance.collection('user_guardian');
    final DocumentSnapshot userDocument =
        await userGuardianCollection.doc(uid).get();

    return userDocument.exists && userDocument.get('userType') == 'guardian';
  }

  @override
  Widget build(BuildContext context) {
    Color itemColor = boxColors[widget.colorIndex % boxColors.length];
    Future<bool> isGuardian =
        isUserAGuardian(AuthController.I.currentUser?.uid);

    return FutureBuilder<bool>(
      future: isGuardian,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        bool isCurrentGuardian = snapshot.data ?? false;

        return GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kwhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kblack.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 1,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildImageContainer(itemColor),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        widget.card.title,
                        style: TextStyle(
                          color: itemColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentGuardian)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to remove the card?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                widget.onDelete(widget.card.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageContainer(Color color) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width * 0.35,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.transparent,
          ),
          child: _buildImage(color),
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
            color: color,
            size: 40,
          ),
        )
      ],
    );
  }

  Widget _buildImage(Color color) {
    if (widget.card.imageUrl.isEmpty) {
      return Icon(Icons.image, color: color);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: CachedNetworkImage(
        imageUrl: widget.card.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: color,
          ),
        ),
        errorWidget: (context, url, error) {
          print('Error loading image: $error');
          return Icon(Icons.image_not_supported, color: color);
        },
      ),
    );
  }
}
