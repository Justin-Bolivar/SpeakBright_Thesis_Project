import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Screens/guardian/category_ranking_list.dart';
import 'package:speakbright_mobile/Screens/guardian/favorite_ranking_list.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';

class CardRankingMenu extends ConsumerStatefulWidget {
  const CardRankingMenu({super.key});

  static const String route = "/CardRankingMenu";
  static const String path = "/CardRankingMenu";
  static const String name = "CardRankingMenu";

  @override
  ConsumerState<CardRankingMenu> createState() => _CardRankingMenuState();
}

class _CardRankingMenuState extends ConsumerState<CardRankingMenu> {
  List<String> rankedCategories = List.from(phase1Categories);

  Future<void> saveRankingToFirebase() async {
    final String studentID = ref.watch(studentIdProvider);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> rankedData = rankedCategories.skip(1).toList().asMap().entries.map((entry) {
      return {
        'category': entry.value,
        'rank': entry.key + 2, // Start from rank 2, as "Favorites" is rank 1
      };
    }).toList();

    await firestore.collection('main_category_ranking').doc(studentID).set({'categories': rankedData});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Card Ranking Menu")),
      body: Column(
        children: [
          Image.asset(
            'assets/menuCloud.png',
            height: 200,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: rankedCategories.length,
              onReorder: (oldIndex, newIndex) async {
                if (oldIndex == 0 || newIndex == 0) return; // Keep "Favorites" fixed
                if (newIndex > oldIndex) newIndex--;
                setState(() {
                  final String movedItem = rankedCategories.removeAt(oldIndex);
                  rankedCategories.insert(newIndex, movedItem);
                });
                await saveRankingToFirebase();
              },
              itemBuilder: (context, index) {
                int colorIndex = index % boxColors.length;
                Color itemColor = boxColors[colorIndex];

                return GestureDetector(
                  key: ValueKey(rankedCategories[index]),
                  onTap: () {
                    String selectedCategory = rankedCategories[index];
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FavoriteRankingList()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardRankingList(selectedCategory: selectedCategory),
                        ),
                      );
                    }
                  },
                  child: Card(
                    color: itemColor,
                    child: ListTile(
                      title: Text(
                        rankedCategories[index],
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      leading: Text(
                        index == 0 ? '#1' : "#${index + 1}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      trailing: Icon(phase1Icons[index % phase1Icons.length], color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
