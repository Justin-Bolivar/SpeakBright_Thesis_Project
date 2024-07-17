import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';

class RainbowContainer extends StatelessWidget {
  const RainbowContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          for (int i = 0; i < boxColors.length; i++)
            Container(
              height: 115 - (i * 5),
              decoration: BoxDecoration(
                color: boxColors[i],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
          Container(
            height: 80,
            decoration: const BoxDecoration(
              color: kwhite,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "HI DONNA!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
