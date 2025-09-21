// File: lib/screens/add_trip_screen.dart

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';
import 'package:trip_planner_app/services/storage_service.dart';

class AddTripScreen extends StatefulWidget {
  final Trip? tripToEdit;
  const AddTripScreen({super.key, this.tripToEdit});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _existingImageUrl;
  bool _isLoading = false;

  File? _imageFile;
  Uint8List? _webImage;

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.tripToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final trip = widget.tripToEdit!;
      _titleController.text = trip.title;
      _destinationController.text = trip.destination;
      _budgetController.text = trip.budget.toString();
      _startDate = trip.startDate;
      _endDate = trip.endDate;
      _existingImageUrl = trip.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        setState(() async {
          _webImage = await pickedFile.readAsBytes();
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null)
      return;

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

    String? imageUrl = _existingImageUrl;

    if (kIsWeb) {
      if (_webImage != null) {
        imageUrl = await _storageService.uploadTripImageFromBytes(
          _webImage!,
          user.uid,
        );
      }
    } else {
      if (_imageFile != null) {
        imageUrl = await _storageService.uploadTripImageFromFile(
          _imageFile!,
          user.uid,
        );
      }
    }

    if (isEditing) {
      final updatedTrip = Trip(
        id: widget.tripToEdit!.id,
        title: _titleController.text,
        destination: _destinationController.text,
        budget: double.tryParse(_budgetController.text) ?? 0.0,
        startDate: _startDate!,
        endDate: _endDate!,
        userId: user.uid,
        imageUrl: imageUrl,
      );
      await _firestoreService.updateTrip(updatedTrip);
    } else {
      final newTrip = Trip(
        title: _titleController.text,
        destination: _destinationController.text,
        budget: double.tryParse(_budgetController.text) ?? 0.0,
        startDate: _startDate!,
        endDate: _endDate!,
        userId: user.uid,
        imageUrl: imageUrl,
      );
      await _firestoreService.addTrip(newTrip);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Trip' : 'Add New Trip')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: buildImagePreview(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Trip Title'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _destinationController,
                    decoration: const InputDecoration(labelText: 'Destination'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Total Budget (LKR)',
                    ),
                    // --- මෙතන නිවැරදි කර ඇත ---
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _startDate == null
                          ? 'Select Start Date'
                          : 'Start: ${DateFormat.yMMMd().format(_startDate!)}',
                    ),
                    onTap: () => _selectDate(context, true),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _endDate == null
                          ? 'Select End Date'
                          : 'End: ${DateFormat.yMMMd().format(_endDate!)}',
                    ),
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveTrip,
                    child: Text(isEditing ? 'Update Trip' : 'Save Trip'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(_webImage!, fit: BoxFit.cover),
      );
    }
    if (!kIsWeb && _imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      );
    }
    if (_existingImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: _existingImageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    }
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
          Text('Tap to add a cover photo'),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
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
}
