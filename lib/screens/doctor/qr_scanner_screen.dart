import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import '../../app/theme.dart';
import '../../models/doctor_model.dart';
import 'patient_profile_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final DoctorModel doctor;

  const QrScannerScreen({super.key, required this.doctor});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String code = barcodes.first.rawValue!;
      
      setState(() {
        _isProcessing = true;
      });
      
      try {
        final Map<String, dynamic> data = jsonDecode(code);
        
        if (data.containsKey('patientId') && data.containsKey('tempToken')) {
          final patientId = data['patientId'];
          
          // Request access from the backend using the generic endpoint
          final response = await http.post(
            Uri.parse('http://localhost:8001/api/sessions/request'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'patientId': patientId,
              'doctorId': widget.doctor.id,
            }),
          );
          
          if (response.statusCode == 201) {
            final resData = jsonDecode(response.body);
            final String rawToken = resData['data']['rawToken'];
            final String sessionId = resData['data']['session']['id'];
            
            // In a real app, the patient would need to approve this via a notification.
            // For prototyping, we will simulate the patient auto-approving this request immediately.
            final approveResponse = await http.post(
              Uri.parse('http://localhost:8001/api/sessions/approve'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'sessionId': sessionId,
                'patientId': patientId,
              }),
            );
            
            if (approveResponse.statusCode == 200) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Access Granted for 90 minutes', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                );
                
                // Navigate to patient profile
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PatientProfileScreen(
                      doctor: widget.doctor,
                      patientId: patientId,
                      rawToken: rawToken,
                      patientName: data['name'] ?? 'Patient',
                      abhaId: data['abhaId'] ?? '',
                    ),
                  ),
                );
                return;
              }
            } else {
              throw Exception('Patient failed to approve access');
            }
          } else {
            throw Exception('Failed to request access: \${response.body}');
          }
        } else {
          throw Exception('Invalid QR Code format');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: \$e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Patient QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Target Box Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.saffronPrimary, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.saffronPrimary),
                    SizedBox(height: 16),
                    Text(
                      'Requesting Secure Access...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Position QR code in the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
