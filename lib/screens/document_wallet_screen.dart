// File: lib/screens/document_wallet_screen.dart

import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/models/document_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';
import 'package:trip_planner_app/services/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentWalletScreen extends StatefulWidget {
  const DocumentWalletScreen({super.key});
  @override
  State<DocumentWalletScreen> createState() => _DocumentWalletScreenState();
}

class _DocumentWalletScreenState extends State<DocumentWalletScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  bool _isLoading = false;

  void _addDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    String filePath = kIsWeb ? '' : result.files.single.path!;
    Uint8List? fileBytes = kIsWeb ? result.files.first.bytes : null;

    final details = await _showDocumentDetailsDialog();
    if (details == null) return;

    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser!;

    final response = await _storageService.uploadFile(
      filePath: filePath,
      fileBytes: fileBytes,
      userId: user.uid,
      folder: 'documents',
      resourceType: 'auto',
    );

    if (response == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('File upload failed.')));
      return;
    }

    final newDoc = TravelDocument(
      name: details['name']!,
      documentType: details['type']!,
      fileUrl: response.secureUrl,
      publicId: response.publicId,
      uploadedAt: Timestamp.now(),
      userId: user.uid,
    );
    await _firestoreService.addDocument(newDoc);
    setState(() {
      _isLoading = false;
    });
  }

  Future<Map<String, String>?> _showDocumentDetailsDialog() {
    final nameController = TextEditingController();
    String docType = 'Flight';
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Details'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Document Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: docType,
                items: ['Flight', 'Hotel', 'Passport', 'Visa', 'Other']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: (value) => docType = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(
                  context,
                ).pop({'name': nameController.text, 'type': docType});
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open the document.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Document Wallet')),
      body: user == null
          ? const Center(child: Text('Please log in.'))
          : Stack(
              children: [
                StreamBuilder<List<TravelDocument>>(
                  stream: _firestoreService.getDocuments(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError)
                      return const Center(
                        child: Text('Could not load documents.'),
                      );
                    if (snapshot.data!.isEmpty)
                      return const Center(
                        child: Text('No documents yet. Add one!'),
                      );

                    final documents = snapshot.data!;
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        return ListTile(
                          leading: Icon(_getDocIcon(doc.documentType)),
                          title: Text(doc.name),
                          subtitle: Text(
                            'Added on ${DateFormat.yMMMd().format(doc.uploadedAt.toDate())}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () =>
                                _firestoreService.deleteDocument(doc.id!),
                          ),
                          onTap: () => _openUrl(doc.fileUrl),
                        );
                      },
                    );
                  },
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addDocument,
        child: const Icon(Icons.add),
        tooltip: 'Add Document',
      ),
    );
  }

  IconData _getDocIcon(String type) {
    switch (type) {
      case 'Flight':
        return Icons.flight_takeoff;
      case 'Hotel':
        return Icons.hotel;
      case 'Passport':
        return Icons.badge;
      case 'Visa':
        return Icons.document_scanner;
      default:
        return Icons.article;
    }
  }
}
