// ignore_for_file: unrelated_type_equality_checks, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakbright_mobile/Screens/auth/auth_controller.dart';
import 'package:speakbright_mobile/Screens/auth/register_student.dart';
import 'package:speakbright_mobile/Widgets/student_list.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import '../../Routing/router.dart';

class GuardianHomepage extends ConsumerStatefulWidget {
  const GuardianHomepage({super.key});

  static const String route = "/guardianhome";
  static const String path = "/guardianhome";
  static const String name = "GuardianHomepage";

  @override
  ConsumerState<GuardianHomepage> createState() => _GuardianHomepageState();
}

class _GuardianHomepageState extends ConsumerState<GuardianHomepage> {
  late String _userName;

  @override
  void initState() {
    super.initState();
    _userName = 'Unknown User';
    _fetchUserName();
    
  }

  Future<void> _fetchUserName() async {
    final userName = await FirestoreService().getCurrentUserName();
    setState(() {
      _userName = userName ?? 'Unknown User';
    });
  }

  Widget responsiveText(String text, BuildContext context,
      {double fontSizeMax = 25, double fontSizeMin = 5}) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      double calculatedFontSize = fontSizeMin +
          ((fontSizeMax - fontSizeMin) / 2) *
              (width / (MediaQuery.of(context).size.width * 0.23));

      calculatedFontSize = calculatedFontSize.clamp(fontSizeMin, fontSizeMax);

      return Text(
        text,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: kwhite,
          fontWeight: FontWeight.w200,
          fontSize: calculatedFontSize,
        ),
        textAlign: TextAlign.center,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Image.asset(
                      'assets/SpeakBright.png',
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: kwhite,
                        size: 18,
                      ),
                      onPressed: () {
                        WaitingDialog.show(context,
                            future: AuthController.I.logout());
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(59),
                    topRight: Radius.circular(59),
                  ),
                  child: Container(
                    color: Colors.white,
                    height: 180, // Adjust as needed
                    child: const Center(
                        child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 80, 8, 0),
                      child: StudentList(),
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 150,
          left: (MediaQuery.of(context).size.width -
                  (MediaQuery.of(context).size.width * 0.8)) /
              2,
          child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    kLightPruple,
                    softPink,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: mainpurple,
                    blurRadius: 16.5,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: ThemeData(fontFamily: 'Roboto'),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome,",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: kwhite,
                              fontWeight: FontWeight.w100,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              color: kwhite,
                              fontWeight: FontWeight.w100,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(children: [
                            Image.asset(
                              'assets/idea.png',
                              width: 15,
                              fit: BoxFit.contain,
                            ),
                            const Text(
                              "Currently, you have 100 students",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: kwhite,
                                fontWeight: FontWeight.w100,
                                fontSize: 10,
                              ),
                            ),
                          ])
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 30, 20),
                      child: InkWell(
                        onTap: () {
                          GlobalRouter.I.router.push(RegistrationStudent.route);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.23,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(167, 110, 166, 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DottedBorder(
                            dashPattern: const [10, 5],
                            strokeWidth: 1,
                            color: Colors.white,
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            padding: const EdgeInsets.all(14),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  responsiveText("Add Student", context),
                                  const SizedBox(height: 5),
                                  Image.asset('assets/addCard.png',
                                      height: 25, fit: BoxFit.contain),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ],
    ));
  }
}
