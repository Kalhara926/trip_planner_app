// File: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_planner_app/models/carbon_footprint_model.dart';
import 'package:trip_planner_app/models/document_model.dart';
import 'package:trip_planner_app/models/emergency_contact_model.dart';
import 'package:trip_planner_app/models/expense_model.dart';
import 'package:trip_planner_app/models/insurance_model.dart';
import 'package:trip_planner_app/models/itinerary_item_model.dart';
import 'package:trip_planner_app/models/loyalty_program_model.dart';
import 'package:trip_planner_app/models/packing_item_model.dart';
import 'package:trip_planner_app/models/post_model.dart'; // Post model import කිරීම
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Functions ---
  Future<void> createUserProfile(MyUser user) =>
      _db.collection('users').doc(user.uid).set(user.toFirestore());

  Future<MyUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return MyUser.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>,
      );
    }
    return null;
  }

  // --- Post & Community Functions ---
  Future<void> createPost(Post post) {
    return _db.collection('posts').add(post.toFirestore());
  }

  Stream<List<Post>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
        );
  }

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
  Future<void> addDocument(TravelDocument document) =>
      _db.collection('documents').add(document.toFirestore());
  Stream<List<TravelDocument>> getDocuments(String userId) => _db
      .collection('documents')
      .where('userId', isEqualTo: userId)
      .orderBy('uploadedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => TravelDocument.fromFirestore(d)).toList());
  Future<void> deleteDocument(String docId) =>
      _db.collection('documents').doc(docId).delete();

  // --- Emergency Contacts Functions ---
  Future<void> addEmergencyContact(EmergencyContact contact) =>
      _db.collection('emergency_contacts').add(contact.toFirestore());
  Stream<List<EmergencyContact>> getEmergencyContacts(String userId) => _db
      .collection('emergency_contacts')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map(
        (s) => s.docs.map((d) => EmergencyContact.fromFirestore(d)).toList(),
      );
  Future<void> deleteEmergencyContact(String docId) =>
      _db.collection('emergency_contacts').doc(docId).delete();

  // --- Loyalty Programs Functions ---
  Future<void> addLoyaltyProgram(LoyaltyProgram program) =>
      _db.collection('loyalty_programs').add(program.toFirestore());
  Stream<List<LoyaltyProgram>> getLoyaltyPrograms(String userId) => _db
      .collection('loyalty_programs')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((s) => s.docs.map((d) => LoyaltyProgram.fromFirestore(d)).toList());
  Future<void> deleteLoyaltyProgram(String docId) =>
      _db.collection('loyalty_programs').doc(docId).delete();

  // --- Travel Insurance Functions ---
  Future<void> saveInsuranceInfo(InsuranceInfo info) => _db
      .collection('insurance_policies')
      .doc(info.userId)
      .set(info.toFirestore());
  Stream<InsuranceInfo?> getInsuranceInfo(String userId) => _db
      .collection('insurance_policies')
      .doc(userId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.exists ? InsuranceInfo.fromFirestore(snapshot) : null,
      );
  Future<void> deleteInsuranceInfo(String userId) =>
      _db.collection('insurance_policies').doc(userId).delete();

  // --- Carbon Footprint Functions ---
  Future<void> saveCarbonFootprint(CarbonFootprint footprint) =>
      _db.collection('carbon_footprints').add(footprint.toFirestore());
  Stream<List<CarbonFootprint>> getCarbonFootprints(String userId) => _db
      .collection('carbon_footprints')
      .where('userId', isEqualTo: userId)
      .orderBy('calculationDate', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => CarbonFootprint.fromFirestore(d)).toList());
}
