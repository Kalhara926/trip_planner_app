// lib/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner_app/screens/home_screen.dart'; // මේක අපි ඊළඟට හදනවා
import 'package:trip_planner_app/screens/login_screen.dart';
import 'package:trip_planner_app/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.user, // User ගේ තත්ත්වය අහගෙන ඉන්නවා
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Check කරනකල් loading circle එකක් පෙන්නනවා
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User data තියෙනවා, ඒ කියන්නේ user log වෙලා. Home Screen එකට යවනවා.
          return HomeScreen();
        } else {
          // User data නෑ, ඒ කියන්නේ user log වෙලා නෑ. Login Screen එකට යවනවා.
          return LoginScreen();
        }
      },
    );
  }
}
