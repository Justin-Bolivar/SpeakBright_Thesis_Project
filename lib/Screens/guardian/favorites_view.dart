import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  static const String route = "/FavoritesView";
  static const String path = "/FavoritesView";
  static const String name = "FavoritesView";

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView> {
  List<DocumentSnapshot> _cards = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String studentID;

  @override
  void initState() {
    super.initState();
    studentID = ref.read(studentIdProvider.notifier).state;
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('favorites')
          .doc(studentID)
          .collection('cards')
          .orderBy('rank')
          .get();
      setState(() {
        _cards = snapshot.docs;
      });
    } catch (e) {
      print('Error loading cards: $e');
    }
  }

  Future<void> _updateCardRanks() async {
    try {
      for (int i = 0; i < _cards.length; i++) {
        await _firestore
            .collection('favorites')
            .doc(studentID)
            .collection('cards')
            .doc(_cards[i].id)
            .update({
          'rank': i + 1,
        });
      }
    } catch (e) {
      print('Error updating card ranks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Cards'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/fave-bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _cards.isEmpty
                    ? Center(child: Text('Add Favorite Cards First!'))
                    : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ReorderableListView(
                          children: _cards.map((DocumentSnapshot card) {
                            final colorIndex = _cards.indexOf(card) % boxColors.length;
                            return ListTile(
                              key: Key(card.id),
                              tileColor: boxColors[colorIndex],
                              leading: Text((_cards.indexOf(card) + 1).toString()),
                              title: Text(card['title']),
                              trailing: const Icon(Icons.drag_handle),
                            );
                          }).toList(),
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              final DocumentSnapshot item = _cards.removeAt(oldIndex);
                              _cards.insert(newIndex, item);
                            });
                            _updateCardRanks();
                          },
                        ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
