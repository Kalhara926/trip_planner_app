// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv package එක import කිරීම
import 'firebase_options.dart';
// 'trip_planner_app' වෙනුවට ඔබගේ package නම යොදන්න.
import 'package:trip_planner_app/auth/auth_wrapper.dart';

// main function එක async බවට පත් කර ඇත
Future<void> main() async {
  // Flutter engine එක සහ widgets අතර සම්බන්ධය නිවැරදිව ස්ථාපිත බවට සහතික වීම.
  WidgetsFlutterBinding.ensureInitialized();

  // .env file එක load කිරීම.
  // Gemini API key එක වැනි රහස්‍ය තොරතුරු ලබාගැනීමට මෙය අවශ්‍ය වේ.
  await dotenv.load(fileName: ".env");

  // Firebase app එක initialize කිරීම.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Flutter යෙදුම run කිරීම.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trip Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 4.0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
