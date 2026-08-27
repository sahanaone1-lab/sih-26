import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/models/patient_model.dart';
import 'package:medical_app/screens/patient/clinical_history_summary_screen.dart';
import 'package:medical_app/screens/patient/medical_history_timeline_screen.dart';
import 'package:medical_app/screens/patient/patient_dashboard_screen.dart';
import 'package:medical_app/screens/patient/scan_medical_documents_screen.dart';
import 'package:medical_app/screens/patient/voice_to_text_history_screen.dart';

void main() {
  const testPatient = PatientModel(
    abhaId: '14-8912-3401-7752',
    name: 'Aarav Patel',
    dateOfBirth: '12 Mar 1986',
    age: 38,
    gender: 'Male',
    mobileNumber: '9876543210',
    bloodGroup: 'O+',
    state: 'Gujarat',
    district: 'Ahmedabad',
  );

  group('Patient AI Clinical Intake Tests', () {
    testWidgets('1. PatientDashboardScreen displays progress bar and 5 feature cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientDashboardScreen(patient: testPatient),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Patient identity
      expect(find.text('Aarav Patel'), findsOneWidget);
      expect(find.text('ABDM Verified'), findsOneWidget);

      // Verify Progress bar
      expect(find.text('Clinical Intake Journey'), findsOneWidget);
      expect(find.text('Talk'), findsOneWidget);
      expect(find.text('Voice/Text'), findsOneWidget);
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);

      // Verify 5 Clinical intake cards
      expect(find.text('1. AI Health Conversation'), findsOneWidget);
      expect(find.text('2. Voice-to-Text Clinical History'), findsOneWidget);
      expect(find.text('3. Scan Medical Documents'), findsOneWidget);
      expect(find.text('4. Medical History Timeline'), findsOneWidget);
      expect(find.text('5. AI Clinical History Summary'), findsOneWidget);
    });

    testWidgets('2. Card 1 and Card 2 navigate to VoiceToTextHistoryScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PatientDashboardScreen(patient: testPatient),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Card 1 (AI Health Conversation)
      await tester.tap(find.text('1. AI Health Conversation'));
      await tester.pumpAndSettle();

      // Verify it opens the Voice-to-Text Clinical History page directly
      expect(find.text('Voice-to-Text Clinical History'), findsOneWidget);
      expect(find.text('Describe Your Health Problem'), findsOneWidget);
      expect(find.text('Select Spoken Language'), findsOneWidget);
    });

    testWidgets('3. VoiceToTextHistoryScreen supports language picker and transcription',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VoiceToTextHistoryScreen(patient: testPatient),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Voice-to-Text Clinical History'), findsOneWidget);
      expect(find.text('Describe Your Health Problem'), findsOneWidget);
      expect(find.text('Select Spoken Language'), findsOneWidget);
      expect(find.text('Converted Clinical Transcript'), findsOneWidget);
      expect(find.text('Save to Intake Profile'), findsOneWidget);

      // Verify microphone button exists
      expect(find.byIcon(Icons.mic_rounded), findsWidgets);
    });

    testWidgets('4. ScanMedicalDocumentsScreen renders digitized records and scan modal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScanMedicalDocumentsScreen(patient: testPatient),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scan Medical Documents'), findsOneWidget);
      expect(find.text('AI OCR Medical Scanner'), findsOneWidget);
      expect(find.text('Scan New Document'), findsOneWidget);
      expect(find.text('Digitized Medical Records'), findsOneWidget);

      // Tap Scan New Document to open bottom sheet
      await tester.tap(find.text('Scan New Document'));
      await tester.pumpAndSettle();

      expect(find.text('Scan or Upload Medical Document'), findsOneWidget);
      expect(find.text('Document Type'), findsOneWidget);
      expect(find.text('Prescription'), findsWidgets);
      expect(find.text('Lab Report'), findsWidgets);
      expect(find.text('Discharge Summary'), findsWidgets);
    });

    testWidgets('5. MedicalHistoryTimelineScreen renders chronological items and filter chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MedicalHistoryTimelineScreen(patient: testPatient),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medical History Timeline'), findsOneWidget);
      expect(find.text('Unified Patient Journey'), findsOneWidget);
      expect(find.text('All Events'), findsOneWidget);
      expect(find.text('Voice History'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);
      expect(find.text('Lab Reports'), findsOneWidget);
    });

    testWidgets('6. ClinicalHistorySummaryScreen renders all 9 clinical sections and submit dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ClinicalHistorySummaryScreen(patient: testPatient),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AI Clinical History Summary'), findsOneWidget);
      expect(find.text('AI PRE-CONSULTATION SUMMARY'), findsOneWidget);
      expect(find.text('AI Clinical Impression'), findsOneWidget);

      // 9 sections
      expect(find.text('Chief Complaint'), findsOneWidget);
      expect(find.text('History of Present Illness (HPI)'), findsOneWidget);
      expect(find.text('Past Medical History'), findsOneWidget);
      expect(find.text('Past Surgical History'), findsOneWidget);
      expect(find.text('Current Medications'), findsOneWidget);
      expect(find.text('Allergies & Adverse Reactions'), findsOneWidget);
      expect(find.text('Family History'), findsOneWidget);
      expect(find.text('Personal History & AYUSH Lifestyle'), findsOneWidget);
      expect(find.text('Previous Investigations & Labs'), findsOneWidget);

      // Submit button
      final submitButton = find.text('Submit Intake for Doctor Consultation');
      expect(submitButton, findsOneWidget);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Submit Clinical Intake?'), findsOneWidget);
      expect(find.text('Confirm & Send'), findsOneWidget);
      await tester.tap(find.text('Confirm & Send'));
      await tester.pumpAndSettle();
    });
  });
}
