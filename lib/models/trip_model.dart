// lib/models/trip_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String? id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String? imageUrl; // <-- මෙන්න මේ field එක අනිවාර්යයෙන්ම තියෙන්න ඕන
  final String userId;

  Trip({
    this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.imageUrl, // <-- මෙතනත් parameter එක තියෙන්න ඕන
    required this.userId,
  });

  factory Trip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Trip(
      id: snapshot.id,
      title: data['title'],
      destination: data['destination'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      budget: (data['budget'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'], // <-- මෙතනත් තියෙන්න ඕන
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget,
      'imageUrl': imageUrl, // <-- මෙතනත් තියෙන්න ඕන
      'userId': userId,
    };
  }
}
