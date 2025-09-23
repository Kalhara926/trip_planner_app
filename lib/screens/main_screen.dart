// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:trip_planner_app/screens/explore_screen.dart';
import 'package:trip_planner_app/screens/profile_screen.dart';
import 'package:trip_planner_app/screens/saved_screen.dart';
import 'package:trip_planner_app/screens/trips_screen.dart'; // home_screen.dart එක rename කළාට පස්සේ

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Default එක Explore screen එකට තියමු

  // Bottom Nav Bar එකේ තියෙන screens ටික list එකක් විදිහට
  static const List<Widget> _widgetOptions = <Widget>[
    TripsScreen(),
    ExploreScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // IndexedStack එකෙන් screens අතර මාරු වෙනකොට state එක නැති වෙන්නේ නැහැ
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.luggage_outlined),
            activeIcon: Icon(Icons.luggage),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00A3FF),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true, // Unselected labels පෙන්වන්න
        type: BottomNavigationBarType.fixed, // Animation එක fix කරන්න
      ),
    );
  }
}
