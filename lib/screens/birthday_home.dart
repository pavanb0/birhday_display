import 'package:birhthday_display/api/services/apiservice.dart';
import 'package:birhthday_display/api/services/birthdayService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';

import 'package:shimmer/shimmer.dart';

class BirthdayHome extends StatefulWidget {
  const BirthdayHome({super.key});

  @override
  State<BirthdayHome> createState() => _BirthdayHomeState();
}

class _BirthdayHomeState extends State<BirthdayHome> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;
  Timer? _birthdayChangeTimer;
  Timer? _refreshTimer;
  Timer? _refreshConfeti;
  bool isLoading = true;
  int currentBirthdayIndex = 0;
  String baseUrl = Apiservice().BaserUrl;
  List<Map<String, String>> birthdays = [];
  List<Map<String, String>> upcomingBirthdays = [];

  Future<void> fetchBirthday() async {
    setState(() => isLoading = true);
    try {
      final birthdayService = Birthdayservice();
      final data = await birthdayService.getBirhday();

      if (data.code == 200) {
        final inputFormat = DateFormat("MM/dd/yyyy HH:mm:ss");
        final displayFormat = DateFormat('MMMM d');
        upcomingBirthdays.clear();
        birthdays.clear();

        for (int i = 0; i < (data.dataset?.values[0].values.length ?? 0); i++) {
          final birthdayValue = data.dataset?.values[0].values[i];
          if (birthdayValue?.day == null || birthdayValue?.name == null) continue;
          try {
            final parsedDate = inputFormat.parse(birthdayValue!.day!);
            final String birthdayDate = "${displayFormat.format(parsedDate)} ${DateTime.now().year}";
            upcomingBirthdays.add({
              'name': birthdayValue.name!,
              'date': "Days Remaining ${birthdayValue.dayRemains} for $birthdayDate",
            });
          } catch (e) {
            print("Error parsing date for upcoming birthday: $e");
          }
        }

        for (int i = 0; i < (data.dataset?.values[1].values.length ?? 0); i++) {
          final birthdayValue = data.dataset?.values[1].values[i];
          if (birthdayValue?.day == null || birthdayValue?.name == null) continue;
          try {
            final parsedDate = inputFormat.parse(birthdayValue!.day!);
            final String birthdayDate = "${displayFormat.format(parsedDate)} ${DateTime.now().year}";
            birthdays.add({
              'name': birthdayValue.name!,
              'date': birthdayDate,
              'designation': birthdayValue.designation ?? "",
              'worklocation': birthdayValue.workLocation ?? "",
              'imagePath': birthdayValue.imagePath ?? "",
            });
          } catch (e) {
            print("Error parsing date for birthday: $e");
          }
        }

        setState(() {
          isLoading = false;
          currentBirthdayIndex = 0;
        });

        if (birthdays.isNotEmpty) {
          _confettiController.play();
          _startBirthdayRotation();
        }
      } else {
        print("API error: Code ${data.code}");
      }
    } catch (e) {
      print("Error fetching birthdays: $e");
    }
  }

  void _startBirthdayRotation() {
    _birthdayChangeTimer?.cancel();
    if (birthdays.length > 1) {
      _birthdayChangeTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
        setState(() {
          currentBirthdayIndex = (currentBirthdayIndex + 1) % birthdays.length;
        });
        _confettiController.play();
      });
    }
  }

  void refreshConfeti() {
    _confettiController.play();
  }

  @override
  void initState() {
    super.initState();
    fetchBirthday();
    _refreshTimer = Timer.periodic(const Duration(minutes: 60), (timer) {
      fetchBirthday();
    });
    _refreshConfeti = Timer.periodic(const Duration(seconds: 8), (timer) {
      refreshConfeti();
    });

    _animationController = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    _refreshConfeti?.cancel();
    _birthdayChangeTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
    final String upcomingText =
        upcomingBirthdays.isEmpty
            ? 'No upcoming birthdays!'
            : upcomingBirthdays.map((b) => '${b['name']} - ${b['date']}').join('   |   ');

    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(215, 252, 228, 236),
                      image: DecorationImage(image: AssetImage('assets/images/birthday_pattern.png'), fit: BoxFit.fill),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                fancyTitle(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Today: $todayDate',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Color(0xFF4A00E0),
                                      fontWeight: FontWeight.w500,
                                      shadows: [Shadow(blurRadius: 6, color: Colors.black38, offset: Offset(2, 2))],
                                    ),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Image.asset(
                                      "assets/images/logo-rbg.png",
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child:
                                birthdays.isEmpty
                                    ? const Center(
                                      child: Text(
                                        'No birthdays today!',
                                        style: TextStyle(
                                          fontSize: 36,
                                          color: Color(0xFF4A00E0),
                                          fontWeight: FontWeight.bold,
                                          shadows: [Shadow(blurRadius: 6, color: Colors.black38, offset: Offset(2, 2))],
                                        ),
                                      ),
                                    )
                                    : FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Row(
                                            children: [
                                              // Profile Image
                                              Hero(
                                                tag: 'profile-${birthdays[currentBirthdayIndex]['name']}',
                                                child: Container(
                                                  // width: 200,
                                                  height: MediaQuery.of(context).size.height * 0.80,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Colors.white, width: 4),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.3),
                                                        blurRadius: 10,
                                                        offset: Offset(4, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    child:
                                                        birthdays[currentBirthdayIndex]['imagePath']?.isNotEmpty ??
                                                                false
                                                            ? Image.network(
                                                              "$baseUrl${birthdays[currentBirthdayIndex]['imagePath']!}",
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (context, error, stackTrace) => Image.asset(
                                                                    'assets/images/default_profile.png',
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                            )
                                                            : Icon(Icons.enhance_photo_translate),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 18),
                                              // Details
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Happy Birthday',
                                                      style: GoogleFonts.pacifico(
                                                        textStyle: TextStyle(
                                                          fontSize: 42,
                                                          color: Color(0xFFE91E63),
                                                          fontWeight: FontWeight.bold,
                                                          shadows: [
                                                            Shadow(
                                                              blurRadius: 6,
                                                              color: Colors.black38,
                                                              offset: Offset(2, 2),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      birthdays[currentBirthdayIndex]['name']!,
                                                      style: TextStyle(
                                                        fontSize: 36,
                                                        color: Color(0xFF4A00E0),
                                                        fontWeight: FontWeight.bold,
                                                        shadows: [
                                                          Shadow(
                                                            blurRadius: 6,
                                                            color: Colors.black38,
                                                            offset: Offset(2, 2),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      birthdays[currentBirthdayIndex]['designation']!,
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        color: Color(0xFF8E24AA),
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                    Text(
                                                      birthdays[currentBirthdayIndex]['worklocation']!,
                                                      style: TextStyle(fontSize: 20, color: Color(0xFF4A00E0)),
                                                    ),
                                                    Text(
                                                      birthdays[currentBirthdayIndex]['date']!,
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        color: Color(0xFFE91E63),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                          ),
                          Container(
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8 / 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Upcoming: ',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
                                ),
                                Expanded(
                                  child: Marquee(
                                    text: upcomingText,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Color(0xFFE91E63),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    scrollAxis: Axis.horizontal,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    blankSpace: 30.0,
                                    velocity: 50.0,
                                    pauseAfterRound: const Duration(seconds: 2),
                                    startPadding: 15.0,
                                    accelerationDuration: const Duration(seconds: 1),
                                    accelerationCurve: Curves.linear,
                                    decelerationDuration: const Duration(milliseconds: 500),
                                    decelerationCurve: Curves.easeOut,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: pi, // Upward blast
                      emissionFrequency: 0.05,
                      numberOfParticles: 20,
                      gravity: 0.2,
                      colors: const [
                        Color(0xFFFF4081),
                        Color(0xFFE91E62),
                        Color(0xFF4A00E0),
                        Color(0xFF8E24AA),
                        Color(0xFFFFCA28),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: pi * 2, // Upward blast
                      emissionFrequency: 0.05,
                      numberOfParticles: 20,
                      gravity: 0.2,
                      colors: const [
                        Color(0xFFFF4081),
                        Color(0xFFE91E62),
                        Color(0xFF4A00E0),
                        Color(0xFF8E24AA),
                        Color(0xFFFFCA28),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

Widget fancyTitle() {
  return Shimmer.fromColors(
    baseColor: Color(0xFF4A00E0),
    highlightColor: Color(0xFFFFD700),
    period: Duration(seconds: 2),
    child: Text(
      'Birthday Wishes',
      textAlign: TextAlign.center,
      style: GoogleFonts.pacifico(
        textStyle: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          shadows: [Shadow(blurRadius: 8, color: Colors.black38, offset: Offset(3, 3))],
        ),
      ),
    ),
  );
}


   // : ListView.builder(
                            //   controller: _scrollController,
                            //   scrollDirection: Axis.horizontal,
                            //   itemCount: birthdays.length,
                            //   itemBuilder: (context, index) {
                            //     final birthday = birthdays[index];
                            //     return FadeTransition(
                            //       opacity: _fadeAnimation,
                            //       child: ScaleTransition(
                            //         scale: _scaleAnimation,
                            //         child: Container(
                            //           width: MediaQuery.of(context).size.width * 0.35,
                            //           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                            //           padding: const EdgeInsets.all(24),
                            //           decoration: BoxDecoration(
                            //             color: Colors.white,
                            //             borderRadius: BorderRadius.circular(20),
                            //             border: Border.all(color: const Color(0xFFFF4081), width: 2),
                            //             boxShadow: const [
                            //               BoxShadow(
                            //                 color: Colors.black26,
                            //                 blurRadius: 10,
                            //                 offset: Offset(0, 4),
                            //               ),
                            //             ],
                            //           ),
                            //           child: Column(
                            //             mainAxisAlignment: MainAxisAlignment.center,
                            //             children: [
                            //               if (birthday['imagePath']?.isNotEmpty ?? false)
                            //                 ClipOval(
                            //                   child: Image.asset(
                            //                     birthday['imagePath']!,
                            //                     width: 100,
                            //                     height: 100,
                            //                     fit: BoxFit.cover,
                            //                     errorBuilder:
                            //                         (context, error, stackTrace) => const Icon(
                            //                           Icons.cake,
                            //                           size: 80,
                            //                           color: Color(0xFF4A00E0),
                            //                         ),
                            //                   ),
                            //                 )
                            //               else
                            //                 const Icon(
                            //                   Icons.cake,
                            //                   size: 80,
                            //                   color: Color.fromARGB(0, 11, 173, 162),
                            //                 ),
                            //               const SizedBox(height: 12),
                            //               Text(
                            //                 birthday['name']!,
                            //                 style: const TextStyle(
                            //                   fontSize: 28,
                            //                   fontWeight: FontWeight.bold,
                            //                   color: Color(0xFF4A00E0),
                            //                 ),
                            //                 textAlign: TextAlign.center,
                            //               ),
                            //               const SizedBox(height: 8),
                            //               Text(
                            //                 birthday['date']!,
                            //                 style: const TextStyle(fontSize: 20, color: Colors.grey),
                            //               ),
                            //               const SizedBox(height: 10),
                            //               Text(
                            //                 "Designation: ${birthday['designation']!}",
                            //                 style: const TextStyle(
                            //                   fontSize: 16,
                            //                   fontStyle: FontStyle.italic,
                            //                   color: Colors.black87,
                            //                 ),
                            //                 textAlign: TextAlign.center,
                            //               ),
                            //               const SizedBox(height: 6),
                            //               Text(
                            //                 "Location: ${birthday['worklocation']!}",
                            //                 style: const TextStyle(
                            //                   fontSize: 16,
                            //                   fontStyle: FontStyle.italic,
                            //                   color: Colors.black87,
                            //                 ),
                            //                 textAlign: TextAlign.center,
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),



