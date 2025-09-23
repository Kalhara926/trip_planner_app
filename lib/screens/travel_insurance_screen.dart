// lib/screens/travel_insurance_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/models/insurance_model.dart';
import 'package:trip_planner_app/screens/add_edit_insurance_screen.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class TravelInsuranceScreen extends StatelessWidget {
  const TravelInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Insurance'),
        actions: [
          // Edit button - only shows if data exists
          StreamBuilder<InsuranceInfo?>(
            stream: firestoreService.getInsuranceInfo(user!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditInsuranceScreen(
                          insuranceInfo: snapshot.data,
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink(); // Return empty space if no data
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<InsuranceInfo?>(
              stream: firestoreService.getInsuranceInfo(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: ElevatedButton(
                      child: const Text('Add Insurance Details'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddEditInsuranceScreen(),
                        ),
                      ),
                    ),
                  );
                }

                final info = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPolicyDetailsCard(info),
                    const SizedBox(height: 20),
                    _buildEmergencyContactsCard(
                      info,
                      firestoreService,
                      user.uid,
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildPolicyDetailsCard(InsuranceInfo info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Policy Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildDetailRow(
              Icons.shield,
              'Policy',
              '${info.providerName}\n${info.policyNumber}',
            ),
            _buildDetailRow(
              Icons.date_range,
              'Coverage Period',
              '${DateFormat.yMMMd().format(info.coverageStartDate.toDate())} - ${DateFormat.yMMMd().format(info.coverageEndDate.toDate())}',
            ),
            _buildDetailRow(
              Icons.medical_services,
              'Medical Coverage',
              info.medicalCoverage,
            ),
            _buildDetailRow(
              Icons.luggage,
              'Baggage Coverage',
              info.baggageCoverage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactsCard(
    InsuranceInfo info,
    FirestoreService service,
    String userId,
  ) {
    // This part can be built similarly to the details card
    // with a delete button at the bottom.
    return Card(/* ... Emergency contacts UI ... */);
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600])),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
