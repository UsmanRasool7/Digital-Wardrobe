import 'package:flutter/material.dart';
import 'package:test_app/widgets/custom_bottom_nav.dart'; // Import your custom bottom nav bar

class StylingPage extends StatefulWidget {
  const StylingPage({super.key});

  @override
  State<StylingPage> createState() => _StylingPageState();
}

class _StylingPageState extends State<StylingPage> {
  int _currentIndex = 1; // Bottom Nav selected index
  int _selectedTab = 0;  // 0 = Dress Me, 1 = Canvas, 2 = Moodboards

  final List<String> _tabs = ['Dress Me', 'Canvas', 'Moodboards'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Top Tabs with Sliding Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_tabs.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = index;
                    });
                    // Empty onPressed for now
                  },
                  child: Column(
                    children: [
                      Text(
                        _tabs[index],
                        style: TextStyle(
                          fontWeight: _selectedTab == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                          color: _selectedTab == index
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        width: 40,
                        color: _selectedTab == index
                            ? Colors.black
                            : Colors.transparent,
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            // Green Arrow Button
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lime,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 90),
            // Add Tops
            _buildAddItem('Add Tops'),
            const SizedBox(height: 30),
            // Add Bottoms
            _buildAddItem('Add Bottoms'),
            const SizedBox(height: 30),
            // Add Footwear
            _buildAddItem('Add Footwear'),
            const Spacer(),
            // Dress Me Button
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[100],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Dress Me',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle bottom nav tap navigation if needed
        },
      ),
    );
  }

  Widget _buildAddItem(String text) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.lightBlueAccent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
