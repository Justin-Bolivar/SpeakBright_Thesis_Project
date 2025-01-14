import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/cards/card_model.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';

class CardGameItem extends StatefulWidget {
  final CardModel card;
  final int colorIndex;
  final bool revealed;
  final VoidCallback onTap;

  const CardGameItem({
    Key? key,
    required this.card,
    required this.colorIndex,
    required this.revealed,
    required this.onTap,
  }) : super(key: key);

  @override
  _CardGameItemState createState() => _CardGameItemState();
}

class _CardGameItemState extends State<CardGameItem> {
  @override
  Widget build(BuildContext context) {
    final itemColor =
        Colors.primaries[widget.colorIndex % Colors.primaries.length];

    return GestureDetector(
      onTap: widget.onTap,
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
                Flexible(
                  flex: 3,
                  child: widget.revealed
                      ? _buildImageContainer(itemColor)
                      : Container(
                          color: itemColor.withOpacity(0.1),
                          child: Center(
                            child: Icon(Icons.question_mark, color: itemColor),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  flex: 1,
                  child: Center(
                    child: Text(
                      widget.revealed ? widget.card.title : '',
                      style: TextStyle(
                        color: itemColor,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildImageContainer(Color itemColor) {
    return Container(
      decoration: BoxDecoration(
        color: itemColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: CachedNetworkImage(
          imageUrl: widget.card.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: WaitingDialog(
              color: itemColor,
            ),
          ),
          errorWidget: (context, url, error) {
            return Icon(Icons.image_not_supported, color: itemColor);
          },
        ),
      ),
    );
  }
}
