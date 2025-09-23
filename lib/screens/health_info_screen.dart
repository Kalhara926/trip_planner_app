// lib/screens/health_info_screen.dart

import 'package:flutter/material.dart';
import 'package:trip_planner_app/data/health_data.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthInfoScreen extends StatelessWidget {
  const HealthInfoScreen({super.key});

  void _callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health & Safety')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Vaccinations Section
          _buildExpansionTile(
            context,
            title: 'Vaccinations',
            leadingIcon: Icons.vaccines,
            children: vaccinationData.map((vaccine) {
              return ListTile(
                title: Text(vaccine.title),
                subtitle: Text(vaccine.subtitle),
                trailing: Text(
                  vaccine.riskLevel,
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Health Risks Section
          _buildExpansionTile(
            context,
            title: 'Health Risks',
            leadingIcon: Icons.warning_amber_rounded,
            children: healthRisksData.map((risk) {
              return ListTile(
                title: Text(risk.title),
                subtitle: Text(risk.subtitle),
                trailing: Text(
                  risk.riskLevel,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Medical Facilities Section
          _buildExpansionTile(
            context,
            title: 'Local Medical Facilities',
            leadingIcon: Icons.local_hospital,
            initiallyExpanded: true, // Default විදිහට මේක open වෙලා තියෙන්න
            children: medicalFacilitiesData.map((facility) {
              return ListTile(
                title: Text(facility.name),
                subtitle: Text(facility.address),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _callNumber(facility.phone),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ExpansionTile එකට ලස්සන style එකක් දෙන helper widget එක
  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required IconData leadingIcon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: Icon(leadingIcon, color: Theme.of(context).primaryColor),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        shape: const Border(), // Removes default border when expanded
        children: children,
      ),
    );
  }
}
