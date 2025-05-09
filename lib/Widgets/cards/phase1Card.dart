// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';

class Phase1Card extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;
  final double widthFactor;
  final double heightFactor;
  final double fontSize;

  const Phase1Card({
    super.key,
    required this.card,
    required this.onTap,
    this.widthFactor = 0.5, // Default
    this.heightFactor = 0.5,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * widthFactor,
        height: MediaQuery.of(context).size.height * heightFactor,
        decoration: BoxDecoration(
          color: kwhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.9),
              spreadRadius: 5,
              blurRadius: 9,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildImage(context),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      card.title,
                      style: GoogleFonts.roboto(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: lGray,
                      ),
                    ),
                  ),
                ],
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
                child: const Icon(
                  Icons.music_note,
                  color: ugYellow,
                  size: 40,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (card.imageUrl.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 50,
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * widthFactor,
        height: MediaQuery.of(context).size.height * (heightFactor * 0.8),
        child: CachedNetworkImage(
          imageUrl: card.imageUrl,
          fit: BoxFit.fill,
          placeholder: (context, url) => const Center(
            child: WaitingDialog(),
          ),
          errorWidget: (context, url, error) => Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}
