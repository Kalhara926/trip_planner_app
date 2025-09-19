// File: lib/models/trip_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String? id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget; // <--- Budget property එක
  final String userId;

  Trip({
    this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget, // <--- Constructor එකට එකතු කරන ලදී
    required this.userId,
  });

  // Firestore එකෙන් data ගන්නකොට, Map එකක් Trip object එකක් බවට පත්කිරීම
  factory Trip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Trip(
      id: snapshot.id,
      title: data['title'],
      destination: data['destination'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      // Firestore document එකේ budget field එක නොමැති නම් (පැරණි data සඳහා),
      // default අගය 0.0 ලෙස සලකයි.
      budget: (data['budget'] ?? 0.0)
          .toDouble(), // <--- fromFirestore එකට එකතු කරන ලදී
      userId: data['userId'],
    );
  }

  // Trip object එකක් Firestore එකට යවනකොට, Map එකක් බවට පත්කිරීම
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget, // <--- toFirestore එකට එකතු කරන ලදී
      'userId': userId,
    };
  }
}
