// lib/widgets/packing_list_tab_view.dart

import 'package:flutter/material.dart';
import 'package:trip_planner_app/models/packing_item_model.dart';
import 'package:trip_planner_app/services/firestore_service.dart';

class PackingListTabView extends StatefulWidget {
  final String tripId;
  const PackingListTabView({super.key, required this.tripId});

  @override
  State<PackingListTabView> createState() => _PackingListTabViewState();
}

class _PackingListTabViewState extends State<PackingListTabView> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _itemController = TextEditingController();

  void _addPackingItem() {
    if (_itemController.text.isNotEmpty) {
      final newItem = PackingItem(
        name: _itemController.text,
        tripId: widget.tripId,
      );
      _firestoreService.addPackingItem(newItem);
      _itemController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add item input field
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    labelText: 'Add item (e.g., Sunscreen)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton.filled(
                icon: Icon(Icons.add),
                onPressed: _addPackingItem,
              ),
            ],
          ),
        ),
        // List of items
        Expanded(
          child: StreamBuilder<List<PackingItem>>(
            stream: _firestoreService.getPackingList(widget.tripId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Your packing list is empty.'));
              }

              final items = snapshot.data!;

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.isPacked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    leading: Checkbox(
                      value: item.isPacked,
                      onChanged: (bool? value) {
                        _firestoreService.updatePackingItem(
                          widget.tripId,
                          item.id!,
                          value!,
                        );
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        _firestoreService.deletePackingItem(
                          widget.tripId,
                          item.id!,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
