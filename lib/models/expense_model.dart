// lib/models/expense_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String tripId;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.tripId,
  });

  factory Expense.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return Expense(
      id: snapshot.id,
      description: data['description'],
      amount: data['amount'].toDouble(),
      category: data['category'],
      date: (data['date'] as Timestamp).toDate(),
      tripId: data['tripId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
      'date': date,
      'tripId': tripId,
    };
  }
}
