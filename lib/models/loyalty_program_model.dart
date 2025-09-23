// lib/models/loyalty_program_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyProgram {
  final String? id;
  final String programName;
  final String points; // Using String to be flexible (e.g., "12,500 points")
  final String userId;

  LoyaltyProgram({
    this.id,
    required this.programName,
    required this.points,
    required this.userId,
  });

  factory LoyaltyProgram.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return LoyaltyProgram(
      id: doc.id,
      programName: data['programName'] ?? '',
      points: data['points'] ?? '0',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'programName': programName, 'points': points, 'userId': userId};
  }
}
