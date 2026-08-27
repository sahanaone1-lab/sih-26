import 'hospital_model.dart';

/// Authorized Hospital Official model
class HospitalOfficial {
  final String id;
  final String hospitalId;
  final String fullName;
  final String designation;
  final String officialEmail;
  final String officialPhone;
  final bool isPrimary;

  HospitalOfficial({
    required this.id,
    required this.hospitalId,
    required this.fullName,
    required this.designation,
    required this.officialEmail,
    required this.officialPhone,
    this.isPrimary = true,
  });

  factory HospitalOfficial.fromJson(Map<String, dynamic> json) {
    return HospitalOfficial(
      id: json['id']?.toString() ?? '',
      hospitalId: json['hospital_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      officialEmail: json['official_email']?.toString() ?? '',
      officialPhone: json['official_phone']?.toString() ?? '',
      isPrimary: json['is_primary'] == true,
    );
  }
}

/// Uploaded Document metadata model
class HospitalDocument {
  final String id;
  final String hospitalId;
  final String documentType;
  final String storagePath;
  final String originalFilename;
  final String? mimeType;
  final String documentStatus;
  final String uploadedAt;

  HospitalDocument({
    required this.id,
    required this.hospitalId,
    required this.documentType,
    required this.storagePath,
    required this.originalFilename,
    this.mimeType,
    this.documentStatus = 'pending',
    required this.uploadedAt,
  });

  factory HospitalDocument.fromJson(Map<String, dynamic> json) {
    return HospitalDocument(
      id: json['id']?.toString() ?? '',
      hospitalId: json['hospital_id']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? 'registration_certificate',
      storagePath: json['storage_path']?.toString() ?? '',
      originalFilename: json['original_filename']?.toString() ?? 'document.pdf',
      mimeType: json['mime_type']?.toString(),
      documentStatus: json['document_status']?.toString() ?? 'pending',
      uploadedAt: json['uploaded_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

/// Verification History Audit item model
class VerificationHistoryItem {
  final String id;
  final String hospitalId;
  final String? previousStatus;
  final String newStatus;
  final String action;
  final String? rejectionReason;
  final String? notes;
  final String createdAt;

  VerificationHistoryItem({
    required this.id,
    required this.hospitalId,
    this.previousStatus,
    required this.newStatus,
    required this.action,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
  });

  factory VerificationHistoryItem.fromJson(Map<String, dynamic> json) {
    return VerificationHistoryItem(
      id: json['id']?.toString() ?? '',
      hospitalId: json['hospital_id']?.toString() ?? '',
      previousStatus: json['previous_status']?.toString(),
      newStatus: json['new_status']?.toString() ?? 'pending',
      action: json['action']?.toString() ?? 'status_updated',
      rejectionReason: json['rejection_reason']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

/// Complete detailed Hospital record for Admin Portal
class AdminHospitalDetail {
  final String id;
  final String applicationId;
  final String facilityName;
  final String facilityType;
  final String ayushSystem;
  final String state;
  final String district;
  final String address;
  final String? pinCode;
  final String officialEmail;
  final String officialPhone;
  final String registrationNumber;
  final String? ayushId;
  final String? hfrId;
  VerificationStatus verificationStatus;
  String? rejectionReason;
  String? verifiedAt;
  final String createdAt;
  final List<HospitalOfficial> authorizedOfficials;
  final List<HospitalDocument> documents;
  final List<VerificationHistoryItem> verificationHistory;

  AdminHospitalDetail({
    required this.id,
    required this.applicationId,
    required this.facilityName,
    required this.facilityType,
    required this.ayushSystem,
    required this.state,
    required this.district,
    required this.address,
    this.pinCode,
    required this.officialEmail,
    required this.officialPhone,
    required this.registrationNumber,
    this.ayushId,
    this.hfrId,
    required this.verificationStatus,
    this.rejectionReason,
    this.verifiedAt,
    required this.createdAt,
    this.authorizedOfficials = const [],
    this.documents = const [],
    this.verificationHistory = const [],
  });

  /// User-friendly HFR ID representation (displays "Not Provided" when null/empty)
  String get displayHfrId => (hfrId != null && hfrId!.trim().isNotEmpty) ? hfrId! : 'Not Provided';

  /// User-friendly AYUSH ID representation
  String get displayAyushId => (ayushId != null && ayushId!.trim().isNotEmpty) ? ayushId! : 'Not Provided';

  static VerificationStatus parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'under_review':
        return VerificationStatus.under_review;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'pending':
      default:
        return VerificationStatus.pending;
    }
  }

  factory AdminHospitalDetail.fromJson(Map<String, dynamic> json) {
    var officialsJson = json['authorized_officials'] as List? ?? json['hospital_officials'] as List? ?? [];
    var docsJson = json['documents'] as List? ?? json['hospital_documents'] as List? ?? [];
    var historyJson = json['verification_history'] as List? ?? json['hospital_verification_history'] as List? ?? [];

    return AdminHospitalDetail(
      id: json['id']?.toString() ?? '',
      applicationId: json['application_id']?.toString() ?? '',
      facilityName: json['facility_name']?.toString() ?? json['hospital_name']?.toString() ?? '',
      facilityType: json['facility_type']?.toString() ?? json['hospital_type']?.toString() ?? '',
      ayushSystem: json['ayush_system']?.toString() ?? 'Ayurveda',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pinCode: json['pin_code']?.toString(),
      officialEmail: json['official_email']?.toString() ?? '',
      officialPhone: json['official_phone']?.toString() ?? '',
      registrationNumber: json['registration_number']?.toString() ?? json['reg_number']?.toString() ?? '',
      ayushId: json['ayush_id']?.toString(),
      hfrId: json['hfr_id']?.toString(),
      verificationStatus: parseStatus(json['verification_status']?.toString()),
      rejectionReason: json['rejection_reason']?.toString(),
      verifiedAt: json['verified_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      authorizedOfficials: officialsJson.map((e) => HospitalOfficial.fromJson(e as Map<String, dynamic>)).toList(),
      documents: docsJson.map((e) => HospitalDocument.fromJson(e as Map<String, dynamic>)).toList(),
      verificationHistory: historyJson.map((e) => VerificationHistoryItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// Pagination metadata returned by API endpoints
class ApiPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  ApiPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ApiPagination.fromJson(Map<String, dynamic> json) {
    return ApiPagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Aggregated Admin Dashboard Statistics
class AdminDashboardData {
  final int totalHospitals;
  final int pending;
  final int underReview;
  final int verified;
  final int rejected;
  final List<AdminHospitalDetail> recentRegistrations;

  AdminDashboardData({
    required this.totalHospitals,
    required this.pending,
    required this.underReview,
    required this.verified,
    required this.rejected,
    required this.recentRegistrations,
  });

  Map<String, int> toStatsMap() {
    return {
      'total': totalHospitals,
      'pending': pending,
      'under_review': underReview,
      'verified': verified,
      'rejected': rejected,
    };
  }

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final recentList = json['recent_registrations'] as List? ?? [];
    return AdminDashboardData(
      totalHospitals: (json['total_hospitals'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      underReview: (json['under_review'] as num?)?.toInt() ?? 0,
      verified: (json['verified'] as num?)?.toInt() ?? 0,
      rejected: (json['rejected'] as num?)?.toInt() ?? 0,
      recentRegistrations: recentList.map((e) => AdminHospitalDetail.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
