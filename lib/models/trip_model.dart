// File: lib/models/trip_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String? id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String travelers; // "Travelers" field එක
  final String? imageUrl;
  final String userId;

  Trip({
    this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.travelers, // Constructor එකට එකතු කරන ලදී
    this.imageUrl,
    required this.userId,
  });

  // Firestore එකෙන් data ගන්නකොට, Map එකක් Trip object එකක් බවට පත්කිරීම
  factory Trip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Trip(
      id: snapshot.id,
      title: data['title'] ?? '',
      destination: data['destination'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      budget: (data['budget'] ?? 0.0).toDouble(),
      // Firestore document එකේ travelers field එක නොමැති නම්,
      // default අගය '1 traveler' ලෙස සලකයි
      travelers: data['travelers'] ?? '1 traveler',
      imageUrl: data['imageUrl'],
      userId: data['userId'] ?? '',
    );
  }

  // Trip object එකක් Firestore එකට යවනකොට, Map එකක් බවට පත්කිරීම
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget,
      'travelers': travelers, // Firestore එකට යැවීමට එකතු කරන ලදී
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }
}
