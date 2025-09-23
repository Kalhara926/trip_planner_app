// lib/models/emergency_contact_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
  final String? id;
  final String name;
  final String phone;
  final String userId;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phone,
    required this.userId,
  });

  factory EmergencyContact.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EmergencyContact(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'phone': phone, 'userId': userId};
  }
}
