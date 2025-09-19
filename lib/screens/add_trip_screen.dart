// File: lib/screens/add_trip_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController(); // <--- Budget controller
  DateTime? _startDate;
  DateTime? _endDate;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose(); // <--- Controller එක dispose කිරීම
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveTrip() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newTrip = Trip(
          title: _titleController.text,
          destination: _destinationController.text,
          budget:
              double.tryParse(_budgetController.text) ??
              0.0, // <--- Budget එක parse කිරීම
          startDate: _startDate!,
          endDate: _endDate!,
          userId: user.uid,
        );
        _firestoreService.addTrip(newTrip).then((_) {
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Trip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Trip Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a destination' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                // <--- Budget TextField එක
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Total Budget (LKR)',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}',
                ),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _endDate == null
                      ? 'Select End Date'
                      : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}',
                ),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTrip,
                child: const Text('Save Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
