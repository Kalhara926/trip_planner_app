// File: lib/widgets/itinerary_tab_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner_app/models/itinerary_item_model.dart';
import 'package:trip_planner_app/models/trip_model.dart';
import 'package:trip_planner_app/services/ai_service.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class ItineraryTabView extends StatefulWidget {
  final Trip trip;
  const ItineraryTabView({super.key, required this.trip});

  @override
  State<ItineraryTabView> createState() => _ItineraryTabViewState();
}

class _ItineraryTabViewState extends State<ItineraryTabView> {
  final FirestoreService _firestoreService = FirestoreService();
  final AiService _aiService = AiService();
  bool _isGenerating =
      false; // AI එක ක්‍රියාත්මක වන විට loading state එක පාලනය කිරීමට

  // AI Itinerary Generation සඳහා dialog box එක පෙන්වීම
  void _showGenerateDialog() {
    final interestsController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible:
          false, // Loading වන විට dialog එක close වීම වැළැක්වීමට
      builder: (context) {
        return AlertDialog(
          title: const Text('Generate with AI'),
          content: TextField(
            controller: interestsController,
            decoration: const InputDecoration(
              labelText: 'Your Interests',
              hintText: 'e.g., history, food, hiking',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Generate'),
              onPressed: () async {
                if (interestsController.text.isEmpty) return;
                Navigator.of(context).pop(); // Dialog එක close කිරීම
                setState(() {
                  _isGenerating = true;
                });

                final items = await _aiService.generateItinerary(
                  trip: widget.trip,
                  interests: interestsController.text,
                );

                // AI එකෙන් ලැබුණු සියලුම items එකින් එක Firestore එකට save කිරීම
                for (var item in items) {
                  await _firestoreService.addItineraryItem(item);
                }

                if (mounted) {
                  setState(() {
                    _isGenerating = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  // අතින් (manually) Itinerary Item එකක් එකතු කිරීමට
  void _showAddItineraryItemDialog(DateTime date) {
    // මෙම function එකේ කේතය පාඩම් අංක 05 හි පරිදිම වේ.
    // අවශ්‍ය නම් එය මෙහි paste කරගත හැක. දැනට එය හිස්ව තබමු.
  }

  // Itinerary Item එකක් delete කිරීමට
  void _deleteItineraryItem(String itemId) {
    _firestoreService.deleteItineraryItem(widget.trip.id!, itemId);
  }

  @override
  Widget build(BuildContext context) {
    final tripDays =
        widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;
    final tripDates = List.generate(
      tripDays,
      (index) => widget.trip.startDate.add(Duration(days: index)),
    );

    // Loading overlay එක සහ FAB එක පෙන්වීම සඳහා Stack widget එක භාවිතා කිරීම
    return Stack(
      children: [
        // ප්‍රධාන Itinerary List එක
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // FAB එකට ඉඩ තැබීමට
          itemCount: tripDays,
          itemBuilder: (context, index) {
            final date = tripDates[index];
            final dayNumber = index + 1;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day $dayNumber (${DateFormat('EEE, MMM d').format(date)})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    StreamBuilder<List<ItineraryItem>>(
                      stream: _firestoreService.getItinerary(widget.trip.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Loading..."),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No plans for this day yet.'),
                          );
                        }

                        final dayItems = snapshot.data!
                            .where(
                              (item) => DateUtils.isSameDay(item.date, date),
                            )
                            .toList();

                        if (dayItems.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No plans for this day yet.'),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dayItems.length,
                          itemBuilder: (context, itemIndex) {
                            final item = dayItems[itemIndex];
                            return ListTile(
                              leading: Text(
                                DateFormat('hh:mm a').format(item.time),
                              ),
                              title: Text(item.description),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteItineraryItem(item.id!),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // "Generate with AI" Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _showGenerateDialog,
            label: const Text('Generate with AI'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ),

        // Loading Overlay
        if (_isGenerating)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'AI is planning your trip...\nThis might take a moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
