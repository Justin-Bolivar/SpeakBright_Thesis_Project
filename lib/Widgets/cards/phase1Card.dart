import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';

class Phase1Card extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const Phase1Card({
    Key? key,
    required this.card,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 254, 251, 238),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImage(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: CachedNetworkImage(
          imageUrl: card.imageUrl,
          height: MediaQuery.of(context).size.height * 0.4,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: const WaitingDialog(),
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
