// lib/screens/power_info_screen.dart

import 'package:flutter/material.dart';
import 'package:trip_planner_app/data/power_data.dart';
import 'package:trip_planner_app/models/power_info_model.dart';

class PowerInfoScreen extends StatefulWidget {
  const PowerInfoScreen({super.key});

  @override
  State<PowerInfoScreen> createState() => _PowerInfoScreenState();
}

class _PowerInfoScreenState extends State<PowerInfoScreen> {
  // අපේ data list එකෙන් තෝරාගත් රටේ විස්තර තියාගන්න variable එකක්
  late PowerInfo _selectedCountry;

  @override
  void initState() {
    super.initState();
    // Screen එක load වෙනකොට, default විදිහට list එකේ පළවෙනි රට තෝරගන්නවා
    _selectedCountry = powerData.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Power Plugs & Voltage')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCountryDropdown(),
            const SizedBox(height: 24),
            _buildInfoDisplay(),
          ],
        ),
      ),
    );
  }

  // රට තෝරන Dropdown එක
  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PowerInfo>(
          value: _selectedCountry,
          isExpanded: true,
          items: powerData.map((PowerInfo countryInfo) {
            return DropdownMenuItem<PowerInfo>(
              value: countryInfo,
              child: Text(
                countryInfo.country,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (PowerInfo? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCountry = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  // තොරතුරු පෙන්වන කොටස
  Widget _buildInfoDisplay() {
    return Column(
      children: [
        // Design එකේ තියෙන image එක වෙනුවට, අපි දැනට Icon එකක් දාමු
        Icon(Icons.power, size: 100, color: Theme.of(context).primaryColor),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoBox('Plug Type', _selectedCountry.plugTypes),
            _buildInfoBox('Voltage', _selectedCountry.voltage),
            _buildInfoBox('Frequency', _selectedCountry.frequency),
          ],
        ),
        const SizedBox(height: 32),
        _buildAdapterInfoBox(),
      ],
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAdapterInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'You will need a travel adapter. If your devices are not dual voltage, you will also need a voltage converter.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
