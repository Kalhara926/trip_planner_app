// File: lib/models/itinerary_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryItem {
  final String? id;
  final String description;
  final DateTime time;
  final String tripId;
  final DateTime date;
  final GeoPoint position;

  ItineraryItem({
    this.id,
    required this.description,
    required this.time,
    required this.tripId,
    required this.date,
    required this.position,
  });

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
      position: data['position'] as GeoPoint,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'time': time,
      'tripId': tripId,
      'date': date,
      'position': position,
    };
  }
}
