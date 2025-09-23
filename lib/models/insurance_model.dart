// lib/models/insurance_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class InsuranceInfo {
  final String? id;
  final String providerName;
  final String policyNumber;
  final Timestamp coverageStartDate;
  final Timestamp coverageEndDate;
  final String medicalCoverage;
  final String baggageCoverage;
  final String customerServicePhone;
  final String emergencyAssistPhone;
  final String userId;

  InsuranceInfo({
    this.id,
    required this.providerName,
    required this.policyNumber,
    required this.coverageStartDate,
    required this.coverageEndDate,
    required this.medicalCoverage,
    required this.baggageCoverage,
    required this.customerServicePhone,
    required this.emergencyAssistPhone,
    required this.userId,
  });

  factory InsuranceInfo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InsuranceInfo(
      id: doc.id,
      providerName: data['providerName'] ?? '',
      policyNumber: data['policyNumber'] ?? '',
      coverageStartDate: data['coverageStartDate'] ?? Timestamp.now(),
      coverageEndDate: data['coverageEndDate'] ?? Timestamp.now(),
      medicalCoverage: data['medicalCoverage'] ?? '',
      baggageCoverage: data['baggageCoverage'] ?? '',
      customerServicePhone: data['customerServicePhone'] ?? '',
      emergencyAssistPhone: data['emergencyAssistPhone'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerName': providerName,
      'policyNumber': policyNumber,
      'coverageStartDate': coverageStartDate,
      'coverageEndDate': coverageEndDate,
      'medicalCoverage': medicalCoverage,
      'baggageCoverage': baggageCoverage,
      'customerServicePhone': customerServicePhone,
      'emergencyAssistPhone': emergencyAssistPhone,
      'userId': userId,
    };
  }
}
