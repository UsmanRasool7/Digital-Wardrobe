import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/custom_bottom_nav.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();

  final PageController pageController = PageController(initialPage: 1000);
  final DateTime initialWeekStart = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday - 1),
  );
  int selectedIndex = 0;

  // Weather variables
  String weatherDescription = '';
  double temperature = 0.0;
  String weatherIcon = '';
  Color weatherColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    fetchWeatherForDate(selectedDate);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  DateTime _getDateForPage(int pageIndex) {
    int weekOffset = pageIndex - 1000;
    return initialWeekStart.add(Duration(days: weekOffset * 7));
  }

  List<DateTime> _getWeekDates(DateTime refDate) {
    final startOfWeek = refDate.subtract(Duration(days: refDate.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> fetchWeatherForDate(DateTime date) async {
    final String apiKey = '94abe65ce4454ca00732e54f17071b2e';
    final String city = 'Lahore'; // You can make this dynamic
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherDescription = data['weather'][0]['description'];
          temperature = data['main']['temp'];
          weatherIcon = data['weather'][0]['icon'];

          if (weatherDescription.contains('rain')) {
            weatherColor = Colors.blueGrey;
          } else if (weatherDescription.contains('clear')) {
            weatherColor = Colors.orangeAccent;
          } else if (weatherDescription.contains('cloud')) {
            weatherColor = Colors.blueGrey[300]!;
          } else {
            weatherColor = Colors.grey;
          }
        });
      }
    } catch (e) {
      print('Weather fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('EEEE').format(selectedDate),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          if (weatherDescription.isNotEmpty)
                            Row(
                              children: [
                                Image.network(
                                  'http://openweathermap.org/img/wn/$weatherIcon.png',
                                  width: 35,
                                  height: 35,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${temperature.toStringAsFixed(1)}°C',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: weatherColor,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Text(
                        DateFormat('d MMM y').format(selectedDate),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert),
                ],
              ),
            ),

            // Week Calendar
            SizedBox(
              height: 80,
              child: PageView.builder(
                controller: pageController,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index) {
                  DateTime newDate = _getDateForPage(index);
                  setState(() {
                    selectedDate = newDate;
                  });
                  fetchWeatherForDate(newDate);
                },
                itemBuilder: (context, index) {
                  DateTime weekStart = _getDateForPage(index);
                  List<DateTime> week = _getWeekDates(weekStart);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: week.map((day) {
                      bool isToday = isSameDay(day, DateTime.now());
                      bool isSelected = isSameDay(day, selectedDate);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = day;
                          });
                          fetchWeatherForDate(day);
                        },
                        child: Container(
                          width: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.limeAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('E').format(day),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isToday ? Colors.blue : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.black : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Empty Planner
            Expanded(
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddItemsPage()),
                        );
                      },
                      child: const Icon(Icons.add_circle, color: Colors.blue, size: 60),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("No items in wardrobe."),
                  const Text("Add items to start planning."),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
      ),
    );
  }
}

class AddItemsPage extends StatelessWidget {
  final DateTime? selectedDate;

  const AddItemsPage({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 28),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Add Items",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: const Icon(Icons.camera_alt, color: Colors.blue, size: 32),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: const Text(
                "Camera roll",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
                  backgroundColor: Colors.cyanAccent[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {},
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 28),
              ),
            ),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Photo library permission denied",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
