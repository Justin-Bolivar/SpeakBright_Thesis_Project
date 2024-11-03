import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PromptProgress extends StatelessWidget {
  const PromptProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 15.0,
              animation: true,
              percent: 60 / 100,
              center: const Text(
                "60%",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              footer: const Text(
                "Testing",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              ),
              backgroundColor: const Color.fromARGB(126, 255, 82, 82),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.redAccent,
            ),
          ],
        ));
  }
}
