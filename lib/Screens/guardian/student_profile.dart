// ignore_for_file: unrelated_type_equality_checks, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';

class StudentProfile extends ConsumerStatefulWidget {
  const StudentProfile({super.key});

  static const String route = "/studentprofile";
  static const String path = "/studentprofile";
  static const String name = "StudentProfile";

  @override
  ConsumerState<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends ConsumerState<StudentProfile> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final userName = await FirestoreService().getCurrentUserName();

    setState(() {
      _userName = userName ?? 'Unknown User';
    });
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
                    child: const Column(children: [
                      Text(
                        "Student Name",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: kwhite,
                          fontWeight: FontWeight.w100,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "G8SDgwed3423FSDF",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: kwhite,
                          fontWeight: FontWeight.w100,
                          fontSize: 8,
                        ),
                      ),
                    ]),
                  )),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: screenWidth * 0.7,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'medal.png',
                        height: 40,
                      ),
                      Theme(
                          data: ThemeData(fontFamily: 'Roboto'),
                          child: Column(children: [
                            const Text(
                              "Current Phase",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFF1E1E1E),
                                fontWeight: FontWeight.w100,
                                fontSize: 8,
                              ),
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Phase II",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: mainpurple,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 18,
                                  ),
                                ),
                                Icon(
                                  MdiIcons.fileEdit,
                                  color: dullpurple,
                                )
                              ],
                            )
                          ])),
                      Container(
                          decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kLightPruple,
                            softPink,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(children: [
                        Theme(
                          data: ThemeData(fontFamily: 'Roboto'),
                          child: const Text(
                                  "View Card",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: mainpurple,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 10,
                                  ),
                                ),
                        ),
                        Icon(MdiIcons.eye,color: kwhite,size: 30,)
                      ],),
                      
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 200),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(59),
                    topRight: Radius.circular(59),
                  ),
                  child: Container(
                    color: Colors.white,
                    height: 50,
                    child: const Center(
                        child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 80, 8, 0),
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
