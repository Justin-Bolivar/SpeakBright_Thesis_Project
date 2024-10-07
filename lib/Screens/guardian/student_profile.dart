// ignore_for_file: unrelated_type_equality_checks, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String? _userName;
  late String studentID;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    studentID = ref.read(studentIdProvider.notifier).state;
  }

  Future<void> _fetchUserName() async {
    final userName = await FirestoreService().getCurrentUserName();

    setState(() {
      _userName = userName ?? 'Unknown User';
    });
  }

  void _handleTap() {
    GlobalRouter.I.router.push(GuardianCommunicate.route);
  }

  void _selectPhase(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Phase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: Text('Phase 1'),
              value: 1,
              groupValue: ref.watch(phaseProvider),
              onChanged: (int? value) {
                if (value != null) {
                  ref.read(phaseProvider.notifier).update(value);
                }
              },
            ),
            RadioListTile<int>(
              title: Text('Phase 2'),
              value: 2,
              groupValue: ref.watch(phaseProvider),
              onChanged: (int? value) {
                if (value != null) {
                  ref.read(phaseProvider.notifier).update(value);
                }
              },
            ),
            RadioListTile<int>(
              title: Text('Phase 3'),
              value: 3,
              groupValue: ref.watch(phaseProvider),
              onChanged: (int? value) {
                if (value != null) {
                  ref.read(phaseProvider.notifier).update(value);
                }
              },
            ),
            RadioListTile<int>(
              title: Text('Phase 4'),
              value: 4,
              groupValue: ref.watch(phaseProvider),
              onChanged: (int? value) {
                if (value != null) {
                  ref.read(phaseProvider.notifier).update(value);
                }
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Save'),
            onPressed: () async {
              await ref.read(phaseProvider.notifier).savePhase(studentID);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final phase = ref.watch(phaseProvider);

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
                      const Text(
                        "Student Name",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: kwhite,
                          fontWeight: FontWeight.w100,
                          fontSize: 15,
                        ),
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
                                    'Phase ${phase}',
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
                                    onTap: () => _selectPhase(context),
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
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 80, 8, 0),
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
}
