import 'dart:async';
import '../models/admin_hospital_model.dart';
import '../models/hospital_model.dart';

/// Service abstraction for Admin Hospital Management.
/// Supports in-memory mock repository with instant mutations and is ready for Express API integration.
class AdminHospitalService {
  static final AdminHospitalService _instance = AdminHospitalService._internal();
  factory AdminHospitalService() => _instance;
  AdminHospitalService._internal();

  final List<AdminHospitalDetail> _hospitals = [
    AdminHospitalDetail(
      id: '0aae24e7-b1cb-400c-8a3b-a8ec361a1ea8',
      applicationId: 'AYUSH-HOSP-2026-63301',
      facilityName: 'National Institute of Ayurveda Hospital',
      facilityType: 'Government AYUSH Institute',
      ayushSystem: 'Ayurveda',
      state: 'Rajasthan',
      district: 'Jaipur',
      address: 'Jorawar Singh Gate, Amer Road',
      pinCode: '302002',
      officialEmail: 'contact@nia.ayush.gov.in',
      officialPhone: '+91 98290 12345',
      registrationNumber: 'AYUSH-RJ-2024-0091',
      ayushId: 'AYUSH/FIR/2026/0482',
      hfrId: 'HFR-IN-RJ-009182',
      verificationStatus: VerificationStatus.pending,
      createdAt: '26 Aug 2026, 06:32 PM',
      authorizedOfficials: [
        HospitalOfficial(
          id: 'off-1',
          hospitalId: '0aae24e7-b1cb-400c-8a3b-a8ec361a1ea8',
          fullName: 'Dr. Rajeshwar Sharma',
          designation: 'Chief Medical Superintendent',
          officialEmail: 'r.sharma@nia.ayush.gov.in',
          officialPhone: '+91 98290 12345',
          isPrimary: true,
        ),
      ],
      documents: [
        HospitalDocument(
          id: 'doc-1',
          hospitalId: '0aae24e7-b1cb-400c-8a3b-a8ec361a1ea8',
          documentType: 'registration_certificate',
          storagePath: 'certificates/nia_reg_cert.pdf',
          originalFilename: 'ayush_registration_certificate.pdf',
          mimeType: 'application/pdf',
          documentStatus: 'pending',
          uploadedAt: '26 Aug 2026',
        ),
        HospitalDocument(
          id: 'doc-2',
          hospitalId: '0aae24e7-b1cb-400c-8a3b-a8ec361a1ea8',
          documentType: 'authorized_official_id',
          storagePath: 'ids/dr_sharma_id.pdf',
          originalFilename: 'authorized_person_id.pdf',
          mimeType: 'application/pdf',
          documentStatus: 'pending',
          uploadedAt: '26 Aug 2026',
        ),
      ],
      verificationHistory: [
        VerificationHistoryItem(
          id: 'hist-1',
          hospitalId: '0aae24e7-b1cb-400c-8a3b-a8ec361a1ea8',
          previousStatus: null,
          newStatus: 'pending',
          action: 'registration_submitted',
          notes: 'Initial hospital onboarding registration submitted via MediKiosk Portal',
          createdAt: '26 Aug 2026, 06:32 PM',
        ),
      ],
    ),
    AdminHospitalDetail(
      id: '2ab59ab8-e20b-4070-bd47-f86ceadeb5a3',
      applicationId: 'AYUSH-HOSP-2026-78629',
      facilityName: 'Government Siddha Medical Hospital',
      facilityType: 'Government AYUSH Institute',
      ayushSystem: 'Siddha',
      state: 'Tamil Nadu',
      district: 'Chennai',
      address: 'Grand Southern Trunk Rd, Sanatorium, Tambaram',
      pinCode: '600047',
      officialEmail: 'admin@siddhahospital.tn.gov.in',
      officialPhone: '+91 94441 23456',
      registrationNumber: 'AYUSH-TN-2025-0142',
      ayushId: 'AYUSH/SID/2026/0991',
      hfrId: null, // OPTIONAL test case (Not Provided)
      verificationStatus: VerificationStatus.under_review,
      createdAt: '25 Aug 2026, 11:15 AM',
      authorizedOfficials: [
        HospitalOfficial(
          id: 'off-2',
          hospitalId: '2ab59ab8-e20b-4070-bd47-f86ceadeb5a3',
          fullName: 'Dr. K. Meenakshi',
          designation: 'Medical Superintendent',
          officialEmail: 'meenakshi@siddhahospital.tn.gov.in',
          officialPhone: '+91 94441 23456',
          isPrimary: true,
        ),
      ],
      documents: [
        HospitalDocument(
          id: 'doc-3',
          hospitalId: '2ab59ab8-e20b-4070-bd47-f86ceadeb5a3',
          documentType: 'registration_certificate',
          storagePath: 'certificates/tn_siddha.pdf',
          originalFilename: 'tamilnadu_siddha_license.pdf',
          uploadedAt: '25 Aug 2026',
        ),
      ],
      verificationHistory: [
        VerificationHistoryItem(
          id: 'hist-2',
          hospitalId: '2ab59ab8-e20b-4070-bd47-f86ceadeb5a3',
          previousStatus: null,
          newStatus: 'pending',
          action: 'registration_submitted',
          createdAt: '25 Aug 2026, 11:15 AM',
        ),
        VerificationHistoryItem(
          id: 'hist-3',
          hospitalId: '2ab59ab8-e20b-4070-bd47-f86ceadeb5a3',
          previousStatus: 'pending',
          newStatus: 'under_review',
          action: 'moved_to_under_review',
          notes: 'Application picked up by Verification Officer',
          createdAt: '26 Aug 2026, 10:00 AM',
        ),
      ],
    ),
    AdminHospitalDetail(
      id: '3cde56f1-c301-4982-a721-998811223344',
      applicationId: 'AYUSH-HOSP-2026-44102',
      facilityName: 'All India Institute of Ayurveda',
      facilityType: 'Government AYUSH Institute',
      ayushSystem: 'Ayurveda',
      state: 'Delhi',
      district: 'South Delhi',
      address: 'Mathura Road, Gautampuri, Sarita Vihar',
      pinCode: '110076',
      officialEmail: 'director@aiia.gov.in',
      officialPhone: '+91 11 2695 0401',
      registrationNumber: 'AYUSH-DL-2023-0001',
      ayushId: 'AYUSH/NAT/2026/0001',
      hfrId: 'HFR-IN-DL-000192',
      verificationStatus: VerificationStatus.verified,
      verifiedAt: '20 Aug 2026, 04:00 PM',
      createdAt: '18 Aug 2026, 09:30 AM',
      authorizedOfficials: [
        HospitalOfficial(
          id: 'off-3',
          hospitalId: '3cde56f1-c301-4982-a721-998811223344',
          fullName: 'Prof. (Dr.) Tanuja Nesari',
          designation: 'Director & CMS',
          officialEmail: 'director@aiia.gov.in',
          officialPhone: '+91 11 2695 0401',
          isPrimary: true,
        ),
      ],
      verificationHistory: [
        VerificationHistoryItem(
          id: 'hist-4',
          hospitalId: '3cde56f1-c301-4982-a721-998811223344',
          previousStatus: null,
          newStatus: 'pending',
          action: 'registration_submitted',
          createdAt: '18 Aug 2026, 09:30 AM',
        ),
        VerificationHistoryItem(
          id: 'hist-5',
          hospitalId: '3cde56f1-c301-4982-a721-998811223344',
          previousStatus: 'pending',
          newStatus: 'under_review',
          action: 'moved_to_under_review',
          createdAt: '19 Aug 2026, 02:00 PM',
        ),
        VerificationHistoryItem(
          id: 'hist-6',
          hospitalId: '3cde56f1-c301-4982-a721-998811223344',
          previousStatus: 'under_review',
          newStatus: 'verified',
          action: 'hospital_approved',
          notes: 'NABH and Central AYUSH accreditation verified',
          createdAt: '20 Aug 2026, 04:00 PM',
        ),
      ],
    ),
    AdminHospitalDetail(
      id: '4def78a2-d402-5093-b832-112233445566',
      applicationId: 'AYUSH-HOSP-2026-11982',
      facilityName: 'Patanjali Yogpeeth & Wellness Center',
      facilityType: 'Trust / NGO AYUSH Center',
      ayushSystem: 'Yoga & Naturopathy',
      state: 'Uttarakhand',
      district: 'Haridwar',
      address: 'Maharishi Dayanand Gram, Delhi-Haridwar Highway',
      pinCode: '249405',
      officialEmail: 'info@patanjaliwellness.org',
      officialPhone: '+91 1334 240008',
      registrationNumber: 'AYUSH-UK-2024-0812',
      ayushId: 'AYUSH/YOG/2026/0122',
      hfrId: 'HFR-IN-UK-008120',
      verificationStatus: VerificationStatus.rejected,
      rejectionReason: 'Invalid Clinical Establishment Registration copy and missing authorized nodal officer ID.',
      createdAt: '10 Aug 2026, 02:20 PM',
      authorizedOfficials: [
        HospitalOfficial(
          id: 'off-4',
          hospitalId: '4def78a2-d402-5093-b832-112233445566',
          fullName: 'Acharya Balkrishna',
          designation: 'General Secretary',
          officialEmail: 'info@patanjaliwellness.org',
          officialPhone: '+91 1334 240008',
          isPrimary: true,
        ),
      ],
      verificationHistory: [
        VerificationHistoryItem(
          id: 'hist-7',
          hospitalId: '4def78a2-d402-5093-b832-112233445566',
          previousStatus: null,
          newStatus: 'pending',
          action: 'registration_submitted',
          createdAt: '10 Aug 2026, 02:20 PM',
        ),
        VerificationHistoryItem(
          id: 'hist-8',
          hospitalId: '4def78a2-d402-5093-b832-112233445566',
          previousStatus: 'pending',
          newStatus: 'under_review',
          action: 'moved_to_under_review',
          createdAt: '11 Aug 2026, 11:00 AM',
        ),
        VerificationHistoryItem(
          id: 'hist-9',
          hospitalId: '4def78a2-d402-5093-b832-112233445566',
          previousStatus: 'under_review',
          newStatus: 'rejected',
          action: 'hospital_rejected',
          rejectionReason: 'Invalid Clinical Establishment Registration copy and missing authorized nodal officer ID.',
          createdAt: '12 Aug 2026, 03:45 PM',
        ),
      ],
    ),
  ];

