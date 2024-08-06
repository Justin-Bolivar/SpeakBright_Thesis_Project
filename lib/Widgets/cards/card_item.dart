// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';

class CardItem extends StatelessWidget {
  final CardModel card;
  final int colorIndex;
  final VoidCallback onTap;
  final Function(String) onDelete;

  const CardItem({
    Key? key,
    required this.card,
    required this.colorIndex,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color itemColor = boxColors[colorIndex % boxColors.length];

    return GestureDetector(
      onTap: onTap,
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
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    card.title,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 15,
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
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ),
        ],
      ),
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
                onDelete(card.id);
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
          height: 100,
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
    if (card.imageUrl.isEmpty) {
      return Icon(Icons.image, color: color);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: CachedNetworkImage(
        imageUrl: card.imageUrl,
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
