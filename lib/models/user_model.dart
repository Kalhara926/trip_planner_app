// File: lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String uid;
  final String email;
  final String? fullName;
  final String? username;

  MyUser({
    required this.uid,
    required this.email,
    this.fullName,
    this.username,
  });

  // --- Firestore Map -> MyUser Object ---
  // මෙම factory constructor එක අලුතින් එකතු කරන්න
  factory MyUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MyUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'],
      username: data['username'],
    );
  }

  // MyUser Object -> Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
