import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../widgets/custom_bottom_nav.dart';
import '../repositories/outfit_history_repository.dart';
import '../models/outfit_history_table.dart';
import '../models/clothing_item_model.dart';

class OutfitDisplay {
  final OutfitHistory history;
  final ClothingItemModel topModel;
  final ClothingItemModel bottomModel;
  final ClothingItemModel footModel;

  OutfitDisplay({
    required this.history,
    required this.topModel,
    required this.bottomModel,
    required this.footModel,
  });
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();
  final pageController = PageController(initialPage: 1000);
  late final DateTime initialWeekStart = DateTime.now()
      .subtract(Duration(days: DateTime.now().weekday - 1));
  int selectedIndex = 0;

  String weatherDescription = '';
  double temperature = 0.0;
  String weatherIcon = '';
  Color weatherColor = Colors.grey;

  final _repo = OutfitHistoryRepository();
  List<OutfitDisplay> outfitsForSelectedDate = [];

  @override
  void initState() {
    super.initState();
    _loadAllForDate(selectedDate);
  }

  void _loadAllForDate(DateTime date) {
    fetchWeatherForDate(date);
    fetchOutfitsForDate(date);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  DateTime _getDateForPage(int pageIndex) =>
      initialWeekStart.add(Duration(days: (pageIndex - 1000) * 7));

  List<DateTime> _getWeekDates(DateTime refDate) {
    final start = refDate.subtract(Duration(days: refDate.weekday - 1));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> fetchWeatherForDate(DateTime date) async {
    const apiKey = '94abe65ce4454ca00732e54f17071b2e';
    const city = 'Lahore';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
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
      debugPrint('Weather fetch error: $e');
    }
  }

  Future<void> fetchOutfitsForDate(DateTime date) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final historyList = await _repo.getOutfitsByDate(date, user.uid);
      final displays = await Future.wait(historyList.map((history) async {
        final topSnap = await FirebaseFirestore.instance
            .collection('clothing_items')
            .doc(history.top.itemId)
            .get();
        final bottomSnap = await FirebaseFirestore.instance
            .collection('clothing_items')
            .doc(history.bottom.itemId)
            .get();
        final footSnap = await FirebaseFirestore.instance
            .collection('clothing_items')
            .doc(history.foot.itemId)
            .get();

        final topModel = ClothingItemModel.fromMap(
            topSnap.data()! as Map<String, dynamic>);
        final bottomModel = ClothingItemModel.fromMap(
            bottomSnap.data()! as Map<String, dynamic>);
        final footModel = ClothingItemModel.fromMap(
            footSnap.data()! as Map<String, dynamic>);

        return OutfitDisplay(
          history: history,
          topModel: topModel,
          bottomModel: bottomModel,
          footModel: footModel,
        );
      }));

      setState(() => outfitsForSelectedDate = displays);
    } catch (e) {
      debugPrint('Error fetching outfits for $date: $e');
    }
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
      );
    } else if (url.isNotEmpty) {
      return Image.file(
        File(url),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // — Header with date & weather
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          DateFormat('EEEE').format(selectedDate),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        if (weatherDescription.isNotEmpty)
                          Row(children: [
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
                                  color: weatherColor),
                            ),
                          ]),
                      ]),
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

            // — Week calendar (unchanged) …
            SizedBox(
              height: 80,
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (i) {
                  final newDate = _getDateForPage(i);
                  setState(() => selectedDate = newDate);
                  _loadAllForDate(newDate);
                },
                itemBuilder: (c, i) {
                  final week = _getWeekDates(_getDateForPage(i));
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: week.map((day) {
                      final isToday = _isSameDay(day, DateTime.now());
                      final isSel = _isSameDay(day, selectedDate);
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedDate = day);
                          _loadAllForDate(day);
                        },
                        child: Container(
                          width: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSel
                                ? Colors.limeAccent
                                : Colors.transparent,
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
                                  color: isSel
                                      ? Colors.black
                                      : Colors.grey[800],
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

            const SizedBox(height: 20),

            // — Display outfits with safe image loading
            Expanded(
              child: outfitsForSelectedDate.isEmpty
                  ? Center(
                child: Text(
                  'No outfits worn on this date.',
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey[600]),
                ),
              )
                  : ListView.builder(
                itemCount: outfitsForSelectedDate.length,
                itemBuilder: (context, i) {
                  final o = outfitsForSelectedDate[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildImage(o.topModel.imageUrl),
                            _buildImage(o.bottomModel.imageUrl),
                            _buildImage(o.footModel.imageUrl),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
