// File: lib/screens/trips_screen.dart (Previously home_screen.dart)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/screens/add_trip_screen.dart';
import 'package:trip_planner_app/screens/trip_details_screen.dart';
import 'package:trip_planner_app/services/auth_service.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

// Class එකේ නම HomeScreen සිට TripsScreen ලෙස වෙනස් කර ඇත
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('User not found. Please log in again.'),
              ElevatedButton(
                onPressed: () => authService.signOut(),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        // AppBar එකේ actions ටික MainScreen එකට ගෙන යා හැක,
        // නමුත් දැනට මෙහි තැබීම ගැටලුවක් නැත.
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Trip>>(
        stream: firestoreService.getTrips(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return const Center(child: Text('Error loading trips.'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(
              child: Text('No trips yet. Tap "+" to add one.'),
            );

          final trips = snapshot.data!;

          // --- ListView.builder එකේ සම්පූර්ණ කේතය මෙන්න ---
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Dismissible(
                key: Key(trip.id!),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async => await showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: Text(
                      "Are you sure you want to delete '${trip.title}'?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("DELETE"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  firestoreService.deleteTrip(trip.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${trip.title} deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TripDetailsScreen(trip: trip),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (trip.imageUrl == null || trip.imageUrl!.isEmpty)
                            ? Container(
                                height: 150,
                                color: Colors.blueGrey[100],
                                child: const Center(
                                  child: Icon(
                                    Icons.luggage,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Hero(
                                tag: trip.id!,
                                child: CachedNetworkImage(
                                  imageUrl: trip.imageUrl!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 180,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        height: 180,
                                        color: Colors.red[100],
                                        child: const Center(
                                          child: Icon(Icons.error),
                                        ),
                                      ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trip.destination,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTripScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
