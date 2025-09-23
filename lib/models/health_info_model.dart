// lib/models/health_info_model.dart

// පොදු මාතෘකා සඳහා (Vaccinations, Health Risks)
class HealthTopic {
  final String title;
  final String subtitle;
  final String riskLevel; // e.g., 'Recommended', 'Moderate Risk'

  HealthTopic({
    required this.title,
    required this.subtitle,
    required this.riskLevel,
  });
}

// වෛද්‍ය මධ්‍යස්ථාන සඳහා
class MedicalFacility {
  final String name;
  final String address;
  final String phone;

  MedicalFacility({
    required this.name,
    required this.address,
    required this.phone,
  });
}
