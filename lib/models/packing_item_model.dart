// lib/models/packing_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PackingItem {
  final String? id;
  final String name;
  bool isPacked;
  final String tripId;

  PackingItem({
    this.id,
    required this.name,
    this.isPacked = false,
    required this.tripId,
  });

  factory PackingItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return PackingItem(
      id: snapshot.id,
      name: data['name'],
      isPacked: data['isPacked'],
      tripId: data['tripId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'isPacked': isPacked, 'tripId': tripId};
  }
}
