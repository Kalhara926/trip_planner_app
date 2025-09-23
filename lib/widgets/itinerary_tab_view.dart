// File: lib/widgets/itinerary_tab_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isGenerating = false;

  void _showGenerateDialog() {
    final interestsController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              Navigator.of(context).pop();
              setState(() {
                _isGenerating = true;
              });

              final items = await _aiService.generateItinerary(
                trip: widget.trip,
                interests: interestsController.text,
              );
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
      ),
    );
  }

  void _showItineraryItemDialog({
    required DateTime date,
    ItineraryItem? itemToEdit,
  }) {
    final isEditing = itemToEdit != null;
    final descriptionController = TextEditingController(
      text: itemToEdit?.description ?? '',
    );
    TimeOfDay selectedTime = isEditing
        ? TimeOfDay.fromDateTime(itemToEdit!.time)
        : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Itinerary Item' : 'Add Itinerary Item',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Time: ${selectedTime.format(context)}'),
                      IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text(isEditing ? 'Update' : 'Add'),
                  onPressed: () {
                    if (descriptionController.text.isEmpty) return;

                    final finalTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    final item = ItineraryItem(
                      id: itemToEdit?.id,
                      description: descriptionController.text,
                      time: finalTime,
                      tripId: widget.trip.id!,
                      date: date,
                      position: itemToEdit?.position ?? const GeoPoint(0, 0),
                    );

                    if (isEditing) {
                      _firestoreService.updateItineraryItem(
                        widget.trip.id!,
                        item,
                      );
                    } else {
                      _firestoreService.addItineraryItem(item);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

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

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Day $dayNumber (${DateFormat('EEE, MMM d').format(date)})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _showItineraryItemDialog(date: date),
                        ),
                      ],
                    ),
                    const Divider(),
                    StreamBuilder<List<ItineraryItem>>(
                      stream: _firestoreService.getItinerary(widget.trip.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Loading..."),
                            ),
                          );
                        if (!snapshot.hasData || snapshot.data!.isEmpty)
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No plans for this day yet.'),
                          );

                        final dayItems = snapshot.data!
                            .where(
                              (item) => DateUtils.isSameDay(item.date, date),
                            )
                            .toList();
                        if (dayItems.isEmpty)
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No plans for this day yet.'),
                          );

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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.grey.shade700,
                                    ),
                                    onPressed: () => _showItineraryItemDialog(
                                      date: date,
                                      itemToEdit: item,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _deleteItineraryItem(item.id!),
                                  ),
                                ],
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
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _showGenerateDialog,
            label: const Text('Generate with AI'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ),
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
                    'AI is planning your trip...',
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
