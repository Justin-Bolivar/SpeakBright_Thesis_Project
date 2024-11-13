import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Screens/guardian/category_ranking_list.dart';
import 'package:speakbright_mobile/Screens/guardian/favorite_ranking_list.dart';

class CardRankingMenu extends ConsumerStatefulWidget {
  const CardRankingMenu({super.key});

  static const String route = "/CardRankingMenu";
  static const String path = "/CardRankingMenu";
  static const String name = "CardRankingMenu";

  @override
  ConsumerState<CardRankingMenu> createState() => _CardRankingMenuState();
}

class _CardRankingMenuState extends ConsumerState<CardRankingMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Image.asset(
              'assets/menuCloud.png',
              fit: BoxFit.cover,
            ),
            // Other categories like in your original code
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                ),
                itemCount: phase1Categories.length,
                itemBuilder: (context, index) {
                  int colorIndex = index % boxColors.length;
                  Color itemColor = boxColors[colorIndex];

                  return GestureDetector(
                    onTap: () {
                      String selectedCategory = phase1Categories[index];
                      if (index == 0) {
                        // Instead of opening a dialog, we now directly show the FavoriteRankingList
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriteRankingList(),
                          ),
                        );
                      } else {
                        // Pass selectedCategory to CardRankingList
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CardRankingList(
                              selectedCategory: selectedCategory,  // Pass selected category
                            ),
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: itemColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              phase1Categories[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Icon(
                              phase1Icons[index],
                              size: 24,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
