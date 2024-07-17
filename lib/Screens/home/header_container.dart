import 'package:flutter/material.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';

import '../../Widgets/waiting_dialog.dart';
import '../auth/auth_controller.dart';

class RainbowContainer extends StatelessWidget {
  const RainbowContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 160,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              height: 150,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8E2DE2), mainpurple],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                        onPressed: () {
                          WaitingDialog.show(context, future: AuthController.I.logout());
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  "Hello Donnalyn!",
                                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                 ElevatedButton(
                                  //on pressed
                                  onPressed: () async {},
                                  //style section code here
                                  style: ButtonStyle(
                                    
                                    elevation: WidgetStateProperty.all<double>(0),
                                    shape:
                                        WidgetStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    )),
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(dullpurple),
                                  ),
                                  //text to shoe in to the button
                                  child: const Text('View Profile',
                                      style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ],
                            ),
                            
                            // SizedBox(width: 30,),
                            // Image.asset('assets/dash_bg.png', height: 125),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                right: 0,
                top: 55,
                child: Image.asset(
                  'assets/dash_bg.png',
                  fit: BoxFit.cover,
                  height: 100,
                ),
              ),
              Positioned(
                right: 265,
                top: 40,
                child: Image.asset(
                  'assets/explore.png',
                  fit: BoxFit.cover,
                  height: 128,
                ),
              )
          ],
        ),
      ),
    );
  }
}
