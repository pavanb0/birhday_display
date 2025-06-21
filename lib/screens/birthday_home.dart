import 'package:birhthday_display/api/services/birthdayService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'dart:async';

class BirthdayHome extends StatefulWidget {
  const BirthdayHome({super.key});

  @override
  State<BirthdayHome> createState() => _BirthdayHomeState();
}

class _BirthdayHomeState extends State<BirthdayHome> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late ScrollController _scrollController;
  Timer? _scrollTimer;

  List<Map<String, String>> birthdays = [];

  List<Map<String, String>> upcomingBirthdays = [];

 Future<void> fetchBirhday() async {
  try {
    final birhdatService = Birthdayservice();
    final data = await birhdatService.getBirhday();

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
          });
        } catch (e) {
          print("Error parsing date for birthday: $e");
        }
      }

      setState(() {});
    } else {
      print("API error: Code ${data.code}");
    }
  } catch (e) {
    print("Error fetching birthdays: $e");
  }
}



  @override
  void initState() {
    super.initState();
    fetchBirhday();
    _animationController = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _scrollController = ScrollController();
    if (birthdays.isNotEmpty) {
      _scrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_scrollController.hasClients) {
          double maxExtent = _scrollController.position.maxScrollExtent;
          double currentOffset = _scrollController.offset;
          double nextOffset = currentOffset + MediaQuery.of(context).size.width / 2;

          if (nextOffset >= maxExtent) {
            _scrollController.jumpTo(0);
          } else {
            _scrollController.animateTo(nextOffset, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _scrollTimer?.cancel();
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.yellowAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset("assets/images/logo-rbg.png", width: 48, height: 48, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
          backgroundColor: Colors.deepPurple,
          title: const Text(
            'MAIDC Birthday Wishes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  birthdays.isEmpty
                      ? const Center(
                        child: Text(
                          'No birthdays today!',
                          style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: null,
                        itemBuilder: (context, index) {
                          final birthday = birthdays[index % birthdays.length];
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2,
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.cake, size: 50, color: Colors.deepPurple),
                                    //Image.asset("assets/images/birthday.png", width: 80, height: 50),
                                    Text(
                                      birthday['name']!,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(birthday['date']!, style: TextStyle(fontSize: 20, color: Colors.grey[700])),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Designation :- ${birthday['designation']!} ",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "Location :- ${birthday['worklocation']!}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Text(
                    'Upcoming: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  Expanded(
                    child: Marquee(
                      text: upcomingText,
                      style: const TextStyle(fontSize: 20, color: Colors.teal, fontWeight: FontWeight.w500),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      blankSpace: 20.0,
                      velocity: 50.0,
                      pauseAfterRound: const Duration(seconds: 1),
                      startPadding: 10.0,
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
    );
  }
}