  Map<String, int> getStatistics() {
    int total = _hospitals.length;
    int pending = _hospitals.where((h) => h.verificationStatus == VerificationStatus.pending).length;
    int underReview = _hospitals.where((h) => h.verificationStatus == VerificationStatus.under_review).length;
    int verified = _hospitals.where((h) => h.verificationStatus == VerificationStatus.verified).length;
    int rejected = _hospitals.where((h) => h.verificationStatus == VerificationStatus.rejected).length;

    return {
      'total': total,
      'pending': pending,
      'under_review': underReview,
      'verified': verified,
      'rejected': rejected,
    };
  }

  Future<List<AdminHospitalDetail>> getHospitals({VerificationStatus? status, String? search}) async {
    var results = List<AdminHospitalDetail>.from(_hospitals);

    if (status != null) {
      results = results.where((h) => h.verificationStatus == status).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      results = results.where((h) {
        return h.facilityName.toLowerCase().contains(query) ||
            h.applicationId.toLowerCase().contains(query) ||
            h.registrationNumber.toLowerCase().contains(query) ||
            (h.hfrId != null && h.hfrId!.toLowerCase().contains(query)) ||
            h.state.toLowerCase().contains(query) ||
            h.district.toLowerCase().contains(query);
      }).toList();
    }

    return results;
  }

