import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MyProgressIndicator extends StatelessWidget {
  const MyProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: CircularPercentIndicator(
          radius: 120.0,
          lineWidth: 15.0, 
          animation: true, 
          percent: 60 / 100, 
          center: const Text(
            "60.0%",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ), 
          footer: const Text(
            "Order this Month",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
          ), 
          backgroundColor: const Color.fromARGB(255, 166, 208, 119), 
          circularStrokeCap: CircularStrokeCap
              .round, 
          progressColor: Colors.redAccent,
        ));
  }
}
