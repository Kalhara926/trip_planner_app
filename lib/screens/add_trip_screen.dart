// File: lib/screens/add_trip_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class AddTripScreen extends StatefulWidget {
  // Constructor එක දැන් කිසිම parameter එකක් ගන්නේ නැහැ
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _travelersController = TextEditingController(text: '1 traveler');
  final _nameController = TextEditingController();

  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _destinationController.dispose();
    _travelersController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDateRange != null) {
      setState(() {
        _selectedDateRange = pickedDateRange;
      });
    }
  }

  Future<void> _createTrip() async {
    if (_formKey.currentState!.validate() && _selectedDateRange != null) {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final newTrip = Trip(
        title: _nameController.text,
        destination: _destinationController.text,
        startDate: _selectedDateRange!.start,
        endDate: _selectedDateRange!.end,
        travelers: _travelersController.text,
        budget: 0.0,
        userId: user.uid,
      );

      await _firestoreService.addTrip(newTrip);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } else if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the trip dates.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New trip',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildSectionTitle('Destination'),
              _buildTextField(_destinationController, 'Where to?'),
              const SizedBox(height: 24),
              _buildSectionTitle('Dates'),
              _buildDatePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('Travelers'),
              _buildTextField(_travelersController, 'How many?'),
              const SizedBox(height: 24),
              _buildSectionTitle('Name'),
              _buildTextField(_nameController, 'Trip name'),
              const Spacer(),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A3FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create trip',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    ),
  );

  Widget _buildTextField(TextEditingController controller, String hintText) =>
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.grey[100],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) =>
              value!.isEmpty ? 'This field is required' : null,
        ),
      );

  Widget _buildDatePicker() {
    String dateText = 'Select dates';
    if (_selectedDateRange != null) {
      final start = DateFormat.yMMMd().format(_selectedDateRange!.start);
      final end = DateFormat.yMMMd().format(_selectedDateRange!.end);
      dateText = '$start - $end';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
        onTap: _presentDatePicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              fontSize: 16,
              color: _selectedDateRange == null ? Colors.black54 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
