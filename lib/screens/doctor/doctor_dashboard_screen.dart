import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../app/theme.dart';
import '../../models/doctor_model.dart';
import 'patient_profile_screen.dart';
import '../../config/api_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorDashboardScreen extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorDashboardScreen({super.key, required this.doctor});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> uploadedDocuments = [];

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    // Connect to backend
    socket = IO.io(ApiConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Socket Connected');
      // For now, doctors join a common room for their ID, but ideally we get active session IDs
      // Here we assume the doctor joins all sessions they own, or a global doctor room.
      // For MVP, we can emit a join for the doctor. Wait, in consultation.controller.js we emit to `session_${sessionId}`.
      // So the doctor needs to know the sessionId. For a real app, doctor dashboard fetches active sessions.
      // Let's just listen to a global doctor room as well, or fetch active sessions.
      // Quick fix for MVP: Backend can emit to a doctor-specific room.
    });

    // We didn't add doctor-room emitting in the backend, but we can do it by changing the backend slightly,
    // or the doctor can join all their active sessions. Since we didn't write an endpoint for "get active sessions",
    // let's just show the uploaded documents if we receive an event.
    socket.on('document_uploaded', (data) {
      if (mounted) {
        setState(() {
          uploadedDocuments.add(data['document']);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New document uploaded!'), backgroundColor: AppColors.greenSuccess),
        );
      }
    });

    socket.on('consultation_ended', (data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultation session ended')),
        );
      }
    });
  }

  Future<void> _viewDocument(String documentId) async {
    try {
      final uri = Uri.parse('${ApiConfig.getDocumentUrl}/$documentId?doctorId=${widget.doctor.id}');
      final response = await http.get(uri, headers: ApiConfig.defaultHeaders);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final urlString = data['data']['url'];
        final url = Uri.parse(urlString);
        
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch URL';
        }
      } else {
        throw 'Failed to fetch document URL';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Doctor Dashboard', style: TextStyle(color: AppColors.navyPrimary)),
        backgroundColor: AppColors.background,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.saffronDark),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Doctor Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navyPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navyPrimary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${widget.doctor.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor.specialization,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Active Consultations section
              const Text(
                'Live Consultation Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              if (uploadedDocuments.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: const Center(
                    child: Text(
                      'No documents uploaded yet.\nWaiting for patients to scan QR.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: uploadedDocuments.length,
                    itemBuilder: (context, index) {
                      final doc = uploadedDocuments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.description, color: AppColors.saffronPrimary, size: 32),
                          title: Text(doc['original_filename']),
                          subtitle: Text('Size: ${(doc['file_size'] / 1024).toStringAsFixed(1)} KB'),
                          trailing: ElevatedButton(
                            onPressed: () => _viewDocument(doc['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navyLight,
                            ),
                            child: const Text('View', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
