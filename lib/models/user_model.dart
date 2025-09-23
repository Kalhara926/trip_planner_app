// lib/models/user_model.dart
class MyUser {
  final String uid;
  final String email;
  final String? fullName;
  final String? username;
  // You can add other fields like phone number, dob etc. here

  MyUser({
    required this.uid,
    required this.email,
    this.fullName,
    this.username,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'username': username,
      'createdAt': DateTime.now(), // To know when the user joined
    };
  }
}
