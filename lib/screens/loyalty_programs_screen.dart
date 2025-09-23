// lib/screens/loyalty_programs_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner_app/models/loyalty_program_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class LoyaltyProgramsScreen extends StatefulWidget {
  const LoyaltyProgramsScreen({super.key});
  @override
  State<LoyaltyProgramsScreen> createState() => _LoyaltyProgramsScreenState();
}

class _LoyaltyProgramsScreenState extends State<LoyaltyProgramsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showAddProgramSheet() {
    final nameController = TextEditingController();
    final pointsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Keyboard එකට යට නොවී ඉන්න
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Loyalty Program',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Program Name (e.g., SkyMiles)',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: pointsController,
                decoration: const InputDecoration(labelText: 'Points / Miles'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final user = FirebaseAuth.instance.currentUser!;
                    final newProgram = LoyaltyProgram(
                      programName: nameController.text,
                      points: pointsController.text,
                      userId: user.uid,
                    );
                    _firestoreService.addLoyaltyProgram(newProgram);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save Program'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty Programs')),
      body: user == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<List<LoyaltyProgram>>(
              stream: _firestoreService.getLoyaltyPrograms(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.isEmpty)
                  return const Center(
                    child: Text('No loyalty programs added yet.'),
                  );

                final programs = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.card_membership,
                          color: Colors.blueAccent,
                        ),
                        title: Text(
                          program.programName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${program.points} points/miles'),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _firestoreService
                              .deleteLoyaltyProgram(program.id!),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProgramSheet,
        child: const Icon(Icons.add),
        tooltip: 'Add Program',
      ),
    );
  }
}
