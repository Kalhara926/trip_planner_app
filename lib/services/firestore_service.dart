// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_planner_app/models/expense_model.dart';
import 'package:trip_planner_app/models/itinerary_item_model.dart';
import 'package:trip_planner_app/models/packing_item_model.dart';
import 'package:trip_planner_app/models/trip_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Trip Functions ---
  Future<void> addTrip(Trip trip) {
    return _db.collection('trips').add(trip.toFirestore());
  }

  Stream<List<Trip>> getTrips(String userId) {
    return _db
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList(),
        );
  }

  Future<void> deleteTrip(String tripId) async {
    final tripRef = _db.collection('trips').doc(tripId);
    final itinerarySnapshot = await tripRef.collection('itinerary').get();
    for (var doc in itinerarySnapshot.docs) {
      await doc.reference.delete();
    }
    final packingListSnapshot = await tripRef.collection('packing_list').get();
    for (var doc in packingListSnapshot.docs) {
      await doc.reference.delete();
    }
    final expensesSnapshot = await tripRef.collection('expenses').get();
    for (var doc in expensesSnapshot.docs) {
      await doc.reference.delete();
    }
    await tripRef.delete();
  }

  Future<void> updateTrip(Trip trip) {
    return _db.collection('trips').doc(trip.id).update(trip.toFirestore());
  }

  // --- Itinerary Functions ---
  Future<void> addItineraryItem(ItineraryItem item) {
    return _db
        .collection('trips')
        .doc(item.tripId)
        .collection('itinerary')
        .add(item.toFirestore());
  }

  Stream<List<ItineraryItem>> getItinerary(String tripId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('itinerary')
        .orderBy('time')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ItineraryItem.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> deleteItineraryItem(String tripId, String itemId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('itinerary')
        .doc(itemId)
        .delete();
  }

  // --- Packing List Functions ---
  Future<void> addPackingItem(PackingItem item) {
    return _db
        .collection('trips')
        .doc(item.tripId)
        .collection('packing_list')
        .add(item.toFirestore());
  }

  Stream<List<PackingItem>> getPackingList(String tripId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('packing_list')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PackingItem.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updatePackingItem(String tripId, String itemId, bool isPacked) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('packing_list')
        .doc(itemId)
        .update({'isPacked': isPacked});
  }

  Future<void> deletePackingItem(String tripId, String itemId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('packing_list')
        .doc(itemId)
        .delete();
  }

  // --- Budget / Expense Functions ---
  Future<void> addExpense(Expense expense) {
    return _db
        .collection('trips')
        .doc(expense.tripId)
        .collection('expenses')
        .add(expense.toFirestore());
  }

  Stream<List<Expense>> getExpenses(String tripId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
        );
  }

  Future<void> deleteExpense(String tripId, String expenseId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}
