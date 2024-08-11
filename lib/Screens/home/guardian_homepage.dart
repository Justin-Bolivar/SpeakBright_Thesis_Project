// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speakbright_mobile/Screens/auth/register_student.dart';
import 'package:speakbright_mobile/Screens/home/communicate.dart';
import 'package:speakbright_mobile/Screens/home/explore.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/header_container.dart';

import '../../Routing/router.dart';

class GuardianHomepage extends ConsumerStatefulWidget {
  const GuardianHomepage({super.key});

  static const String route = "/guardianhome";
  static const String path = "/guardianhome";
  static const String name = "GuardianHomepage";

  @override
  ConsumerState<GuardianHomepage> createState() => _GuardianHomepageState();
}

class _GuardianHomepageState extends ConsumerState<GuardianHomepage> {
  final FlutterTts flutterTts = FlutterTts();
  final intro = "You have selected";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double baseFontSize = screenWidth * 0.045;
    double imageHeight = screenWidth * 0.2;
    return Scaffold(
      backgroundColor: kwhite,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              height: max(screenHeight * 0.2, 240),
              child: const RainbowContainer(),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              width: screenWidth * 0.85,
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      switch (index) {
                        case 0:
                          GlobalRouter.I.router.push(RegistrationStudent.route);
                          break;
                        case 1:
                        // student list??
                          // GlobalRouter.I.router.push(Explore.route);
                          break;

                        default:
                          print('Unknown card tapped');
                          break;
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  [
                                    'Register Student',
                                    'Student List',
                                  ][index],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: baseFontSize),
                                ),
                                Text(
                                  [
                                    'Register a student',
                                    'Check your students'
                                  ][index],
                                  style:
                                      TextStyle(fontSize: baseFontSize * 0.8),
                                ),
                              ],
                            ),
                            Image.asset(
                              [
                                'assets/communicate.png',
                                'assets/test_books.png',
                              ][index],
                              height: imageHeight,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
