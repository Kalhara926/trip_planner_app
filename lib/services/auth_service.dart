// File: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner_app/models/user_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Email සහ Password සමඟින් User කෙනෙක්ව register කර, Firestore profile එකක් සෑදීම
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String fullName,
    String username,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Auth record එක හැදුනට පස්සේ, Firestore profile එක හදනවා
        MyUser newUser = MyUser(
          uid: credential.user!.uid,
          email: email,
          fullName: fullName,
          username: username,
        );
        await _firestoreService.createUserProfile(newUser);
        return credential.user;
      }
      return null;
    } catch (e) {
      print("Something went wrong during sign up: $e");
      return null;
    }
  }

  /// Email සහ Password සමඟින් User කෙනෙක්ව Sign In කිරීම
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Something went wrong during sign in: $e");
      return null;
    }
  }

  /// User ව Sign Out කිරීම
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// User ගේ authentication state එකට සවන් දීම
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
