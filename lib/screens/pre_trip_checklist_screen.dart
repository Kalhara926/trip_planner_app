// lib/screens/pre_trip_checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:trip_planner_app/services/preferences_service.dart';

class PreTripChecklistScreen extends StatefulWidget {
  const PreTripChecklistScreen({super.key});

  @override
  State<PreTripChecklistScreen> createState() => _PreTripChecklistScreenState();
}

class _PreTripChecklistScreenState extends State<PreTripChecklistScreen> {
  final PreferencesService _prefsService = PreferencesService();

  // Checklist එකේ තියෙන හැම item එකකම checked/unchecked state එක තියාගන්න Map එකක්
  Map<String, bool> _checkedState = {};
  bool _isLoading = true;

  // Checklist එකේ තියෙන items ටික. අපි මේවා app එකේම hardcode කරනවා.
  final List<Map<String, dynamic>> _checklistItems = [
    {'id': 'doc_passport', 'title': 'Passport', 'section': 'Documents'},
    {'id': 'doc_visa', 'title': 'Visa', 'section': 'Documents'},
    {
      'id': 'doc_insurance',
      'title': 'Travel insurance',
      'section': 'Documents',
    },
    {'id': 'doc_tickets', 'title': 'Flight tickets', 'section': 'Documents'},

    {'id': 'home_stopmail', 'title': 'Stop mail', 'section': 'Home'},
    {'id': 'home_pets', 'title': 'Arrange pet care', 'section': 'Home'},
    {
      'id': 'home_appliances',
      'title': 'Turn off appliances',
      'section': 'Home',
    },

    {'id': 'pack_clothes', 'title': 'Clothes', 'section': 'Packing'},
    {'id': 'pack_meds', 'title': 'Medications', 'section': 'Packing'},
    {'id': 'pack_electronics', 'title': 'Electronics', 'section': 'Packing'},
  ];

  @override
  void initState() {
    super.initState();
    _loadChecklistState();
  }

  // Phone එකේ save කරපු checklist data ටික load කරගැනීම
  Future<void> _loadChecklistState() async {
    final Map<String, bool> loadedState = {};
    for (var item in _checklistItems) {
      // හැම item එකකටම අදාළව, save කරපු අගය (true/false) ලබාගන්නවා
      loadedState[item['id']] = await _prefsService.getBoolSetting(item['id']);
    }
    setState(() {
      _checkedState = loadedState;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Items ටික section අනුව කාණ්ඩ කිරීම
    final documents = _checklistItems
        .where((i) => i['section'] == 'Documents')
        .toList();
    final home = _checklistItems.where((i) => i['section'] == 'Home').toList();
    final packing = _checklistItems
        .where((i) => i['section'] == 'Packing')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Trip Checklist')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSection('Documents', documents),
                const SizedBox(height: 24),
                _buildSection('Home', home),
                const SizedBox(height: 24),
                _buildSection('Packing', packing),
              ],
            ),
    );
  }

  // එක section එකක් හදන helper widget එක
  Widget _buildSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          final itemId = item['id'];
          return CheckboxListTile(
            title: Text(item['title']),
            value:
                _checkedState[itemId] ??
                false, // අගයක් නැත්නම්, false ලෙස සලකනවා
            onChanged: (bool? newValue) {
              if (newValue != null) {
                setState(() {
                  _checkedState[itemId] = newValue;
                });
                // වෙනස් කරපු අගය phone එකේ save කරනවා
                _prefsService.saveBoolSetting(itemId, newValue);
              }
            },
          );
        }).toList(),
      ],
    );
  }
}
