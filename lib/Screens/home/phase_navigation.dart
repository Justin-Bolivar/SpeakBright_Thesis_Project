import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speakbright_mobile/Widgets/constants.dart';
import 'package:speakbright_mobile/Widgets/services/firestore_service.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
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
                          onTap: () => Navigator.pushNamed(context, '/page1'),
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
                        child: _buildPhaseButton(currentPhase, 2, 'P2', 'P2-lock', '/page2'),
                      ),
                      Positioned(
                        bottom: 440,
                        right: 80,
                        child: _buildPhaseButton(currentPhase, 3, 'P3', 'P3-lock', '/page3'),
                      ),
                      Positioned(
                        top: 235,
                        left: 80,
                        child: _buildPhaseButton(currentPhase, 4, 'P4', 'P4-lock', '/page4'),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseButton(int currentPhase, int phaseNumber, String unlockedAsset, String lockedAsset, String routeName) {
    bool isLocked = phaseNumber > currentPhase;
    return InkWell(
      onTap: isLocked
          ? () => Fluttertoast.showToast(msg: "Oops Phase locked")
          : () => Navigator.pushNamed(context, routeName),
      child: Image.asset(isLocked ? 'assets/phase/$lockedAsset.png' : 'assets/phase/$unlockedAsset.png', height: 115),
    );
  }
}