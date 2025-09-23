// File: lib/screens/carbon_tracker_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_planner_app/data/emission_data.dart';
import 'package:trip_planner_app/models/carbon_footprint_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class CarbonTrackerScreen extends StatefulWidget {
  const CarbonTrackerScreen({super.key});
  @override
  State<CarbonTrackerScreen> createState() => _CarbonTrackerScreenState();
}

class _CarbonTrackerScreenState extends State<CarbonTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripNameController = TextEditingController();
  final _distanceController = TextEditingController();

  String _selectedTransport = 'Flight';
  double? _estimatedEmissions;

  void _calculateAndSave() {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final distance = double.tryParse(_distanceController.text) ?? 0.0;
      final factor = emissionFactors[_selectedTransport] ?? 0.0;
      final emissions = distance * factor;

      setState(() {
        _estimatedEmissions = emissions;
      });

      final user = FirebaseAuth.instance.currentUser!;
      final footprintData = CarbonFootprint(
        tripName: _tripNameController.text,
        transportMode: _selectedTransport,
        distance: distance,
        emissions: emissions,
        calculationDate: Timestamp.now(),
        userId: user.uid,
      );

      FirestoreService().saveCarbonFootprint(footprintData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Calculation saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Dark Theme එක මෙතනදී apply කරනවා ---
    final darkTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.green,
      scaffoldBackgroundColor: const Color(0xFF121212),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
    );

    return Theme(
      data: darkTheme, // Apply the custom dark theme to this screen
      child: Scaffold(
        appBar: AppBar(title: const Text('Carbon Footprint')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  _tripNameController,
                  'Trip Name (e.g., Summer Vacation)',
                ),
                const SizedBox(height: 20),
                _buildDropdown(),
                const SizedBox(height: 20),
                _buildTextField(
                  _distanceController,
                  'Distance (km)',
                  isNumber: true,
                ),
                const SizedBox(height: 30),
                if (_estimatedEmissions != null) _buildResultCard(),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _calculateAndSave,
                  child: const Text('Calculate & Save Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedTransport,
      items: emissionFactors.keys.map((String mode) {
        return DropdownMenuItem<String>(value: mode, child: Text(mode));
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedTransport = newValue;
            _estimatedEmissions = null;
          });
        }
      },
      dropdownColor: Colors.grey[850],
      iconEnabledColor: Colors.white70,
      decoration: const InputDecoration(labelText: 'Transportation'),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Text(
            'Estimated Emissions',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _estimatedEmissions!.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ' kg CO2e',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This is equivalent to driving a car for ~${(_estimatedEmissions! / 0.17).toStringAsFixed(0)} km.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
