// lib/screens/emergency_contacts_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trip_planner_app/models/emergency_contact_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});
  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _pickContact() async {
    if (await Permission.contacts.request().isGranted) {
      try {
        Contact? contact = await ContactsService.openDeviceContactPicker();
        if (contact != null) {
          final user = FirebaseAuth.instance.currentUser!;
          final newContact = EmergencyContact(
            name: contact.displayName ?? 'No Name',
            phone: contact.phones?.isNotEmpty == true
                ? contact.phones!.first.value!
                : 'No Number',
            userId: user.uid,
          );
          await _firestoreService.addEmergencyContact(newContact);
        }
      } catch (e) {
        print('Error picking contact: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission is required.')),
      );
    }
  }

  void _callContact(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: user == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<List<EmergencyContact>>(
              stream: _firestoreService.getEmergencyContacts(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.isEmpty)
                  return const Center(
                    child: Text('No emergency contacts added yet.'),
                  );

                final contacts = snapshot.data!;
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(contact.name),
                      subtitle: Text(contact.phone),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () => _callContact(contact.phone),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _firestoreService
                                .deleteEmergencyContact(contact.id!),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickContact,
        child: const Icon(Icons.add),
        tooltip: 'Add Contact',
      ),
    );
  }
}
