import 'package:flutter/foundation.dart';

/// Central API Configuration for MediKiosk Flutter Frontend.
/// Automatically resolves base URL depending on target platform (Web, Desktop, Android Emulator, iOS Simulator, or Custom LAN IP).
class ApiConfig {
  /// Allows override via: flutter run --dart-define=API_BASE_URL=http://192.168.1.X:5000
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Default Express Server Port
  static const int defaultPort = 5000;

  /// Returns the appropriate base URL for the active platform.
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:$defaultPort';
    }

    // Mobile platforms
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android Emulator uses 10.0.2.2 to reach host machine's localhost
        return 'http://10.0.2.2:$defaultPort';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:$defaultPort';
    }
  }

  // Admin Verification Endpoints
  static String get adminDashboard => '$baseUrl/api/admin/dashboard';
  static String get adminHospitals => '$baseUrl/api/admin/hospitals';
  static String get adminPendingHospitals => '$baseUrl/api/admin/hospitals/pending';

  static String adminHospitalDetail(String hospitalId) => '$baseUrl/api/admin/hospitals/$hospitalId';
  static String adminMarkUnderReview(String hospitalId) => '$baseUrl/api/admin/hospitals/$hospitalId/under-review';
  static String adminApproveHospital(String hospitalId) => '$baseUrl/api/admin/hospitals/$hospitalId/approve';
  static String adminRejectHospital(String hospitalId) => '$baseUrl/api/admin/hospitals/$hospitalId/reject';

  // Hospital Endpoints
  static String get hospitalRegister => '$baseUrl/api/hospitals/register';
  static String get hospitalLogin => '$baseUrl/api/hospitals/login';
  static String hospitalStatus(String appId) => '$baseUrl/api/hospitals/status/$appId';

  // Request Headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // In development mode, admin context can be specified via x-admin-id
        'x-admin-id': 'dev-admin-officer-01',
      };

  // Timeout Config
  static const Duration requestTimeout = Duration(seconds: 15);
}
