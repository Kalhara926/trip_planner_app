// File: lib/models/carbon_footprint_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CarbonFootprint {
  final String? id;
  final String tripName;
  final String transportMode;
  final double distance;
  final double emissions; // in kg CO2e
  final Timestamp calculationDate;
  final String userId;

  CarbonFootprint({
    this.id,
    required this.tripName,
    required this.transportMode,
    required this.distance,
    required this.emissions,
    required this.calculationDate,
    required this.userId,
  });

  // --- Firestore එකෙන් data ගන්නකොට, Map එකක් Object එකක් බවට පත්කිරීම ---
  factory CarbonFootprint.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CarbonFootprint(
      id: doc.id,
      tripName: data['tripName'] ?? '',
      transportMode: data['transportMode'] ?? '',
      distance: (data['distance'] ?? 0.0).toDouble(),
      emissions: (data['emissions'] ?? 0.0).toDouble(),
      calculationDate: data['calculationDate'] ?? Timestamp.now(),
      userId: data['userId'] ?? '',
    );
  }

  // --- Object එකක් Firestore එකට යවනකොට, Map එකක් බවට පත්කිරීම ---
  Map<String, dynamic> toFirestore() {
    return {
      'tripName': tripName,
      'transportMode': transportMode,
      'distance': distance,
      'emissions': emissions,
      'calculationDate': calculationDate,
      'userId': userId,
    };
  }
}
