// lib/models/itinerary_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryItem {
  final String? id;
  final String description; // සිදුවීමේ විස්තරය
  final DateTime time; // සිදුවීම වන වේලාව
  final String tripId; // මේක අයිති කුමන trip එකටද
  final DateTime date; // මේක අයිති කුමන දවසටද

  ItineraryItem({
    this.id,
    required this.description,
    required this.time,
    required this.tripId,
    required this.date,
  });

  // Firestore Map -> ItineraryItem Object
  factory ItineraryItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return ItineraryItem(
      id: snapshot.id,
      description: data['description'],
      time: (data['time'] as Timestamp).toDate(),
      tripId: data['tripId'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // ItineraryItem Object -> Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'time': time,
      'tripId': tripId,
      'date': date,
    };
  }
}
