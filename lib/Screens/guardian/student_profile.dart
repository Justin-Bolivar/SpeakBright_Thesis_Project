// ignore_for_file: unrelated_type_equality_checks, avoid_print, no_leading_underscores_for_local_identifiers, prefer_const_constructors, unused_element, use_build_context_synchronously, prefer_interpolation_to_compose_strings
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:speakbright_mobile/Routing/router.dart';
import 'package:speakbright_mobile/Screens/guardian/card_ranking_menu.dart';
import 'package:speakbright_mobile/Screens/home/guardian_cardview.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
import 'package:speakbright_mobile/providers/student_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  late FrequencyProvider frequencyProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    frequencyProvider = FrequencyProvider(ref);
  }

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

  Future<String?> getStudentReadiness(
      String studentID, int? phaseNumber) async {
    var url = Uri.parse(
        'https://phase-progression-analysis.onrender.com/student_readiness/$studentID/$phaseNumber');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse['readiness_status']);
      return jsonResponse['readiness_status'];
    } else {
      print('Failed to load student readiness: ${response.statusCode}');
      return null;
    }
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
              //change phase
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Move Student ",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                color: jblack,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          ),
                          buildFutureWidget(
                              _firestoreService.fetchStudentName(studentID),
                              'Failed to fetch student name',
                              textStyle: const TextStyle(
                                  fontFamily: 'Roboto',
                                  color: jblack,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20)),
                          const Text(
                            " to other phase?",
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                color: jblack,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          )
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     // Text("Score: ", style: TextStyle(color: lGray, fontFamily: 'Roboto',fontSize: 18),),
                      //     // Text("45", style: TextStyle(color: scoreYellow, fontFamily: 'Roboto',fontSize: 18, fontWeight: FontWeight.w600),),
                      //     buildFutureWidget(
                      //         getStudentReadiness(studentID, _currentPhase),
                      //         'Failed to fetch readiness',
                      //         textStyle: const TextStyle(
                      //             color: scoreYellow,
                      //             fontFamily: 'Roboto',
                      //             fontSize: 21,
                      //             fontWeight: FontWeight.w600)),
                      //   ],
                      // ),
                      // const Text(
                      //   "Student needs more time in the current phase (sample)",
                      //   style: TextStyle(
                      //     fontStyle: FontStyle.italic,
                      //     fontFamily: 'Roboto',
                      //     color: lGray,
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "MOVE TO PHASE  ",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: lGray),
                            ),
                            DropdownButton<int>(
                              value: _selectedValue,
                              icon: Icon(
                                MdiIcons.triangleSmallDown,
                                size: 18,
                                color: kLightPruple,
                              ),
                              elevation: 16,
                              style: const TextStyle(
                                  color: mainpurple,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800),
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
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  child: Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _updateAndCloseDialog(_selectedValue!, context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  child: Text('Save'),
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

  Color _getPhaseColor(int? phase) {
    switch (phase) {
      case 1:
        return Color(0xFF7CB342);
      case 2:
        return Color(0xFFE040FB);
      case 3:
        return Color(0xFF03A9F4);
      case 4:
        return Color(0xFF00897B);
      case 5:
        return Color(0xFFFFA000);
      default:
        return kwhite;
    }
  }

  Widget buildReadinessText(String readiness) {
    String textMessage = readiness == "Ready"
        ? "Student is proficient enough in the current phase"
        : readiness == "Almost Ready"
            ? "Student is close to being proficient in current phase!"
            : "Student needs more time in the current phase";

    return Text(textMessage);
  }

  Widget buildCardContainer(String imageUrl, String label) {
    return Container(
      width: 180, 
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildFutureWidget<T>(Future<T> future, String errorMessage,
      {TextStyle? textStyle}) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            'Loading...',
            style: textStyle ??
                TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.w100,
                  fontSize: 25,
                ),
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: textStyle ??
                TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.w100,
                  fontSize: 25,
                ),
          );
        } else {
          return Text(
            snapshot.data?.toString() ?? 'Unknown',
            style: textStyle ??
                TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  fontWeight: FontWeight.w100,
                  fontSize: 25,
                ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    String imagePath = _currentPhase != null
        ? 'assets/phase/$_currentPhase.png'
        : 'assets/studcard_monster.png';

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
                      buildFutureWidget(
                          _firestoreService.fetchStudentName(studentID),
                          'Failed to fetch student name'),
                      // Text(
                      //   studentID,
                      //   style: const TextStyle(
                      //     fontFamily: 'Roboto',
                      //     color: kwhite,
                      //     fontWeight: FontWeight.w100,
                      //     fontSize: 8,
                      //   ),
                      // ),
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
                        SizedBox(
                          width: 5,
                        ),
                        Image.asset(
                          'assets/medal.png',
                          height: 50,
                        ),
                        Theme(
                          data: ThemeData(fontFamily: 'Roboto'),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phase',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: _getPhaseColor(_currentPhase),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23,
                                ),
                              ),
                              const Text(
                                "Current Phase",
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: softGray,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          imagePath,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('Error');
                          },
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: InkWell(
                            onTap: () => selectPhase(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    ugRed,
                                    ugYellow,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Theme(
                                      data: ThemeData(fontFamily: 'Roboto'),
                                      child: const Text(
                                        "Upgrade",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: kwhite,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Image.asset(
                                      'assets/upgrade.png',
                                      height: 18,
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
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: Container(
                      color: Colors.white,
                      height: 50,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 20, 8, 0),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => GlobalRouter.I.router
                                            .push(GuardianCommunicate.route),
                                        child: Container(
                                          height: 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [
                                              Colors.blue.withOpacity(0.7),
                                              Colors.green.withOpacity(0.7),
                                            ]),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Image.asset(
                                                    'assets/sp-card.png',
                                                    width: 50,
                                                    height: 50),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'View Cards',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => GlobalRouter.I.router
                                            .push(CardRankingMenu.route),
                                        child: Container(
                                          height: 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [
                                              Colors.red.withOpacity(0.7),
                                              Colors.yellow.withOpacity(0.7),
                                            ]),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Image.asset(
                                                    'assets/sp-fave.png',
                                                    width: 50,
                                                    height: 50),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Card Ranking',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "STUDENT PROGRESS",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: jblack),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                FutureBuilder<bool>(
                                  future: preloadCardData(studentID),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    return Expanded(
                                      child: SingleChildScrollView(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Phase 1",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: phase1Color),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Recently Learning",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                    color: jblack),
                                              ),
                                            ),
                                            genericCardScroller(
                                              future: _firestoreService
                                                  .fetchRecentlyLearningSP(
                                                      studentID),
                                              emptyMessage: "No Recent Card.",
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "To be Learned",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                    color: jblack),
                                              ),
                                            ),
                                            genericCardScroller(
                                              future: _firestoreService
                                                  .fetchUnlearnedCardsSP(
                                                      studentID),
                                              emptyMessage:
                                                  "No unlearned cards.",
                                            ),
                                            const SizedBox(height: 10),
                                            const Divider(
                                              color: Colors.grey,
                                              thickness: 1,       
                                              height: 20,        
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Phase 2",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: phase2Color),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Cards in Phase 2",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                    color: jblack),
                                              ),
                                            ),
                                            genericCardScroller(
                                              future: _firestoreService
                                                  .fetchPhase2CardsSP(
                                                      studentID),
                                              emptyMessage:
                                                  "No Phase 2 dependent cards.",
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Phase 2 Independent Cards",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                    color: jblack),
                                              ),
                                            ),
                                            genericCardScroller(
                                              future: _firestoreService
                                                  .fetchPhase2IndependentCardsSP(
                                                      studentID),
                                              emptyMessage:
                                                  "No Phase 2 independent cards.",
                                            ),
                                            const SizedBox(height: 10),
                                            const Divider(
                                              color: Colors.grey,
                                              thickness: 1,       
                                              height: 20,        
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Phase 3",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: phase3Color),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Cards in Phase 3",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                    color: jblack),
                                              ),
                                            ),
                                            genericCardScroller(
                                              future: _firestoreService
                                                  .fetchPhase3CardsSP(
                                                      studentID),
                                              emptyMessage:
                                                  "No Phase 3 dependent cards.",
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Phase 3 Independent Cards",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                    color: jblack),
                                              ),
                                            ),
                                            genericCardScroller(
                                              future: _firestoreService
                                                  .fetchPhase3IndependentCardsSP(
                                                      studentID),
                                              emptyMessage:
                                                  "No Phase 3 independent cards.",
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // SizedBox(
                                //   height: 15,
                                // ),
                                // Align(
                                //   alignment: Alignment.centerLeft,
                                //   child: Text(
                                //     "Activity Log",
                                //     style: TextStyle(
                                //         fontWeight: FontWeight.bold,
                                //         fontSize: 18,
                                //         color: jblack),
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                // Expanded(
                                //   child: SingleChildScrollView(
                                //     child: Row(
                                //       children: [
                                //         Expanded(
                                //           child: FutureBuilder<
                                //               List<Map<String, dynamic>>>(
                                //             future: fetchDatesWithCards(),
                                //             builder: (context, snapshot) {
                                //               if (snapshot.connectionState ==
                                //                   ConnectionState.waiting) {
                                //                 return WaitingDialog();
                                //               } else if (snapshot.hasError) {
                                //                 return Text(
                                //                     'Error: ${snapshot.error}');
                                //               } else if (!snapshot.hasData ||
                                //                   snapshot.data!.isEmpty) {
                                //                 return Text(
                                //                     'No dates available');
                                //               } else {
                                //                 return SingleChildScrollView(
                                //                   child: Column(
                                //                     crossAxisAlignment:
                                //                         CrossAxisAlignment
                                //                             .start,
                                //                     children: snapshot.data!
                                //                         .map((dateWithCards) {
                                //                       return Column(
                                //                         crossAxisAlignment:
                                //                             CrossAxisAlignment
                                //                                 .start,
                                //                         children: [
                                //                           Row(
                                //                             children: [
                                //                               Align(
                                //                                 alignment: Alignment
                                //                                     .centerLeft,
                                //                                 child: Text(
                                //                                   dateWithCards[
                                //                                       'date'],
                                //                                   style: TextStyle(
                                //                                       fontSize:
                                //                                           13,
                                //                                       fontWeight:
                                //                                           FontWeight
                                //                                               .w300,
                                //                                       color:
                                //                                           jblack),
                                //                                 ),
                                //                               ),
                                //                               Expanded(
                                //                                 child:
                                //                                     Container(
                                //                                   margin: const EdgeInsets
                                //                                       .only(
                                //                                       left:
                                //                                           10.0),
                                //                                   height: 1,
                                //                                   color: Colors
                                //                                       .grey,
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                           ),
                                //                           SizedBox(height: 10),
                                //                           SingleChildScrollView(
                                //                             scrollDirection:
                                //                                 Axis.horizontal,
                                //                             child: Row(
                                //                               children: dateWithCards[
                                //                                       'cards']
                                //                                   .map<Widget>(
                                //                                       (cardId) {
                                //                                 return Container(
                                //                                   margin: EdgeInsets
                                //                                       .only(
                                //                                           right:
                                //                                               10),
                                //                                   padding:
                                //                                       EdgeInsets
                                //                                           .all(
                                //                                               8),
                                //                                   decoration:
                                //                                       BoxDecoration(
                                //                                     color: Colors
                                //                                         .purple
                                //                                         .withOpacity(
                                //                                             0.1),
                                //                                     borderRadius:
                                //                                         BorderRadius.circular(
                                //                                             10),
                                //                                   ),
                                //                                   child: Text(
                                //                                     cardId,
                                //                                     style: TextStyle(
                                //                                         fontSize:
                                //                                             15,
                                //                                         color:
                                //                                             jblack),
                                //                                   ),
                                //                                 );
                                //                               }).toList(),
                                //                             ),
                                //                           ),
                                //                           SizedBox(height: 20),
                                //                         ],
                                //                       );
                                //                     }).toList(),
                                //                   ),
                                //                 );
                                //               }
                                //             },
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // )
                              ],
                            ),
                          ),
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

  Future<List<String>> fetchSessionCardTitlesForDate(String date) async {
    String studID = ref.read(studentIdProvider.notifier).state;

    // Reference to the session collection
    CollectionReference cardsRef = FirebaseFirestore.instance
        .collection('activity_log')
        .doc(studID)
        .collection('phase')
        .doc(_currentPhase.toString())
        .collection('session')
        .doc(date)
        .collection('trialPrompt');

    // Fetch the session documents for the date
    QuerySnapshot sessionQuerySnapshot = await cardsRef.get();

    if (sessionQuerySnapshot.docs.isNotEmpty) {
      // Extract the card IDs from the session documents
      List<String> cardIds = sessionQuerySnapshot.docs.map((doc) {
        return doc['cardID'] as String;
      }).toList();

      // Fetch the titles of cards where cardID matches
      List<String> titles = [];
      for (String cardId in cardIds) {
        DocumentSnapshot cardSnapshot = await FirebaseFirestore.instance
            .collection('cards')
            .doc(cardId)
            .get();

        if (cardSnapshot.exists) {
          titles.add(cardSnapshot['title']);
        }
      }

      return titles;
    } else {
      print('No session documents found for date $date.');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDatesWithCards() async {
    String studID = ref.read(studentIdProvider.notifier).state;

    CollectionReference datesRef = FirebaseFirestore.instance
        .collection('activity_log')
        .doc(studID)
        .collection('phase')
        .doc(_currentPhase.toString())
        .collection('session');

    QuerySnapshot datesSnapshot = await datesRef.get();

    List<Map<String, dynamic>> datesWithCards = [];

    for (var dateDoc in datesSnapshot.docs) {
      DateTime timestamp = (dateDoc['timestamp'] as Timestamp).toDate();
      String formattedDate = DateFormat('MMMM d, yyyy').format(timestamp);
      List<String> cardIds = await fetchSessionCardTitlesForDate(dateDoc.id);
      datesWithCards.add({'date': formattedDate, 'cards': cardIds});
    }

    return datesWithCards;
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

  Future<bool> preloadCardData(String studentID) async {
    await _firestoreService.fetchRecentlyLearningSP(studentID);
    return true;
  }

  Widget genericCardScroller({
    required Future<List<Map<String, dynamic>>> future,
    String emptyMessage = "No cards to display.",
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              emptyMessage,
              style: const TextStyle(
                color: lGray,
                fontWeight: FontWeight.w100,
              ),
            ),
          );
        }

        final cards = snapshot.data!;

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return buildCardContainer(card['imageUrl'], card['title']);
            },
          ),
        );
      },
    );
  }
}
