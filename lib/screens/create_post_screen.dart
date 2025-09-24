// lib/screens/create_post_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_planner_app/models/post_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';
import 'package:trip_planner_app/services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    /* ... Same as in add_trip_screen ... */
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty ||
        (_imageFile == null && _webImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an image and a title.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser!;
    final userProfile = await _firestoreService.getUserProfile(user.uid);

    // 1. Upload image to get URL
    final response = await _storageService.uploadFile(
      filePath: _imageFile?.path ?? '',
      fileBytes: _webImage,
      userId: user.uid,
      folder: 'posts',
      resourceType: 'image',
    );

    if (response == null) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 2. Create Post object
    final newPost = Post(
      title: _titleController.text,
      imageUrl: response.secureUrl,
      authorId: user.uid,
      authorName: userProfile?.fullName ?? 'A Traveller',
      authorAvatarUrl: '', // You can add user avatar URL to MyUser model
      timestamp: Timestamp.now(),
    );

    // 3. Save post to Firestore
    await _firestoreService.createPost(newPost);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a Guide/Post')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Image Picker UI (Same as in add_trip_screen)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: _imageFile != null || _webImage != null
                        ? (kIsWeb
                              ? Image.memory(_webImage!)
                              : Image.file(_imageFile!))
                        : const Icon(Icons.add_a_photo, size: 50),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title or Caption',
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submitPost,
                  child: const Text('Publish Post'),
                ),
                const SizedBox(height: 20),
              ],
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
}
