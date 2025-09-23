// lib/data/power_data.dart
import 'package:trip_planner_app/models/power_info_model.dart';

final List<PowerInfo> powerData = [
  PowerInfo(
    country: 'United Kingdom',
    plugTypes: 'Type G',
    voltage: '230V',
    frequency: '50Hz',
  ),
  PowerInfo(
    country: 'United States',
    plugTypes: 'Type A, B',
    voltage: '120V',
    frequency: '60Hz',
  ),
  PowerInfo(
    country: 'Japan',
    plugTypes: 'Type A, B',
    voltage: '100V',
    frequency: '50/60Hz',
  ),
  PowerInfo(
    country: 'Australia',
    plugTypes: 'Type I',
    voltage: '230V',
    frequency: '50Hz',
  ),
  PowerInfo(
    country: 'Sri Lanka',
    plugTypes: 'Type D, G, M',
    voltage: '230V',
    frequency: '50Hz',
  ),
];
