// File: lib/screens/trip_details_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/screens/add_trip_screen.dart';
import 'package:trip_planner_app/widgets/budget_tab_view.dart';
import 'package:trip_planner_app/widgets/itinerary_tab_view.dart';
import 'package:trip_planner_app/widgets/map_tab_view.dart';
import 'package:trip_planner_app/widgets/packing_list_tab_view.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Trip _currentTrip;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentTrip = widget.trip;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentTrip.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${DateFormat.yMMMd().format(_currentTrip.startDate)} - ${DateFormat.yMMMd().format(_currentTrip.endDate)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Edit Functionality එක දැනට නව UI එකට ගැලපෙන්නේ නැති නිසා,
          // තාවකාලිකව comment කර තබමු. පසුව මෙය නැවත සකස් කළ හැක.
          /*
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Trip',
            onPressed: () {
              // We will need a separate EditTripScreen for the new UI
            },
          ),
          */
        ],
        flexibleSpace:
            (_currentTrip.imageUrl == null || _currentTrip.imageUrl!.isEmpty)
            ? Container(color: Theme.of(context).primaryColor)
            : Hero(
                tag: _currentTrip.id!,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(_currentTrip.imageUrl!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.event_note_rounded), text: 'Itinerary'),
            Tab(icon: Icon(Icons.checkroom_rounded), text: 'Packing List'),
            Tab(
              icon: Icon(Icons.account_balance_wallet_rounded),
              text: 'Budget',
            ),
            Tab(icon: Icon(Icons.map_rounded), text: 'Map'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ItineraryTabView(trip: _currentTrip),
          PackingListTabView(tripId: _currentTrip.id!),
          BudgetTabView(trip: _currentTrip),
          MapTabView(tripId: _currentTrip.id!),
        ],
      ),
    );
  }
}