  Future<List<AdminHospitalDetail>> getPendingHospitals() async {
    return getHospitals(status: VerificationStatus.pending);
  }

  Future<AdminHospitalDetail> getHospitalDetails(String hospitalId) async {
    final hospital = _hospitals.firstWhere(
      (h) => h.id == hospitalId || h.applicationId == hospitalId,
      orElse: () => throw Exception('Hospital not found'),
    );
    return hospital;
  }

  Future<AdminHospitalDetail> startReview(String hospitalId) async {
    final index = _hospitals.indexWhere((h) => h.id == hospitalId || h.applicationId == hospitalId);
    if (index == -1) throw Exception('Hospital not found');

    final hospital = _hospitals[index];
    if (hospital.verificationStatus != VerificationStatus.pending) {
      throw Exception("Cannot move to under_review from status '${hospital.verificationStatus.displayName}'");
    }

    hospital.verificationStatus = VerificationStatus.under_review;
    hospital.verificationHistory.add(
      VerificationHistoryItem(
        id: 'hist-${DateTime.now().millisecondsSinceEpoch}',
        hospitalId: hospital.id,
        previousStatus: 'pending',
        newStatus: 'under_review',
        action: 'moved_to_under_review',
        notes: 'Verification review started by Administrator',
        createdAt: 'Just now',
      ),
    );

    return hospital;
  }

