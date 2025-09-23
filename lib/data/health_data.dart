// lib/data/health_data.dart
import 'package:trip_planner_app/models/health_info_model.dart';

// Vaccinations Data
final List<HealthTopic> vaccinationData = [
  HealthTopic(
    title: 'Hepatitis A',
    subtitle: 'Recommended for all travelers',
    riskLevel: 'Recommended',
  ),
  HealthTopic(
    title: 'Typhoid',
    subtitle: 'Recommended for most travelers',
    riskLevel: 'Recommended',
  ),
  HealthTopic(
    title: 'Yellow Fever',
    subtitle: 'Required if traveling from certain countries',
    riskLevel: 'Required',
  ),
];

// Health Risks Data
final List<HealthTopic> healthRisksData = [
  HealthTopic(
    title: 'Malaria',
    subtitle: 'Consider antimalarial medication',
    riskLevel: 'Moderate Risk',
  ),
  HealthTopic(
    title: 'Dengue Fever',
    subtitle: 'Use mosquito repellent',
    riskLevel: 'Moderate Risk',
  ),
];

// Medical Facilities Data
final List<MedicalFacility> medicalFacilitiesData = [
  MedicalFacility(
    name: 'General Hospital',
    address: '123 Main Street, Anytown',
    phone: '+1-555-123-4567',
  ),
  MedicalFacility(
    name: 'Community Clinic',
    address: '456 Oak Avenue, Anytown',
    phone: '+1-555-987-6543',
  ),
];
