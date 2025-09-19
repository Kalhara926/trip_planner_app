// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Firebase Auth instance එකක් හදාගන්නවා
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Sign Up (Email & Password)
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Firebase එකේ createUserWithEmailAndPassword function එක call කරනවා
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user; // සාර්ථක නම්, user object එක return කරනවා
    } catch (e) {
      // Error එකක් ආවොත්, console එකේ print කරලා null return කරනවා
      print("Something went wrong during sign up: $e");
      return null;
    }
  }

  // 2. Sign In (Email & Password)
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Firebase එකේ signInWithEmailAndPassword function එක call කරනවා
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user; // සාර්ථක නම්, user object එක return කරනවා
    } catch (e) {
      // Error එකක් ආවොත්
      print("Something went wrong during sign in: $e");
      return null;
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 4. User ගේ තත්ත්වය (Stream)
  // මේකෙන් user log වෙලාද නැද්ද කියලා real-time එකේ බලාගන්න පුළුවන්
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
