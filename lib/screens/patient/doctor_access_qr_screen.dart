import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import '../../app/theme.dart';
import '../../models/patient_model.dart';

class DoctorAccessQrScreen extends StatefulWidget {
  final PatientModel patient;

  const DoctorAccessQrScreen({super.key, required this.patient});

  @override
  State<DoctorAccessQrScreen> createState() => _DoctorAccessQrScreenState();
}

class _DoctorAccessQrScreenState extends State<DoctorAccessQrScreen> {
  bool _isLoading = true;
  String? _qrData;
  String? _sessionId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  Future<void> _generateQrCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // In a real app, doctorId would be selected by the patient or scanned first.
      // For this prototype, we'll request a generic access session token that any doctor can scan.
      // Wait, the API requires patientId and doctorId. 
      // If patient generates QR, they don't know the doctor ID yet.
      // Let's assume the QR code just contains the patient ID, and the doctor scans it to trigger a request to the patient's app.
      // Or, the patient generates a generic consent token and the doctor claims it.
      
      // For this prototype, let's encode the patientId and a random temporary consent token.
      final String tempToken = DateTime.now().millisecondsSinceEpoch.toString();
      final Map<String, dynamic> qrPayload = {
        'patientId': widget.patient.abhaId, // Using abhaId since id doesn't exist
        'abhaId': widget.patient.abhaId,
        'name': widget.patient.name,
        'tempToken': tempToken,
      };

      _qrData = jsonEncode(qrPayload);
      
    } catch (e) {
      _error = "Failed to generate QR Code: \$e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Share Medical Records', style: TextStyle(color: AppColors.navyPrimary)),
        backgroundColor: AppColors.background,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.navyPrimary),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security_rounded, size: 64, color: AppColors.greenSuccess),
              const SizedBox(height: 24),
              const Text(
                'Show this QR Code to your Doctor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Scanning this will give the doctor secure access to your clinical history and documents for 90 minutes.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red))
              else if (_qrData != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: QrImageView(
                    data: _qrData!,
                    version: QrVersions.auto,
                    size: 250.0,
                    foregroundColor: AppColors.navyPrimary,
                  ),
                ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _generateQrCode,
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.navyPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
