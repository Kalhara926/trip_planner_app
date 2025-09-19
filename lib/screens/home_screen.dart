// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:trip_planner_app/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: Text('My Trips'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.signOut(); // Sign out button එක
            },
          ),
        ],
      ),
      body: Center(child: Text('Welcome! Your trips will be here.')),
    );
  }
}
