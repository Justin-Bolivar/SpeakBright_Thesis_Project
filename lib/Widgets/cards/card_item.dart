// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';

class CardItem extends StatelessWidget {
  final CardModel card;
  final int colorIndex;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CardItem({
    super.key,
    required this.card,
    required this.colorIndex,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Color itemColor = boxColors[colorIndex % boxColors.length];

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
        ],
      ),
    );
  }

  Widget _buildImageContainer(Color color) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(
          width: double.infinity,
          height: 110,
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
