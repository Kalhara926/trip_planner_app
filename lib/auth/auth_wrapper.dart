// File: lib/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner_app/screens/login_screen.dart';
import 'package:trip_planner_app/screens/main_screen.dart'; // <-- HomeScreen වෙනුවට MainScreen import කිරීම
import 'package:trip_planner_app/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      // User ගේ authentication තත්ත්වය (log වෙලාද නැද්ද) real-time එකේදී සවන් දීම
      stream: authService.user,
      builder: (context, snapshot) {
        // 1. තත්ත්වය පරීක්ෂා කරන අතරතුර Loading Indicator එකක් පෙන්වීම
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // 2. User data තියෙනවා නම් (snapshot.hasData == true), ඒ කියන්නේ user log වෙලා
        else if (snapshot.hasData) {
          // User ව, BottomNavigationBar එක සහිත ප්‍රධාන app screen එකට යොමු කිරීම
          return const MainScreen();
        }
        // 3. User data නැත්නම්, ඒ කියන්නේ user log වෙලා නෑ
        else {
          // User ව Login Screen එකට යොමු කිරීම
          return const LoginScreen();
        }
      },
    );
  }
}
