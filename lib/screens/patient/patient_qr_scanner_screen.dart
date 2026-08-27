import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../models/patient_model.dart';
import '../../config/api_config.dart';

/// Patient QR Scanner Screen.
///
/// The patient uses this screen to scan the QR code that the DOCTOR/HOSPITAL
/// generated on the Hospital Kiosk. After scanning, the patient sees an
/// explicit data-sharing approval dialog before anything is shared.
///
/// KEY RULE: This screen does NOT generate QR codes. It only SCANS them.
class PatientQrScannerScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientQrScannerScreen({super.key, required this.patient});

  @override
  State<PatientQrScannerScreen> createState() => _PatientQrScannerScreenState();
}

class _PatientQrScannerScreenState extends State<PatientQrScannerScreen> {
  final _manualCodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _manualCodeController.dispose();
    super.dispose();
  }

  /// Shows an explicit approval dialog before sharing any data.
  void _showApprovalDialog({
    required String doctorId,
    required String hospitalName,
    required String doctorName,
    required String specialization,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.shield, color: AppColors.greenSuccess, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Share your medical information?',
                  style: TextStyle(
                    color: AppColors.navyPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You are about to share your data with:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. $doctorName',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.navyPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialization,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hospitalName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.saffronDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'The following will be shared for 90 minutes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.navyPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildApprovalItem(Icons.auto_awesome, 'AI-generated medical summary'),
                _buildApprovalItem(Icons.history, 'Relevant past medical history'),
                _buildApprovalItem(Icons.folder_shared, 'Selected medical records'),
                _buildApprovalItem(Icons.document_scanner, 'Scanned documents & reports'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.saffronLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.timer, color: AppColors.saffronDark, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Access will automatically expire after 90 minutes.',
                          style: TextStyle(
                            color: AppColors.saffronDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => _isProcessing = false);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                _processGrantAccess(doctorId, doctorName);
              },
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Approve & Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenSuccess,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildApprovalItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.greenSuccess),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Sends session request + auto-approve to backend.
  void _processGrantAccess(String doctorId, String doctorName) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8001/api/sessions/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patientId': widget.patient.abhaId,
          'doctorId': doctorId,
        }),
      );

      if (response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        final String sessionId = resData['data']['session']['id'];

        // Patient has already approved on screen — auto-approve on backend
        final approveResponse = await http.post(
          Uri.parse('http://localhost:8001/api/sessions/approve'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sessionId': sessionId,
            'patientId': widget.patient.abhaId,
          }),
        );

        if (approveResponse.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Access granted to Dr. $doctorName for 90 minutes',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.greenSuccess,
              ),
            );
            Navigator.of(context).pop();
            return;
          }
        } else {
          throw Exception('Failed to approve access');
        }
      } else {
        throw Exception('Failed to request access: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Handles manual fallback code entry.
  void _handleManualCode() async {
    final code = _manualCodeController.text.trim().toUpperCase();
    if (code.isEmpty || code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid fallback code')),
      );
      return;
    }

    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/upload.html?code=$code');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch browser';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Doctor QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Camera placeholder (real camera would use mobile_scanner)
          Container(
            color: Colors.grey.shade900,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.camera_alt, color: Colors.white24, size: 80),
                SizedBox(height: 16),
                Text(
                  'Point camera at the QR code\non the hospital screen',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),

          // Target box overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.saffronPrimary, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Processing overlay
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
                      'Granting Secure Access...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom fallback code panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Camera unavailable?',
                    style: TextStyle(
                      color: AppColors.navyPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter the fallback code displayed below the QR on the hospital screen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'e.g. AYPR327',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: const TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _handleManualCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.saffronPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
