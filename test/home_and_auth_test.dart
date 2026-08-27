import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/app/theme.dart';
import 'package:medical_app/models/hospital_model.dart';
import 'package:medical_app/models/patient_model.dart';
import 'package:medical_app/screens/admin/admin_dashboard_screen.dart';
import 'package:medical_app/screens/admin/admin_login_screen.dart';
import 'package:medical_app/screens/home/home_screen.dart';
import 'package:medical_app/screens/hospital/verification_status_screen.dart';
import 'package:medical_app/screens/patient/patient_dashboard_screen.dart';
import 'package:medical_app/screens/patient/patient_intake_screen.dart';
import 'package:medical_app/screens/patient/patient_otp_screen.dart';
import 'package:medical_app/services/abha_verification_service.dart';
import 'package:medical_app/services/admin_hospital_service.dart';

void main() {
  setUp(() {
    AdminHospitalService().useMockData = true;
  });

  group('HomeScreen, Role Navigation, and Authentication Tests', () {
    testWidgets('1. HomeScreen renders role selection cards without theme toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Smart Public Health & AYUSH Hospital Ecosystem'), findsOneWidget);
      expect(find.text('Patient Portal'), findsOneWidget);
      expect(find.text('Doctor & Hospital Portal'), findsOneWidget);
      expect(find.text('Admin Verification Portal'), findsOneWidget);
      expect(find.text('Sign In / Portals'), findsOneWidget);

      // Theme toggle must be absent
      expect(find.byIcon(Icons.dark_mode_rounded), findsNothing);
      expect(find.byIcon(Icons.light_mode_rounded), findsNothing);
    });

    testWidgets('2. AdminLoginScreen validates credentials and rejects unauthorized input',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AdminLoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('AYUSH Admin Central'), findsOneWidget);
      expect(find.text('Official Admin Email / Employee ID'), findsOneWidget);
      expect(find.text('Security Passkey / Password'), findsOneWidget);

      // Try logging in with wrong password
      await tester.enterText(find.byType(TextFormField).first, 'admin@ayush.gov.in');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
      await tester.tap(find.text('Access Admin Portal'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid admin credentials. Use official Ministry email and security key.'), findsOneWidget);
    });

    testWidgets('3. AdminLoginScreen auto-fill logs into AdminDashboardScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: AdminLoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Auto Fill Admin'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Access Admin Portal'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminDashboardScreen), findsOneWidget);
      expect(find.text('Verification Management Dashboard'), findsOneWidget);
    });

    testWidgets('4. PatientIntakeScreen shows ABHA verification flow (no OPD token)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: PatientIntakeScreen()));
      await tester.pumpAndSettle();

      // New screen has ABHA ID verification flow
      expect(find.text('Patient Portal Login'), findsOneWidget);
      expect(find.text('ABHA Health ID'), findsOneWidget);
      expect(find.text('Verify ABHA ID'), findsOneWidget);
      expect(find.text('Step 1 of 2 — Enter your ABHA Health ID'), findsOneWidget);

      // OPD token elements must not exist
      expect(find.text('Generate OPD Queue Token'), findsNothing);
      expect(find.text('Patient Kiosk Intake'), findsNothing);
      expect(find.text('OPD Check-in Successful!'), findsNothing);
    });

    testWidgets('5. PatientIntakeScreen rejects invalid ABHA ID',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: PatientIntakeScreen()));
      await tester.pumpAndSettle();

      // Enter an invalid ABHA ID (not in demo DB)
      await tester.enterText(find.byType(TextFormField).first, '99-0000-0000-0000');
      await tester.tap(find.text('Verify ABHA ID'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('ABHA ID not found or invalid. Try one of the demo IDs.'), findsOneWidget);
    });

    testWidgets('6. PatientIntakeScreen valid ABHA navigates to PatientOtpScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: PatientIntakeScreen()));
      await tester.pumpAndSettle();

      // Auto Fill first demo patient
      await tester.tap(find.text('Auto Fill'));
      await tester.pumpAndSettle();

      // Verify ABHA ID
      await tester.tap(find.text('Verify ABHA ID'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should navigate to OTP screen
      expect(find.byType(PatientOtpScreen), findsOneWidget);
      expect(find.text('OTP Verification'), findsOneWidget);
      expect(find.text('Step 2 of 2 — Identity Verification'), findsOneWidget);
    });

    testWidgets('7. PatientOtpScreen correct fixed OTP 123456 navigates to PatientDashboardScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final service = AbhaVerificationService.instance;
      final patient = AbhaVerificationService.demoPatients.first;
      service.generateOtp(patient);

      await tester.pumpWidget(MaterialApp(
        home: PatientOtpScreen(patient: patient),
      ));
      await tester.pumpAndSettle();

      // Enter correct fixed demo OTP: 123456
      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.tap(find.text('Verify OTP'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(PatientDashboardScreen), findsOneWidget);
    });

    testWidgets('8. PatientDashboardScreen shows patient details from PatientModel',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const patient = PatientModel(
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

      await tester.pumpWidget(
          MaterialApp(home: PatientDashboardScreen(patient: patient)));
      await tester.pumpAndSettle();

      expect(find.text('Aarav Patel'), findsOneWidget);
      expect(find.text('ABHA ID'), findsOneWidget);
      expect(find.text('14-8912-3401-7752'), findsOneWidget);
      expect(find.text('AI Clinical Intake'), findsOneWidget);
      expect(find.text('Clinical Intake Journey'), findsOneWidget);
      expect(find.text('1. AI Health Conversation'), findsOneWidget);
      expect(find.text('2. Voice-to-Text Clinical History'), findsOneWidget);
      expect(find.text('3. Scan Medical Documents'), findsOneWidget);
      expect(find.text('4. Medical History Timeline'), findsOneWidget);
      expect(find.text('5. AI Clinical History Summary'), findsOneWidget);

      // Verify old cards are completely removed
      expect(find.text('Book Appointment'), findsNothing);
      expect(find.text('Health Records'), findsNothing);
      expect(find.text('Health Profile'), findsNothing);
      expect(find.text('Prescriptions'), findsNothing);
      expect(find.text('Find AYUSH Hospitals'), findsNothing);
    });

    testWidgets('9. VerificationStatusScreen no longer displays the Demo Status Switcher',
        (WidgetTester tester) async {
      final pendingHospital = AyushHospital.mock(status: VerificationStatus.pending);
      await tester.pumpWidget(MaterialApp(home: VerificationStatusScreen(hospital: pendingHospital)));
      await tester.pumpAndSettle();

      expect(find.text('DEMO STATUS SWITCHER (Simulate Verification Stage)'), findsNothing);
      expect(find.text('Verification Application Details'), findsOneWidget);
      expect(find.text('National Institute of Ayurveda Hospital'), findsOneWidget);
    });
  });
}
