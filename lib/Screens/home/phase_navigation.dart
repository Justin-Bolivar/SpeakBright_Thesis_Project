import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakbright_mobile/Routing/router.dart';
import 'package:speakbright_mobile/Screens/home/learn_phase1.dart';
import 'package:speakbright_mobile/Screens/home/learn_phase2.dart';
import 'package:speakbright_mobile/Screens/home/learn_phase3.dart';
import 'package:speakbright_mobile/Screens/home/learn_phase4.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';
import 'package:speakbright_mobile/Widgets/waiting_dialog.dart';

class PhaseNav extends ConsumerStatefulWidget {
  const PhaseNav({super.key});

  static const String route = "/phasenav";
  static const String path = "/phasenav";
  static const String name = "Phase Nav";

  @override
  ConsumerState<PhaseNav> createState() => _PhaseNavState();
}

class _PhaseNavState extends ConsumerState<PhaseNav> {
  late final Future<int> _currentPhaseFuture;

  @override
  void initState() {
    super.initState();
    _currentPhaseFuture = FirestoreService().fetchPhase();
    // FirestoreService().updatePhase1Independence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sky,
        shadowColor: lGray,
      ),
      backgroundColor: sky,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/phase/phases-bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 65,
              child: Column(
                children: [
                  Text(
                    'PHASES',
                    style: GoogleFonts.rubikSprayPaint(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    'To unlock phases, modify in student profile',
                    style: GoogleFonts.roboto(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.normal,
                        fontSize: 10,
                        color: dullWhite),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 80,
              right: 110,
              child: InkWell(
                onTap: ()  {
                  FirestoreService().updatePhase1Independence();
                  GlobalRouter.I.router.push(Learn1.route);
                },
                child: Image.asset('assets/phase/P1.png', height: 115),
              ),
            ),
            FutureBuilder<int>(
              future: _currentPhaseFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int currentPhase = snapshot.data!;
                  return Stack(
                    children: [
                      Positioned(
                        bottom: 260,
                        left: 100,
                        child: _buildPhaseButton(
                            currentPhase, 2, 'P2', 'P2-lock', Learn2.route),
                      ),
                      Positioned(
                        bottom: 440,
                        right: 80,
                        child: _buildPhaseButton(
                            currentPhase, 3, 'P3', 'P3-lock', Learn3.route),
                      ),
                      Positioned(
                        top: 235,
                        left: 80,
                        child: _buildPhaseButton(
                            currentPhase, 4, 'P4', 'P4-lock', Learn4.route),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return const Center(child: WaitingDialog());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseButton(int currentPhase, int phaseNumber,
      String unlockedAsset, String lockedAsset, String routeName) {
    bool isLocked = phaseNumber > currentPhase;
    return InkWell(
      onTap: isLocked
          ? () => Fluttertoast.showToast(msg: "Oops Phase locked")
          : () => GlobalRouter.I.router.push(routeName) , 
      child: Image.asset(
          isLocked
              ? 'assets/phase/$lockedAsset.png'
              : 'assets/phase/$unlockedAsset.png',
          height: 115),
    );
  }
}
