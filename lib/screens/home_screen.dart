// File: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/screens/add_trip_screen.dart';
import 'package:trip_planner_app/screens/trip_details_screen.dart';
import 'package:trip_planner_app/services/auth_service.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // අවශ්‍ය services සහ user තොරතුරු ලබාගැනීම
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authService.signOut();
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('User not logged in!'))
          : StreamBuilder<List<Trip>>(
              stream: firestoreService.getTrips(user.uid),
              builder: (context, snapshot) {
                // 1. දත්ත පැමිණෙන තෙක් Loading Indicator එක පෙන්වීම
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2. දෝෂයක් ඇති වුවහොත් Error Message එක පෙන්වීම
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // 3. Trips නොමැති විට පණිවිඩයක් පෙන්වීම
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.luggage, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No trips yet.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tap the "+" button to add your first trip!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // 4. Trips list එක ලබාගැනීම
                final trips = snapshot.data!;

                // ListView.builder මගින් trips list එක UI එකේ පෙන්වීම
                return ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    // --- Swipe-to-delete functionality සඳහා Dismissible Widget ---
                    return Dismissible(
                      // દરેક widget එකක් හඳුනාගැනීම සඳහා අද්විතීය Key එකක්.
                      key: Key(trip.id!),

                      // Swipe කළ හැකි දිශාව (දකුණේ සිට වමට පමණි).
                      direction: DismissDirection.endToStart,

                      // Swipe කර අවසන් වූ පසු ක්‍රියාත්මක වන function එක.
                      onDismissed: (direction) {
                        // Firestore එකෙන් trip එක delete කිරීම.
                        firestoreService.deleteTrip(trip.id!);

                        // User ට දැනුම් දීම සඳහා SnackBar එකක් පෙන්වීම.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${trip.title} deleted'),
                            backgroundColor: Colors.red,
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                // Undo functionality එකක් මෙහිදී add කළ හැක (Advanced).
                                // දැනට මෙම කොටස හිස්ව තබමු.
                              },
                            ),
                          ),
                        );
                      },

                      // Swipe කරන විට item එකට යටින් පෙන්වන background එක.
                      background: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                      ),

                      // Dismissible widget එකේ child එක ලෙස Card එක යෙදීම.
                      child: Card(
                        // Card එකේ පෙනුම main.dart හි theme එකෙන් ලැබෙන නිසා,
                        // මෙහිදී අමතර styling අවශ්‍ය නොවේ.
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          title: Text(
                            trip.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(trip.destination),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () {
                            // TripDetailsScreen එකට යොමු කිරීම.
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    TripDetailsScreen(trip: trip),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),

      // අලුත් trip එකක් add කිරීමට Floating Action Button එක
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTripScreen()),
          );
        },
        tooltip: 'Add new trip',
        child: const Icon(Icons.add),
      ),
    );
  }
}
