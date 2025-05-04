import 'package:hive/hive.dart';

part 'card_transition.g.dart'; 

@HiveType(typeId: 1)
class CardTransition {
  @HiveField(0)
  final String fromCard;

  @HiveField(1)
  final String toCard;

  // Constructor
  CardTransition({
    required this.fromCard,
    required this.toCard
  });
}
