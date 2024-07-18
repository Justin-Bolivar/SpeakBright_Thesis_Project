import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speakbright_mobile/Widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Widgets/waiting_dialog.dart';
import '../auth/auth_controller.dart';

class RainbowContainer extends StatefulWidget {
  const RainbowContainer({Key? key}) : super(key: key);

  @override
  _RainbowContainerState createState() => _RainbowContainerState();
}

class _RainbowContainerState extends State<RainbowContainer> {
  late Future<DocumentSnapshot> _userDoc;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userDoc = FirebaseFirestore.instance.collection('users').doc(uid).get();
    } else {
      _userDoc = Future.error('User not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userDoc,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          // Assuming the document exists and has a 'name' and 'birthday' field
          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          String userName = userData['name'] ?? 'User';
          DateTime userBirthday =
              DateTime.parse(userData['birthday'].toDate().toString());

          return Expanded(
            child: SizedBox(
              height: 146,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 145,
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
                              icon: const Icon(Icons.logout,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                WaitingDialog.show(context,
                                    future: AuthController.I.logout());
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
                                      Text(
                                        "Hello $userName!",
                                        style: const TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Center(
                                                // Center the dialog on the screen
                                                child: AlertDialog(
                                                  title: const Text('Profile'),
                                                  content:
                                                      SingleChildScrollView(
                                                    // Allow scrolling if needed
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        Text('Name: $userName',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                            'Birthday: ${DateFormat('MMM dd, yyyy').format(userBirthday)}'), // Format date
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child:
                                                          const Text('Close'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        style: ButtonStyle(
                                          elevation:
                                              WidgetStateProperty.all<double>(
                                                  0),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  dullpurple),
                                        ),
                                        child: const Text('View Profile',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ),
                                    ],
                                  ),
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
        } else {
          // While waiting for the future to complete
          return const CircularProgressIndicator(); // Or a similar loading indicator
        }
      },
    );
  }
}
