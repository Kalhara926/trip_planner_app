// File: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_planner_app/models/document_model.dart';
import 'package:trip_planner_app/models/expense_model.dart';
import 'package:trip_planner_app/models/itinerary_item_model.dart';
import 'package:trip_planner_app/models/packing_item_model.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Functions ---
  Future<void> createUserProfile(MyUser user) =>
      _db.collection('users').doc(user.uid).set(user.toFirestore());

  // --- Trip Functions ---
  Future<void> addTrip(Trip trip) =>
      _db.collection('trips').add(trip.toFirestore());
  Stream<List<Trip>> getTrips(String userId) => _db
      .collection('trips')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) => s.docs.map((d) => Trip.fromFirestore(d)).toList());
  Future<void> updateTrip(Trip trip) =>
      _db.collection('trips').doc(trip.id).update(trip.toFirestore());
  Future<void> deleteTrip(String tripId) async {
    final tripRef = _db.collection('trips').doc(tripId);
    final collections = ['itinerary', 'packing_list', 'expenses'];
    for (var col in collections) {
      final snapshot = await tripRef.collection(col).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
    await tripRef.delete();
  }

  // --- Itinerary Functions ---
  Future<void> addItineraryItem(ItineraryItem item) => _db
      .collection('trips')
      .doc(item.tripId)
      .collection('itinerary')
      .add(item.toFirestore());
  Stream<List<ItineraryItem>> getItinerary(String tripId) => _db
      .collection('trips')
      .doc(tripId)
      .collection('itinerary')
      .orderBy('time')
      .snapshots()
      .map((s) => s.docs.map((d) => ItineraryItem.fromFirestore(d)).toList());
  Future<void> deleteItineraryItem(String tripId, String itemId) => _db
      .collection('trips')
      .doc(tripId)
      .collection('itinerary')
      .doc(itemId)
      .delete();
  Future<void> updateItineraryItem(String tripId, ItineraryItem item) => _db
      .collection('trips')
      .doc(tripId)
      .collection('itinerary')
      .doc(item.id)
      .update(item.toFirestore());

  // --- Packing List Functions ---
  Future<void> addPackingItem(PackingItem item) => _db
      .collection('trips')
      .doc(item.tripId)
      .collection('packing_list')
      .add(item.toFirestore());
  Stream<List<PackingItem>> getPackingList(String tripId) => _db
      .collection('trips')
      .doc(tripId)
      .collection('packing_list')
      .snapshots()
      .map((s) => s.docs.map((d) => PackingItem.fromFirestore(d)).toList());
  Future<void> updatePackingItem(String tripId, String itemId, bool isPacked) =>
      _db
          .collection('trips')
          .doc(tripId)
          .collection('packing_list')
          .doc(itemId)
          .update({'isPacked': isPacked});
  Future<void> deletePackingItem(String tripId, String itemId) => _db
      .collection('trips')
      .doc(tripId)
      .collection('packing_list')
      .doc(itemId)
      .delete();

  // --- Budget / Expense Functions ---
  Future<void> addExpense(Expense expense) => _db
      .collection('trips')
      .doc(expense.tripId)
      .collection('expenses')
      .add(expense.toFirestore());
  Stream<List<Expense>> getExpenses(String tripId) => _db
      .collection('trips')
      .doc(tripId)
      .collection('expenses')
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Expense.fromFirestore(d)).toList());
  Future<void> deleteExpense(String tripId, String expenseId) => _db
      .collection('trips')
      .doc(tripId)
      .collection('expenses')
      .doc(expenseId)
      .delete();

  // --- Document Wallet Functions ---
  Future<void> addDocument(TravelDocument document) {
    return _db.collection('documents').add(document.toFirestore());
  }

  Stream<List<TravelDocument>> getDocuments(String userId) {
    return _db
        .collection('documents')
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TravelDocument.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> deleteDocument(String docId) {
    // TODO: Also delete the file from Cloudinary using its public_id
    return _db.collection('documents').doc(docId).delete();
  }
}
