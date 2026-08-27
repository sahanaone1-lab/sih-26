import '../models/patient_model.dart';

/// AbhaVerificationService — Demo/Mock ABHA verification and OTP service.
///
/// Architecture note: This service is deliberately separated from the UI so
/// that, in production, only this file needs to be swapped out for a real
/// ABDM PHR API implementation. The UI screens remain unchanged.
///
/// Production replacement path:
///   verifyAbhaId()  → POST /v1/registration/mobile/verify
///   generateOtp()   → POST /v1/registration/mobile/generateOtp
///   verifyOtp()     → POST /v1/registration/mobile/verifyOtp
///
/// DO NOT call any real government API here. This is a demo-only module.
class AbhaVerificationService {
  // ── Singleton ───────────────────────────────────────────────────────────────
  AbhaVerificationService._internal();
  static final AbhaVerificationService instance =
      AbhaVerificationService._internal();
  factory AbhaVerificationService() => instance;

  // ── Fixed Demo OTP ──────────────────────────────────────────────────────────
  static const String fixedDemoOtp = '123456';

  // ── Internal State ───────────────────────────────────────────────────────────
  PatientModel? _pendingPatient;

  // ── Demo Patient Database ────────────────────────────────────────────────────
  /// 6 demo patients covering a range of Indian states, genders, and ages.
  /// ABHA IDs follow the 14-digit national format (XX-XXXX-XXXX-XXXX).
  static final List<PatientModel> demoPatients = [
    const PatientModel(
      abhaId: '14-8912-3401-7752',
      name: 'Aarav Patel',
      dateOfBirth: '12 Mar 1986',
      age: 38,
      gender: 'Male',
      mobileNumber: '9876543210',
      bloodGroup: 'O+',
      state: 'Gujarat',
      district: 'Ahmedabad',
    ),
    const PatientModel(
      abhaId: '23-4567-8901-2345',
      name: 'Priya Sharma',
      dateOfBirth: '05 Jul 1995',
      age: 29,
      gender: 'Female',
      mobileNumber: '9988776655',
      bloodGroup: 'A+',
      state: 'Delhi',
      district: 'New Delhi',
    ),
    const PatientModel(
      abhaId: '34-5678-9012-3456',
      name: 'Ramesh Kumar',
      dateOfBirth: '20 Jan 1972',
      age: 52,
      gender: 'Male',
      mobileNumber: '9123456780',
      bloodGroup: 'B+',
      state: 'Maharashtra',
      district: 'Pune',
    ),
    const PatientModel(
      abhaId: '45-6789-0123-4567',
      name: 'Sunita Devi',
      dateOfBirth: '15 Sep 1979',
      age: 45,
      gender: 'Female',
      mobileNumber: '8765432109',
      bloodGroup: 'AB+',
      state: 'Rajasthan',
      district: 'Jaipur',
    ),
    const PatientModel(
      abhaId: '56-7890-1234-5678',
      name: 'Arjun Singh',
      dateOfBirth: '30 Nov 1993',
      age: 31,
      gender: 'Male',
      mobileNumber: '7654321098',
      bloodGroup: 'O-',
      state: 'Punjab',
      district: 'Amritsar',
    ),
    const PatientModel(
      abhaId: '67-8901-2345-6789',
      name: 'Meera Nair',
      dateOfBirth: '22 Apr 2001',
      age: 23,
      gender: 'Female',
      mobileNumber: '9012345678',
      bloodGroup: 'A-',
      state: 'Kerala',
      district: 'Kochi',
    ),
  ];

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Verifies the ABHA ID against the demo patient database.
  ///
  /// Returns the matched [PatientModel] if found, or `null` if not found.
  /// Accepts ABHA IDs with or without dashes (both formats are normalized).
  ///
  /// Production replacement: call ABDM /v1/registration/mobile/verify endpoint.
  PatientModel? verifyAbhaId(String abhaId) {
    final normalized = _normalize(abhaId);
    try {
      return demoPatients.firstWhere(
        (p) => _normalize(p.abhaId) == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  /// Initiates OTP request for the given patient.
  ///
  /// Stores the pending patient session internally.
  /// Uses fixed OTP `123456` internally for prototype verification.
  ///
  /// Production replacement: call ABDM OTP generation endpoint.
  void generateOtp(PatientModel patient) {
    _pendingPatient = patient;
  }

  /// Verifies the OTP entered by the user against the internal fixed OTP.
  ///
  /// Returns the verified [PatientModel] on success, or `null` on failure.
  ///
  /// Production replacement: call ABDM OTP verify endpoint.
  PatientModel? verifyOtp(String enteredOtp) {
    if (enteredOtp.trim() == fixedDemoOtp && _pendingPatient != null) {
      final verified = _pendingPatient!;
      // Clear session after successful verification
      _pendingPatient = null;
      return verified;
    }
    return null;
  }

  /// Clears the pending OTP session (called on logout or screen dismiss).
  void clearSession() {
    _pendingPatient = null;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Strips dashes and whitespace for normalized comparison.
  String _normalize(String abhaId) =>
      abhaId.replaceAll('-', '').replaceAll(' ', '').trim();
}
