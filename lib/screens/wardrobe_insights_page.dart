import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/repositories/user_repository.dart'; // Import your user repository
import 'package:test_app/services/auth_service.dart'; // Assuming these services exist in your project
import 'package:test_app/services/firestore_service.dart';
import 'package:test_app/services/local_storage_service.dart';

class WardrobeInsightsScreen extends StatefulWidget {
  const WardrobeInsightsScreen({super.key});

  @override
  _WardrobeInsightsScreenState createState() => _WardrobeInsightsScreenState();
}

class _WardrobeInsightsScreenState extends State<WardrobeInsightsScreen> {
  String displayName = '';

  late UserRepository userRepository;

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository(AuthService(), FirestoreService(), LocalStorageService());
    _getUserDisplayName();
  }

  void _getUserDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print(user.uid);
      final userModel = await userRepository.fetchUser();
      if (userModel != null) {
        setState(() {
          displayName = userModel.username;
        });
      } else {
        setState(() {
          displayName = 'User'; // Default value if username is not found
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$displayName\'s Stats'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wardrobe Value Section
            _buildSectionTitle('Wardrobe Value'),
            _buildValueCard('25,000 PKR'),
            const SizedBox(height: 30),

            // Wardrobe Usage Section
            _buildSectionTitle('Wardrobe Usage'),
            _buildUsageCard('You’ve worn 30% of your clothes this month.'),
            const SizedBox(height: 30),

            // Outfits Worn Section
            _buildSectionTitle('Outfits Worn'),
            _buildOutfitsList([
              'Casual Friday Look',
              'Date Night Outfit',
              'Gym Wear',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildValueCard(String value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.account_balance_outlined, color: Colors.deepPurple, size: 30),
            const SizedBox(width: 10),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(String usage) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.pie_chart, color: Colors.deepPurple, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                usage,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitsList(List<String> outfits) {
    return Column(
      children: outfits.map((outfit) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Icon(Icons.checkroom),
            title: Text(outfit),
          ),
        );
      }).toList(),
    );
  }
}