  Future<AdminHospitalDetail> approveHospital(String hospitalId, {String? notes}) async {
    final index = _hospitals.indexWhere((h) => h.id == hospitalId || h.applicationId == hospitalId);
    if (index == -1) throw Exception('Hospital not found');

    final hospital = _hospitals[index];
    if (hospital.verificationStatus != VerificationStatus.under_review &&
        hospital.verificationStatus != VerificationStatus.pending) {
      throw Exception("Cannot approve hospital from status '${hospital.verificationStatus.displayName}'");
    }

    final prevStatus = hospital.verificationStatus.name;
    hospital.verificationStatus = VerificationStatus.verified;
    hospital.rejectionReason = null;
    hospital.verifiedAt = 'Today';
    hospital.verificationHistory.add(
      VerificationHistoryItem(
        id: 'hist-${DateTime.now().millisecondsSinceEpoch}',
        hospitalId: hospital.id,
        previousStatus: prevStatus,
        newStatus: 'verified',
        action: 'hospital_approved',
        notes: notes ?? 'AYUSH facility credentials approved by verification authority',
        createdAt: 'Just now',
      ),
    );

    return hospital;
  }

  Future<AdminHospitalDetail> rejectHospital(String hospitalId, String reason, {String? notes}) async {
    if (reason.trim().isEmpty) {
      throw Exception('Rejection reason is required');
    }

    final index = _hospitals.indexWhere((h) => h.id == hospitalId || h.applicationId == hospitalId);
    if (index == -1) throw Exception('Hospital not found');

    final hospital = _hospitals[index];
    if (hospital.verificationStatus == VerificationStatus.verified) {
      throw Exception('Cannot reject an already verified hospital');
    }

    final prevStatus = hospital.verificationStatus.name;
    hospital.verificationStatus = VerificationStatus.rejected;
    hospital.rejectionReason = reason.trim();
    hospital.verificationHistory.add(
      VerificationHistoryItem(
        id: 'hist-${DateTime.now().millisecondsSinceEpoch}',
        hospitalId: hospital.id,
        previousStatus: prevStatus,
        newStatus: 'rejected',
        action: 'hospital_rejected',
        rejectionReason: reason.trim(),
        notes: notes ?? 'Hospital onboarding rejected',
        createdAt: 'Just now',
      ),
    );

    return hospital;
  }
}
