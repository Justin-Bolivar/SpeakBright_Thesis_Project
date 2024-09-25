import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Widgets/prompt/prompt_progress.dart';
import 'package:speakbright_mobile/Widgets/prompt/prompt_button.dart';

class Play extends ConsumerStatefulWidget {
  const Play({super.key});

  static const String route = "/play";
  static const String path = "/play";
  static const String name = "Play";

  @override
  ConsumerState<Play> createState() => _PlayState();
}

class _PlayState extends ConsumerState<Play> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('for testing'),
      ),
      body: const Center(child: PromptProgress()),
      floatingActionButton: const Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: PromptButton(),
        ),
      ),
    );
  }
}