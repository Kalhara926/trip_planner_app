// lib/models/document_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TravelDocument {
  final String? id;
  final String name;
  final String documentType; // e.g., "Passport", "Ticket", "Hotel"
  final String fileUrl;
  final String publicId; // Cloudinary එකෙන් delete කරන්න ඕන වෙන ID එක
  final Timestamp uploadedAt;
  final String userId;

  TravelDocument({
    this.id,
    required this.name,
    required this.documentType,
    required this.fileUrl,
    required this.publicId,
    required this.uploadedAt,
    required this.userId,
  });

  factory TravelDocument.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return TravelDocument(
      id: snapshot.id,
      name: data['name'],
      documentType: data['documentType'],
      fileUrl: data['fileUrl'],
      publicId: data['publicId'],
      uploadedAt: data['uploadedAt'],
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'documentType': documentType,
      'fileUrl': fileUrl,
      'publicId': publicId,
      'uploadedAt': uploadedAt,
      'userId': userId,
    };
  }
}
