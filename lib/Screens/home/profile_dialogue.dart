import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileDialogue extends StatelessWidget {
  const ProfileDialogue(
      {required this.name,
      required this.birthday,
      required this.onTap,
      super.key});

  final String name;
  final DateTime birthday;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Apply blur effect
      child: Align(
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(top: 85),
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // White background for content visibility
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            const Text('Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.w200, fontSize: 15)),
                            const SizedBox(
                              height: 12,
                            ),

                            Text(
                              DateFormat('MMM dd, yyyy').format(birthday),
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.amber),
                            ),
                            const Text('Birthday',
                                style: TextStyle(
                                    fontWeight: FontWeight.w200, fontSize: 15)),
                            // Format date
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: onTap,
                          child: Image.asset(
                            'assets/profile.png',
                            fit: BoxFit.cover,
                            height: 170,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(
                            255, 198, 65, 56), // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      child: const Text('Close'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
