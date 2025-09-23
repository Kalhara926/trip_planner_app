// lib/screens/add_edit_insurance_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_planner_app/models/insurance_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class AddEditInsuranceScreen extends StatefulWidget {
  final InsuranceInfo? insuranceInfo;
  const AddEditInsuranceScreen({super.key, this.insuranceInfo});

  @override
  State<AddEditInsuranceScreen> createState() => _AddEditInsuranceScreenState();
}

class _AddEditInsuranceScreenState extends State<AddEditInsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  // Add controllers for all the fields
  final _providerController = TextEditingController();
  final _policyNumberController = TextEditingController();
  // ... and so on for all other fields

  @override
  void initState() {
    super.initState();
    if (widget.insuranceInfo != null) {
      // Populate controllers if editing
      _providerController.text = widget.insuranceInfo!.providerName;
      _policyNumberController.text = widget.insuranceInfo!.policyNumber;
      // ... and so on
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser!;
      final newInfo = InsuranceInfo(
        userId: user.uid,
        providerName: _providerController.text,
        policyNumber: _policyNumberController.text,
        // Get values from all other controllers and date pickers
        coverageStartDate: Timestamp.now(), // Placeholder
        coverageEndDate: Timestamp.now(), // Placeholder
        medicalCoverage: "50,000", // Placeholder
        baggageCoverage: "2,000", // Placeholder
        customerServicePhone: "123", // Placeholder
        emergencyAssistPhone: "911", // Placeholder
      );
      FirestoreService().saveInsuranceInfo(newInfo);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.insuranceInfo == null ? 'Add Insurance' : 'Edit Insurance',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _providerController,
              decoration: const InputDecoration(labelText: 'Provider Name'),
            ),
            TextFormField(
              controller: _policyNumberController,
              decoration: const InputDecoration(labelText: 'Policy Number'),
            ),
            // Add other text fields and date pickers for all fields
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveForm,
              child: const Text('Save Details'),
            ),
          ],
        ),
      ),
    );
  }
}
