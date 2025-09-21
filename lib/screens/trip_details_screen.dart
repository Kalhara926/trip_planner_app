// File: lib/screens/trip_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/screens/add_trip_screen.dart'; // AddTripScreen import කිරීම
import 'package:trip_planner_app/widgets/budget_tab_view.dart';
import 'package:trip_planner_app/widgets/itinerary_tab_view.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.title, style: const TextStyle(fontSize: 20)),
            Text(
              '${DateFormat.yMMMd().format(widget.trip.startDate)} - ${DateFormat.yMMMd().format(widget.trip.endDate)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        // AppBar එකේ දකුණු පස actions (Edit button) එකතු කිරීම
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Trip',
            onPressed: () {
              // AddTripScreen එකට, edit කිරීමට අවශ්‍ය trip object එක සමඟ යොමු කිරීම
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddTripScreen(tripToEdit: widget.trip),
                    ),
                  )
                  .then((_) {
                    // Edit screen එකෙන් ආපසු ආ විට, UI එක refresh වීමට
                    // (මෙය state management library එකක් නොමැතිව කරන සරල ක්‍රමයකි)
                    setState(() {});
                  });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ItineraryTabView(trip: widget.trip),
          PackingListTabView(tripId: widget.trip.id!),
          BudgetTabView(trip: widget.trip),
        ],
      ),
    );
  }
}
