import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/admin_hospital_model.dart';
import '../models/hospital_model.dart';

/// Custom API Exception for user-friendly error propagation
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// AdminHospitalService communicates with the Express Backend API.
/// Provides verification management, search, status filtering, and audit history.
class AdminHospitalService {
  static final AdminHospitalService _instance = AdminHospitalService._internal();
  factory AdminHospitalService({http.Client? client, bool? useMockData}) {
    if (client != null) _instance._client = client;
    if (useMockData != null) _instance.useMockData = useMockData;
    return _instance;
  }
  AdminHospitalService._internal();

  http.Client _client = http.Client();
  bool useMockData = false;

  // In-memory fallback mock dataset for offline test fixtures
  final List<AdminHospitalDetail> _mockHospitals = [
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
      hfrId: null,
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
          notes: 'Assigned to Verification Officer for document compliance check',
          createdAt: '25 Aug 2026, 02:40 PM',
        ),
      ],
    ),
    AdminHospitalDetail(
      id: '3bcc89c1-c301-4182-a721-e75bfbeec6b4',
      applicationId: 'AYUSH-HOSP-2026-90114',
      facilityName: 'Central Research Institute of Unani Medicine',
      facilityType: 'Research Institute & Hospital',
      ayushSystem: 'Unani',
      state: 'Telangana',
      district: 'Hyderabad',
      address: 'Opp. ESI Hospital, AG Colony Road, Erragadda',
      pinCode: '500038',
      officialEmail: 'crium.hyderabad@ayush.gov.in',
      officialPhone: '+91 40 2381 1234',
      registrationNumber: 'AYUSH-TG-2023-0056',
      ayushId: 'AYUSH/UNI/2026/0319',
      hfrId: 'HFR-IN-TG-005619',
      verificationStatus: VerificationStatus.verified,
      verifiedAt: '24 Aug 2026, 04:10 PM',
      createdAt: '20 Aug 2026, 09:30 AM',
      authorizedOfficials: [
        HospitalOfficial(
          id: 'off-3',
          hospitalId: '3bcc89c1-c301-4182-a721-e75bfbeec6b4',
          fullName: 'Prof. Mohammad Tariq',
          designation: 'Director In-charge',
          officialEmail: 'director.crium@ayush.gov.in',
          officialPhone: '+91 40 2381 1234',
          isPrimary: true,
        ),
      ],
      verificationHistory: [
        VerificationHistoryItem(
          id: 'hist-4',
          hospitalId: '3bcc89c1-c301-4182-a721-e75bfbeec6b4',
          previousStatus: null,
          newStatus: 'pending',
          action: 'registration_submitted',
          createdAt: '20 Aug 2026, 09:30 AM',
        ),
        VerificationHistoryItem(
          id: 'hist-5',
          hospitalId: '3bcc89c1-c301-4182-a721-e75bfbeec6b4',
          previousStatus: 'pending',
          newStatus: 'under_review',
          action: 'moved_to_under_review',
          createdAt: '22 Aug 2026, 10:00 AM',
        ),
        VerificationHistoryItem(
          id: 'hist-6',
          hospitalId: '3bcc89c1-c301-4182-a721-e75bfbeec6b4',
          previousStatus: 'under_review',
          newStatus: 'verified',
          action: 'hospital_approved',
          notes: 'All clinical establishment documents and AYUSH registration verified successfully',
          createdAt: '24 Aug 2026, 04:10 PM',
        ),
      ],
    ),
    AdminHospitalDetail(
      id: '4def78a2-d402-5093-b832-112233445566',
      applicationId: 'AYUSH-HOSP-2026-11894',
      facilityName: 'Patanjali Yogpeeth & Wellness Center',
      facilityType: 'Private AYUSH Super Speciality Hospital',
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

  // ==========================================================================
  // HTTP REQUEST HELPER WITH EXCEPTION HANDLING
  // ==========================================================================

  Future<dynamic> _sendRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(url);
    final headers = ApiConfig.defaultHeaders;

    try {
      http.Response response;
      if (method == 'GET') {
        response = await _client.get(uri, headers: headers).timeout(ApiConfig.requestTimeout);
      } else if (method == 'PATCH') {
        response = await _client
            .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(ApiConfig.requestTimeout);
      } else if (method == 'POST') {
        response = await _client
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(ApiConfig.requestTimeout);
      } else {
        throw ApiException('Unsupported HTTP method: $method');
      }

      final statusCode = response.statusCode;
      dynamic responseJson;
      try {
        responseJson = jsonDecode(response.body);
      } catch (_) {
        responseJson = null;
      }

      if (statusCode >= 200 && statusCode < 300) {
        return responseJson != null ? responseJson['data'] : null;
      }

      String errorMessage = 'Server responded with error status $statusCode';
      if (responseJson != null) {
        if (responseJson['errors'] != null && (responseJson['errors'] as List).isNotEmpty) {
          errorMessage = (responseJson['errors'] as List).join('\n');
        } else if (responseJson['message'] != null) {
          errorMessage = responseJson['message'].toString();
        }
      }

      throw ApiException(errorMessage, statusCode: statusCode);
    } on SocketException catch (_) {
      throw ApiException(
        'Cannot connect to MediKiosk backend server at ${ApiConfig.baseUrl}. Please check that the server is running.',
      );
    } on http.ClientException catch (_) {
      throw ApiException(
        'Network error communicating with ${ApiConfig.baseUrl}. Ensure CORS and local server are accessible.',
      );
    } on TimeoutException catch (_) {
      throw ApiException('Request to MediKiosk backend timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  // ==========================================================================
  // DASHBOARD STATISTICS API
  // ==========================================================================

  /// Fetches aggregate counts and recent registrations from GET /api/admin/dashboard
  Future<AdminDashboardData> getDashboardStats() async {
    if (useMockData) {
      return AdminDashboardData(
        totalHospitals: _mockHospitals.length,
        pending: _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.pending).length,
        underReview: _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.under_review).length,
        verified: _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.verified).length,
        rejected: _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.rejected).length,
        recentRegistrations: _mockHospitals.take(5).toList(),
      );
    }

    try {
      final data = await _sendRequest('GET', ApiConfig.adminDashboard);
      return AdminDashboardData.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      // If live backend call fails in test mode, fallback to in-memory stats
      if (useMockData) {
        return AdminDashboardData(
          totalHospitals: _mockHospitals.length,
          pending: _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.pending).length,
          underReview: _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.under_review).length,
          verified: _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.verified).length,
          rejected: _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.rejected).length,
          recentRegistrations: _mockHospitals.take(5).toList(),
        );
      }
      rethrow;
    }
  }

  /// Backward-compatible synchronous/fast stats helper
  Map<String, int> getStatistics() {
    int total = _mockHospitals.length;
    int pending = _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.pending).length;
    int underReview = _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.under_review).length;
    int verified = _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.verified).length;
    int rejected = _mockHospitals.where((h) => h.verificationStatus == VerificationStatus.rejected).length;

    return {
      'total': total,
      'pending': pending,
      'under_review': underReview,
      'verified': verified,
      'rejected': rejected,
    };
  }

  // ==========================================================================
  // HOSPITAL LIST & SEARCH API
  // ==========================================================================

  /// Fetches hospitals from GET /api/admin/hospitals with optional status filter and search query
  Future<List<AdminHospitalDetail>> getHospitals({
    VerificationStatus? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    if (useMockData) {
      var results = List<AdminHospitalDetail>.from(_mockHospitals);
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

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final url = '${ApiConfig.adminHospitals}?$queryString';

    final data = await _sendRequest('GET', url);
    final list = data as List? ?? [];
    return list.map((e) => AdminHospitalDetail.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches pending hospitals from GET /api/admin/hospitals/pending
  Future<List<AdminHospitalDetail>> getPendingHospitals({int page = 1, int limit = 50}) async {
    if (useMockData) {
      return getHospitals(status: VerificationStatus.pending);
    }
    final url = '${ApiConfig.adminPendingHospitals}?page=$page&limit=$limit';
    final data = await _sendRequest('GET', url);
    final list = data as List? ?? [];
    return list.map((e) => AdminHospitalDetail.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ==========================================================================
  // HOSPITAL DETAIL API
  // ==========================================================================

  /// Fetches full hospital details from GET /api/admin/hospitals/:hospitalId
  Future<AdminHospitalDetail> getHospitalDetails(String hospitalId) async {
    if (useMockData) {
      final hospital = _mockHospitals.firstWhere(
        (h) => h.id == hospitalId || h.applicationId == hospitalId,
        orElse: () => throw ApiException('Hospital not found', statusCode: 404),
      );
      return hospital;
    }

    final url = ApiConfig.adminHospitalDetail(hospitalId);
    final data = await _sendRequest('GET', url);
    return AdminHospitalDetail.fromJson(data as Map<String, dynamic>);
  }

  // ==========================================================================
  // STATUS TRANSITION ACTIONS
  // ==========================================================================

  /// Moves hospital to Under Review via PATCH /api/admin/hospitals/:hospitalId/under-review
  Future<AdminHospitalDetail> startReview(String hospitalId) async {
    if (useMockData) {
      final index = _mockHospitals.indexWhere((h) => h.id == hospitalId || h.applicationId == hospitalId);
      if (index == -1) throw ApiException('Hospital not found', statusCode: 404);

      final hospital = _mockHospitals[index];
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

    final url = ApiConfig.adminMarkUnderReview(hospitalId);
    await _sendRequest('PATCH', url);
    // Refresh complete updated hospital details
    return getHospitalDetails(hospitalId);
  }

  /// Approves hospital registration via PATCH /api/admin/hospitals/:hospitalId/approve
  Future<AdminHospitalDetail> approveHospital(String hospitalId, {String? notes}) async {
    if (useMockData) {
      final index = _mockHospitals.indexWhere((h) => h.id == hospitalId || h.applicationId == hospitalId);
      if (index == -1) throw ApiException('Hospital not found', statusCode: 404);

      final hospital = _mockHospitals[index];
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

    final url = ApiConfig.adminApproveHospital(hospitalId);
    await _sendRequest('PATCH', url, body: {'notes': notes});
    // Refresh complete updated hospital details
    return getHospitalDetails(hospitalId);
  }

  /// Rejects hospital registration via PATCH /api/admin/hospitals/:hospitalId/reject
  Future<AdminHospitalDetail> rejectHospital(String hospitalId, String reason, {String? notes}) async {
    if (useMockData) {
      final index = _mockHospitals.indexWhere((h) => h.id == hospitalId || h.applicationId == hospitalId);
      if (index == -1) throw ApiException('Hospital not found', statusCode: 404);

      final hospital = _mockHospitals[index];
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
          notes: notes,
          createdAt: 'Just now',
        ),
      );
      return hospital;
    }

    final url = ApiConfig.adminRejectHospital(hospitalId);
    final payload = <String, dynamic>{'reason': reason.trim()};
    if (notes != null) payload['notes'] = notes;
    await _sendRequest('PATCH', url, body: payload);
    // Refresh complete updated hospital details
    return getHospitalDetails(hospitalId);
  }

  /// Registers a new hospital submitted through the Hospital Portal
  Future<void> registerHospital(AyushHospital hospital) async {
    if (useMockData) {
      final detail = AdminHospitalDetail(
        id: hospital.applicationId,
        applicationId: hospital.applicationId,
        facilityName: hospital.hospitalName,
        facilityType: hospital.hospitalType,
        ayushSystem: 'Ayurveda',
        state: hospital.state,
        district: hospital.district,
        address: hospital.address,
        officialEmail: hospital.officialEmail,
        officialPhone: hospital.phoneNumber,
        registrationNumber: hospital.regNumber,
        ayushId: hospital.ayushId,
        verificationStatus: hospital.verificationStatus,
        createdAt: hospital.submittedDate,
        authorizedOfficials: [
          HospitalOfficial(
            id: 'off-${hospital.applicationId}',
            hospitalId: hospital.applicationId,
            fullName: hospital.authorizedPersonName,
            designation: hospital.authorizedPersonDesignation,
            officialEmail: hospital.officialEmail,
            officialPhone: hospital.phoneNumber,
          ),
        ],
        documents: [
          if (hospital.regCertFileName != null)
            HospitalDocument(
              id: 'doc-cert-${hospital.applicationId}',
              hospitalId: hospital.applicationId,
              documentType: 'registration_certificate',
              storagePath: 'certificates/${hospital.regCertFileName}',
              originalFilename: hospital.regCertFileName!,
              uploadedAt: hospital.submittedDate,
            ),
          if (hospital.authorizedPersonIdFileName != null)
            HospitalDocument(
              id: 'doc-id-${hospital.applicationId}',
              hospitalId: hospital.applicationId,
              documentType: 'authorized_official_id',
              storagePath: 'ids/${hospital.authorizedPersonIdFileName}',
              originalFilename: hospital.authorizedPersonIdFileName!,
              uploadedAt: hospital.submittedDate,
            ),
        ],
        verificationHistory: [
          VerificationHistoryItem(
            id: 'hist-init-${hospital.applicationId}',
            hospitalId: hospital.applicationId,
            newStatus: 'pending',
            action: 'registration_submitted',
            notes: 'Hospital submitted onboarding application',
            createdAt: hospital.submittedDate,
          ),
        ],
      );

      _mockHospitals.insert(0, detail);
      return;
    }

    final payload = {
      "facility_name": hospital.hospitalName,
      "facility_type": hospital.hospitalType,
      "state": hospital.state,
      "district": hospital.district,
      "address": hospital.address,
      "official_email": hospital.officialEmail,
      "official_phone": hospital.phoneNumber,
      "registration_number": hospital.regNumber,
      "hfr_id": hospital.ayushId,
      "password": hospital.password,
      "authorized_official": {
        "full_name": hospital.authorizedPersonName,
        "designation": hospital.authorizedPersonDesignation,
        "official_email": hospital.officialEmail,
        "official_phone": hospital.phoneNumber
      }
    };

    await _sendRequest('POST', ApiConfig.hospitalRegister, body: payload);
  }

  /// Finds a registered hospital by ID, application ID, or email for login check (Mock Mode Only)
  AyushHospital? _findHospitalForLoginMock(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;

    final match = _mockHospitals.cast<AdminHospitalDetail?>().firstWhere(
      (h) =>
          h?.id.toLowerCase() == q ||
          h?.applicationId.toLowerCase() == q ||
          h?.officialEmail.toLowerCase() == q ||
          h?.registrationNumber.toLowerCase() == q,
      orElse: () => null,
    );

    if (match == null) return null;

    final primaryOfficial = match.authorizedOfficials.isNotEmpty ? match.authorizedOfficials.first : null;

    return AyushHospital(
      applicationId: match.applicationId,
      hospitalName: match.facilityName,
      regNumber: match.registrationNumber,
      ayushId: match.ayushId ?? 'AYUSH/FIR/2026/0000',
      address: match.address,
      state: match.state,
      district: match.district,
      hospitalType: match.facilityType,
      authorizedPersonName: primaryOfficial?.fullName ?? 'Authorized Officer',
      authorizedPersonDesignation: primaryOfficial?.designation ?? 'Medical Superintendent',
      officialEmail: primaryOfficial?.officialEmail ?? match.officialEmail,
      phoneNumber: primaryOfficial?.officialPhone ?? match.officialPhone,
      password: 'password123',
      verificationStatus: match.verificationStatus,
      submittedDate: match.createdAt,
    );
  }

  /// Authenticates a hospital using their registration ID or email and password
  Future<AyushHospital> loginHospital(String identifier, String password) async {
    if (useMockData) {
      final hospital = _findHospitalForLoginMock(identifier);
      if (hospital == null || password != 'password123') {
        throw ApiException('Invalid credentials', statusCode: 401);
      }
      return hospital;
    }

    final payload = {
      'identifier': identifier.trim(),
      'password': password,
    };

    final data = await _sendRequest('POST', ApiConfig.hospitalLogin, body: payload);
    
    final map = data as Map<String, dynamic>;
    final official = map['primary_official'] as Map<String, dynamic>?;

    VerificationStatus parsedStatus = VerificationStatus.pending;
    try {
      final statusStr = (map['verification_status'] as String?)?.toLowerCase();
      if (statusStr != null) {
        parsedStatus = VerificationStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => VerificationStatus.pending
        );
      }
    } catch (_) {}

    return AyushHospital(
      applicationId: map['application_id'] ?? '',
      hospitalName: map['facility_name'] ?? '',
      regNumber: map['registration_number'] ?? '',
      ayushId: map['ayush_id'] ?? '',
      address: map['address'] ?? '',
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      hospitalType: map['facility_type'] ?? '',
      authorizedPersonName: official?['full_name'] ?? '',
      authorizedPersonDesignation: official?['designation'] ?? '',
      officialEmail: map['official_email'] ?? '',
      phoneNumber: map['official_phone'] ?? '',
      password: '', // Clear password for security
      verificationStatus: parsedStatus,
      submittedDate: map['created_at'] ?? '',
    );
  }

  /// Quickly fetches the current verification status for a hospital
  Future<VerificationStatus> checkHospitalStatus(String applicationId) async {
    if (useMockData) {
      final hospital = _findHospitalForLoginMock(applicationId);
      return hospital?.verificationStatus ?? VerificationStatus.pending;
    }

    final data = await _sendRequest('GET', ApiConfig.hospitalStatus(applicationId));
    final map = data as Map<String, dynamic>;
    
    try {
      final statusStr = (map['verification_status'] as String?)?.toLowerCase();
      if (statusStr != null) {
        return VerificationStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => VerificationStatus.pending
        );
      }
    } catch (_) {}
    
    return VerificationStatus.pending;
  }
}
