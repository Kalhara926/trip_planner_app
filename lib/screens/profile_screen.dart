// File: lib/screens/profile_screen.dart

import 'package:flutter/material.dart';

import 'package.flutter/material.dart';
import 'package:trip_planner_app/screens/carbon_tracker_screen.dart';
import 'package:trip_planner_app/screens/currency_converter_screen.dart';
import 'package:trip_planner_app/screens/document_wallet_screen.dart';
import 'package:trip_planner_app/screens/emergency_contacts_screen.dart';
import 'package:trip_planner_app/screens/health_info_screen.dart'; // Health Info screen එක import කිරීම
import 'package:trip_planner_app/screens/loyalty_programs_screen.dart';
import 'package:trip_planner_app/screens/notification_settings_screen.dart';
import 'package:trip_planner_app/screens/power_info_screen.dart';
import 'package:trip_planner_app/screens/tip_calculator_screen.dart';
import 'package:trip_planner_app/screens/travel_insurance_screen.dart';
import 'package:trip_planner_app/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String userName = 'Sophia Carter';
    const String userLevel = 'Level 2 Traveller';
    const String avatarUrl =
        'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=2680&auto=format&fit=crop';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(avatarUrl, userName, userLevel),
              const SizedBox(height: 24),
              _buildAchievementsCard(),
              const SizedBox(height: 24),
              _buildToolsAndSettingsList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String avatarUrl, String name, String level) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(avatarUrl),
          backgroundColor: Colors.grey[300],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(level, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAchievementsCard() {
    return Card(
      color: const Color(0xFF1E3A3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBadge(Icons.explore, 'Explorer'),
                _buildBadge(Icons.landscape, 'Adventurer'),
                _buildBadge(Icons.eco, 'Eco-traveller'),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),
            const Text(
              'Leaderboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildLeaderboardEntry('1. Sophia Carter', '12,345 points'),
            _buildLeaderboardEntry('2. Ethan Bennett', '11,872 points'),
            _buildLeaderboardEntry('3. Olivia Hayes', '10,543 points'),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white.withOpacity(0.1),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLeaderboardEntry(String name, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white)),
          Text(points, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildToolsAndSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildListTile(
            context,
            icon: Icons.message_rounded,
            title: 'Direct Messages',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.contact_emergency_rounded,
            title: 'Emergency Contacts',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EmergencyContactsScreen(),
              ),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.wallet_rounded,
            title: 'Document Wallet',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DocumentWalletScreen(),
              ),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.loyalty_rounded,
            title: 'Loyalty Programs',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LoyaltyProgramsScreen(),
              ),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.shield_rounded,
            title: 'Travel Insurance',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TravelInsuranceScreen(),
              ),
            ),
          ),
          // --- මෙතන යාවත්කාලීන කර ඇත ---
          _buildListTile(
            context,
            icon: Icons.health_and_safety_rounded,
            title: 'Health & Vaccination',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HealthInfoScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            context,
            icon: Icons.currency_exchange_rounded,
            title: 'Currency Converter',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CurrencyConverterScreen(),
              ),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.calculate_rounded,
            title: 'Tip Calculator',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TipCalculatorScreen(),
              ),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.translate_rounded,
            title: 'Translation Tool',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.power_rounded,
            title: 'Power Plugs & Voltage',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PowerInfoScreen()),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.eco_rounded,
            title: 'Carbon Footprint Tracker',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CarbonTrackerScreen(),
              ),
            ),
          ),
          const Divider(height: 1),
          _buildListTile(
            context,
            icon: Icons.notifications_rounded,
            title: 'Notification Settings',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: () => AuthService().signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
