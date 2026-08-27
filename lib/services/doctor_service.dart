import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/doctor_model.dart';
import 'admin_hospital_service.dart'; // for ApiException

class DoctorService {
  Future<DoctorModel> registerDoctor(Map<String, dynamic> doctorData) async {
    final uri = Uri.parse(ApiConfig.doctorRegister);
    final headers = ApiConfig.defaultHeaders;

    try {
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(doctorData))
          .timeout(ApiConfig.requestTimeout);

      final statusCode = response.statusCode;
      dynamic responseJson;
      try {
        responseJson = jsonDecode(response.body);
      } catch (_) {
        responseJson = null;
      }

      if (statusCode >= 200 && statusCode < 300) {
        return DoctorModel.fromJson(responseJson['data'] as Map<String, dynamic>);
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
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<List<DoctorModel>> getDoctorsByHospital(String hospitalId) async {
    final uri = Uri.parse(ApiConfig.getHospitalDoctors(hospitalId));
    
    try {
      final response = await http
          .get(uri, headers: ApiConfig.defaultHeaders)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        
        return data.map((json) => DoctorModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      throw ApiException('Failed to fetch doctors', statusCode: response.statusCode);
    } catch (e) {
      throw ApiException('Error fetching doctors: $e');
    }
  }
}
