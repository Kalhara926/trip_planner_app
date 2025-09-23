// lib/models/power_info_model.dart

class PowerInfo {
  final String country;
  final String plugTypes;
  final String voltage;
  final String frequency;

  PowerInfo({
    required this.country,
    required this.plugTypes,
    required this.voltage,
    required this.frequency,
  });
}
