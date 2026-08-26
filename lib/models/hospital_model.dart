import 'package:flutter/material.dart';

/// Enum representing the verification status of an AYUSH hospital.
enum VerificationStatus {
  pending,
  // ignore: constant_identifier_names
  under_review,
  verified,
  rejected;

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending Verification';
      case VerificationStatus.under_review:
        return 'Under Review';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case VerificationStatus.pending:
        return const Color(0xFFE0530B); // Saffron Dark
      case VerificationStatus.under_review:
        return const Color(0xFF1E3A8A); // Navy Accent / Blue
      case VerificationStatus.verified:
        return const Color(0xFF046A38); // India Green
      case VerificationStatus.rejected:
        return const Color(0xFFDC2626); // Alert Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case VerificationStatus.pending:
        return const Color(0xFFFFF2EC);
      case VerificationStatus.under_review:
        return const Color(0xFFEFF6FF);
      case VerificationStatus.verified:
        return const Color(0xFFEDF7F2);
      case VerificationStatus.rejected:
        return const Color(0xFFFEF2F2);
    }
  }

  IconData get icon {
    switch (this) {
      case VerificationStatus.pending:
        return Icons.hourglass_top_rounded;
      case VerificationStatus.under_review:
        return Icons.policy_rounded;
      case VerificationStatus.verified:
        return Icons.verified_user_rounded;
      case VerificationStatus.rejected:
        return Icons.cancel_outlined;
    }
  }
}

/// Data model representing an AYUSH Hospital.
class AyushHospital {
  final String applicationId;
  final String hospitalName;
  final String regNumber;
  final String ayushId;
  final String address;
  final String state;
  final String district;
  final String hospitalType;
  String authorizedPersonName;
  String authorizedPersonDesignation;
  String officialEmail;
  String phoneNumber;
  final String password;
  final String? regCertFileName;
  final String? authorizedPersonIdFileName;
  VerificationStatus verificationStatus;
  final String submittedDate;

  AyushHospital({
    required this.applicationId,
    required this.hospitalName,
    required this.regNumber,
    required this.ayushId,
    required this.address,
    required this.state,
    required this.district,
    required this.hospitalType,
    required this.authorizedPersonName,
    this.authorizedPersonDesignation = 'Medical Superintendent',
    required this.officialEmail,
    required this.phoneNumber,
    required this.password,
    this.regCertFileName,
    this.authorizedPersonIdFileName,
    this.verificationStatus = VerificationStatus.pending,
    required this.submittedDate,
  });

  /// Factory constructor for mock demo hospital.
  factory AyushHospital.mock({VerificationStatus status = VerificationStatus.verified}) {
    return AyushHospital(
      applicationId: 'AYUSH-HOSP-2026-89412',
      hospitalName: 'National Institute of Ayurveda Hospital',
      regNumber: 'AYUSH-RJ-2024-0091',
      ayushId: 'AYUSH/FIR/2026/0482',
      address: 'Jorawar Singh Gate, Amer Road',
      state: 'Rajasthan',
      district: 'Jaipur',
      hospitalType: 'Government AYUSH Institute',
      authorizedPersonName: 'Dr. Rajeshwar Sharma',
      authorizedPersonDesignation: 'Chief Medical Superintendent',
      officialEmail: 'contact@nia.ayush.gov.in',
      phoneNumber: '+91 98290 12345',
      password: 'password123',
      regCertFileName: 'ayush_registration_certificate.pdf',
      authorizedPersonIdFileName: 'authorized_person_id.pdf',
      verificationStatus: status,
      submittedDate: '26 August 2026',
    );
  }
}
