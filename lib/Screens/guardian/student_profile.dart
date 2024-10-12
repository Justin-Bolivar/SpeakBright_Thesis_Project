// ignore_for_file: unrelated_type_equality_checks, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:speakbright_mobile/Routing/router.dart';
import 'package:speakbright_mobile/Screens/home/guardian_cardview.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';

class StudentProfile extends ConsumerStatefulWidget {
  const StudentProfile({super.key});

  static const String route = "/studentprofile";
  static const String path = "/studentprofile";
  static const String name = "StudentProfile";

  @override
  ConsumerState<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends ConsumerState<StudentProfile> {
  late String studentID;
  final FirestoreService _firestoreService = FirestoreService();
  int? _currentPhase;

  @override
  void initState() {
    super.initState();
    studentID = ref.read(studentIdProvider.notifier).state;
    _loadInitialPhase();
  }

  Future<void> _loadInitialPhase() async {
    final phase = await fetchPhase();
    setState(() {
      _currentPhase = phase;
    });
  }

  void _handleTap() {
    GlobalRouter.I.router.push(GuardianCommunicate.route);
  }

  void selectPhase(BuildContext context) async {
    List<int> options = [1, 2, 3, 4];
    int? _selectedValue = _currentPhase;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(
                'Edit Phase',
                style: TextStyle(
                    color: mainpurple,
                    fontSize: 20,
                    fontWeight: FontWeight.w300),
              ),
              content: Row(
                children: [
                  Text("Student is in Phase  "),
                  DropdownButton<int>(
                    value: _selectedValue,
                    icon: Icon(
                      MdiIcons.triangleSmallDown,
                      size: 18,
                      color: kLightPruple,
                    ),
                    elevation: 16,
                    style: const TextStyle(color: mainpurple, fontSize: 25),
                    underline: Container(
                      height: 2,
                      color: Colors.purple.withOpacity(0.5),
                    ),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedValue = newValue!;
                      });
                    },
                    items: options.map((option) {
                      return DropdownMenuItem<int>(
                        value: option,
                        child: Text(option.toString()),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                ),
                ElevatedButton(
                  child: Text('Save'),
                  onPressed: () async {
                    await _updateAndCloseDialog(_selectedValue!, context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateAndCloseDialog(
      int selectedPhase, BuildContext context) async {
    await _firestoreService.updateStudentPhase(studentID, selectedPhase);
    setState(() {
      _currentPhase = selectedPhase;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mainpurple,
                  gradientPurple,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Theme(
                    data: ThemeData(fontFamily: 'Roboto'),
                    child: Column(children: [
                      FutureBuilder<String?>(
                        future: _firestoreService.fetchStudentName(studentID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              'Loading...',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: kwhite,
                                fontWeight: FontWeight.w100,
                                fontSize: 25,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: kwhite,
                                fontWeight: FontWeight.w100,
                                fontSize: 25,
                              ),
                            );
                          } else {
                            return Text(
                              snapshot.data ?? 'Unknown Student',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: kwhite,
                                fontWeight: FontWeight.w100,
                                fontSize: 25,
                              ),
                            );
                          }
                        },
                      ),
                      Text(
                        studentID,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: kwhite,
                          fontWeight: FontWeight.w100,
                          fontSize: 8,
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: screenWidth * 0.7,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/medal.png',
                          height: 50,
                        ),
                        Theme(
                          data: ThemeData(fontFamily: 'Roboto'),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Current Phase",
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color(0xFF1E1E1E),
                                  fontWeight: FontWeight.w100,
                                  fontSize: 13,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _currentPhase != null
                                        ? 'Phase $_currentPhase'
                                        : 'Loading...',
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      color: mainpurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () => selectPhase(context),
                                    child: Icon(
                                      MdiIcons.pencil,
                                      size: 15,
                                      color: dullpurple,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: InkWell(
                            onTap: _handleTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    kLightPruple,
                                    softPink,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Theme(
                                      data: ThemeData(fontFamily: 'Roboto'),
                                      child: const Text(
                                        "View Card",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: kwhite,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      MdiIcons.eye,
                                      color: kwhite,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(59),
                      topRight: Radius.circular(59),
                    ),
                    child: Container(
                      color: Colors.white,
                      height: 50,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 80, 8, 0),
                          child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Activity Log",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FutureBuilder<List<String>>(
                                          future:
                                              fetchDates(), // Ensure fetchDates() returns a List<String> after formatting dates
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator(); // Show loading indicator
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}'); // Display error message
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Text(
                                                  'No dates available'); // Display message if no data
                                            } else {
                                              return Container(
                                                height:
                                                    200, // Set a height limit for scrollable content
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: snapshot.data!
                                                        .map((date) {
                                                      return Row(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              date, // Display each fetched date here
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0),
                                                              height: 1,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> fetchDates() async {
    String studID = ref.read(studentIdProvider.notifier).state;

    CollectionReference sessionRef = FirebaseFirestore.instance
        .collection('activity_log')
        .doc(studID)
        .collection('phase')
        .doc(_currentPhase.toString())
        .collection('session');

    QuerySnapshot querySnapshot = await sessionRef.get();

    if (querySnapshot.docs.isNotEmpty) {
      List<String> dates = querySnapshot.docs.map((doc) {
        // Convert Firestore Timestamp to DateTime
        DateTime dateTime = (doc['timestamp'] as Timestamp).toDate();
        // Format to "MM/dd/yyyy" or any preferred format
        return DateFormat('MMMM d, yyyy').format(dateTime);
      }).toList();
      return dates;
    } else {
      print('No session documents found.');
      return [];
    }
  }

  Future<int> fetchPhase() async {
    String studID = ref.read(studentIdProvider.notifier).state;

    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    DocumentSnapshot userDoc = await userRef.doc(studID).get();

    if (userDoc.exists) {
      int currentUserPhase = userDoc.get('phase');
      return currentUserPhase;
    } else {
      print('User document not found.');
      return 1;
    }
  }
}
