import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'admin_hospital_service.dart'; // for ApiException

class ConsultationService {
  Future<Map<String, dynamic>> startSession(String hospitalId, String doctorId) async {
    final uri = Uri.parse(ApiConfig.startConsultation);
    
    try {
      final response = await http
          .post(
            uri, 
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({'hospitalId': hospitalId, 'doctorId': doctorId}),
          )
          .timeout(ApiConfig.requestTimeout);

      final statusCode = response.statusCode;
      dynamic responseJson;
      try {
        responseJson = jsonDecode(response.body);
      } catch (_) {
        responseJson = null;
      }

      if (statusCode >= 200 && statusCode < 300 && responseJson != null) {
        return responseJson['data'] as Map<String, dynamic>;
      }

      throw ApiException('Failed to start consultation session', statusCode: statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }
}
