// lib/screens/notification_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:trip_planner_app/services/preferences_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final PreferencesService _prefsService = PreferencesService();

  bool _newMessagesEnabled = true;
  bool _communityActivityEnabled = true;
  bool _isLoading = true;

  // Setting keys - මේවා වැරදෙන්නේ නැතුව පාවිච්චි කරන්න
  static const String newMessagesKey = 'new_messages_enabled';
  static const String communityActivityKey = 'community_activity_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // App එක පටන් ගන්නකොට save කරපු settings ටික load කරගැනීම
  Future<void> _loadSettings() async {
    final newMessages = await _prefsService.getBoolSetting(newMessagesKey);
    final communityActivity = await _prefsService.getBoolSetting(
      communityActivityKey,
    );
    setState(() {
      _newMessagesEnabled = newMessages;
      _communityActivityEnabled = communityActivity;
      _isLoading = false;
    });
  }

  // Switch එකක් on/off කරනකොට අලුත් අගය save කිරීම
  Future<void> _updateSetting(String key, bool value) async {
    await _prefsService.saveBoolSetting(key, value);
    setState(() {
      if (key == newMessagesKey) {
        _newMessagesEnabled = value;
      } else if (key == communityActivityKey) {
        _communityActivityEnabled = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionHeader('Push Notifications'),
                SwitchListTile(
                  title: const Text('New Messages'),
                  subtitle: const Text(
                    'Receive notifications for new messages',
                  ),
                  value: _newMessagesEnabled,
                  onChanged: (bool value) {
                    _updateSetting(newMessagesKey, value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Community Activity'),
                  subtitle: const Text(
                    'New posts and replies in your communities',
                  ),
                  value: _communityActivityEnabled,
                  onChanged: (bool value) {
                    _updateSetting(communityActivityKey, value);
                  },
                ),
                const Divider(),
                _buildSectionHeader('Trip Updates'),
                SwitchListTile(
                  title: const Text('Trip Alerts'),
                  subtitle: const Text(
                    'Changes to your itinerary, flight alerts, etc.',
                  ),
                  value: true, // This is just a UI example
                  onChanged: (bool value) {
                    // TODO: Implement saving logic for this setting
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
