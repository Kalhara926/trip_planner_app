// File: lib/widgets/map_tab_view.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner_app/models/itinerary_item_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class MapTabView extends StatelessWidget {
  final String tripId;
  const MapTabView({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return StreamBuilder<List<ItineraryItem>>(
      stream: firestoreService.getItinerary(tripId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No locations to show on map.'));
        }

        final List<ItineraryItem> items = snapshot.data!;

        final Set<Marker> markers = items.map((item) {
          return Marker(
            markerId: MarkerId(item.id!),
            position: LatLng(item.position.latitude, item.position.longitude),
            infoWindow: InfoWindow(
              title: item.description,
              snippet: TimeOfDay.fromDateTime(item.time).format(context),
            ),
          );
        }).toSet();

        final LatLng initialPosition = LatLng(
          items.first.position.latitude,
          items.first.position.longitude,
        );

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 12,
          ),
          markers: markers,
        );
      },
    );
  }
}
