import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {
  final String id;
  final String title;
  final String imageUrl;
  final String userId;
  final String category;

  CardModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.userId,
    required this.category,
  });

  factory CardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CardModel(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
    );
  }
}
