// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase configuration file එක import කර ගැනීම.
// මෙය flutterfire configure මගින් ස්වයංක්‍රීයව සෑදේ.
import 'firebase_options.dart';

// AuthWrapper widget එක import කර ගැනීම.
// පරිශීලකයාගේ සත්‍යාපන තත්ත්වය (authentication state) පරීක්ෂා කරන්නේ මෙතැනිනි.
// 'trip_planner_app' වෙනුවට ඔබගේ package නම යොදන්න.
import 'package:trip_planner_app/auth/auth_wrapper.dart';

// යෙදුම ආරම්භ වන ප්‍රධාන function එක.
// Firebase සේවා භාවිතා කිරීමට පෙර එය initialize කළ යුතු නිසා මෙය 'async' function එකකි.
void main() async {
  // Flutter engine එක සහ widgets අතර සම්බන්ධය නිවැරදිව ස්ථාපිත බවට සහතික වීම.
  // async main function එකක් තුළදී මෙය අනිවාර්යයෙන්ම යෙදිය යුතුය.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase app එක initialize කිරීම.
  // 'await' මගින් මෙම ක්‍රියාවලිය අවසන් වන තුරු රැඳී සිටියි.
  // 'DefaultFirebaseOptions.currentPlatform' මගින් දැනට app එක run වන platform එකට
  // (Android/iOS) අදාළ Firebase configuration ස්වයංක්‍රීයව ලබා ගනී.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase initialize වූ පසු, Flutter යෙදුම run කිරීම.
  runApp(const MyApp());
}

// යෙදුමේ මූලිකම Widget එක (Root Widget).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp යනු Material Design widgets භාවිතා කරන යෙදුම්වල මූලික රාමුවයි.
    return MaterialApp(
      // Debug banner එක ඉවත් කිරීම.
      debugShowCheckedModeBanner: false,

      // යෙදුමේ නම.
      title: 'Trip Planner',

      // යෙදුමේ සමස්ත පෙනුම (Theme) සකස් කිරීම.
      theme: ThemeData(
        // ප්‍රධාන වර්ණය ලෙස නිල් පැහැය යොදාගැනීම.
        primarySwatch: Colors.blue,

        // විවිධ තිර መጠኖች සඳහා UI එකේ ඝනත්වය ස්වයංක්‍රීයව සකස් කිරීම.
        visualDensity: VisualDensity.adaptivePlatformDensity,

        // යෙදුම පුරා භාවිතා වන බොත්තම් වල පෙනුම සකස් කිරීම.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),

        // TextField වල පෙනුම සකස් කිරීම.
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),

      // යෙදුම ආරම්භයේදී පෙන්වන ප්‍රධාන Widget එක.
      // මෙහිදී LoginScreen එක напрямකය පෙන්වීම වෙනුවට,
      // AuthWrapper එකට යොමු කරයි.
      // AuthWrapper එක මගින් පරිශීලකයා log වී ඇත්නම් HomeScreen එකටත්,
      // එසේ නොමැති නම් LoginScreen එකටත් ස්වයංක්‍රීයව යොමු කරනු ලබයි.
      home: const AuthWrapper(),
    );
  }
}
