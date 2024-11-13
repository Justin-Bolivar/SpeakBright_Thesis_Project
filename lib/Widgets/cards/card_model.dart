import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {
  final String id;
  final String title;
  final String imageUrl;
  final String userId;
  final String category;
  final int tapCount;
  final bool isFavorite;
  final bool phase1_independence;
  final bool phase2_independence;
  final bool phase3_independence;


  CardModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.userId,
    required this.category,
    required this.tapCount,
    required this.isFavorite,
    required this.phase1_independence,
    required this.phase2_independence,
    required this.phase3_independence,


  });

  factory CardModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return CardModel(
    id: doc.id,
    title: data['title'] ?? '',
    imageUrl: data['imageUrl'] ?? '',
    userId: data['userId'] ?? '',
    category: data['category'] ?? '',
    tapCount: data['tapCount'] ?? 0,
    isFavorite: data['isFavorite'] as bool? ?? false,  
    phase1_independence: data['phase1_independence'] as bool? ?? false,  
    phase2_independence: data['phase2_independence'] as bool? ?? false,  
    phase3_independence: data['phase3_independence'] as bool? ?? false,  
  );
}

}
