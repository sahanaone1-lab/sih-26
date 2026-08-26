import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/app/theme.dart';
import 'package:medical_app/models/hospital_model.dart';
import 'package:medical_app/screens/admin/admin_dashboard_screen.dart';
import 'package:medical_app/screens/admin/admin_login_screen.dart';
import 'package:medical_app/screens/home/home_screen.dart';
import 'package:medical_app/screens/hospital/verification_status_screen.dart';
import 'package:medical_app/screens/patient/patient_intake_screen.dart';

void main() {
  group('HomeScreen, Role Navigation, and Authentication Tests', () {
    testWidgets('1. HomeScreen renders role selection cards and theme toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Smart Public Health & AYUSH Hospital Ecosystem'), findsOneWidget);
      expect(find.text('Patient & Kiosk Intake'), findsOneWidget);
      expect(find.text('Doctor & Hospital Portal'), findsOneWidget);
      expect(find.text('Admin Verification Portal'), findsOneWidget);
      expect(find.text('Sign In / Portals'), findsOneWidget);

      // Verify theme toggle can be tapped
      final themeToggle = find.byIcon(Icons.dark_mode_rounded);
      expect(themeToggle, findsOneWidget);
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();
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

      // Click Auto Fill Admin
      await tester.tap(find.text('Auto Fill Admin'));
      await tester.pumpAndSettle();

      // Click Access Admin Portal
      await tester.tap(find.text('Access Admin Portal'));
      await tester.pumpAndSettle();

      // Verify navigated to AdminDashboardScreen
      expect(find.byType(AdminDashboardScreen), findsOneWidget);
      expect(find.text('Verification Management Dashboard'), findsOneWidget);
    });

    testWidgets('4. PatientIntakeScreen validates and generates OPD Queue Token',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: PatientIntakeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Patient Kiosk Intake'), findsOneWidget);

      // Auto Fill Patient
      await tester.tap(find.text('Auto Fill'));
      await tester.pumpAndSettle();

      // Generate Token
      await tester.tap(find.text('Generate OPD Queue Token'));
      await tester.pumpAndSettle();

      expect(find.text('OPD Check-in Successful!'), findsOneWidget);
      expect(find.text('TOKEN NUMBER'), findsOneWidget);
      expect(find.text('Aarav Patel'), findsOneWidget);
      expect(find.text('Print Slip'), findsOneWidget);
    });

    testWidgets('5. VerificationStatusScreen no longer displays the Demo Status Switcher',
        (WidgetTester tester) async {
      final pendingHospital = AyushHospital.mock(status: VerificationStatus.pending);
      await tester.pumpWidget(MaterialApp(home: VerificationStatusScreen(hospital: pendingHospital)));
      await tester.pumpAndSettle();

      // Demo Switcher must be absent
      expect(find.text('DEMO STATUS SWITCHER (Simulate Verification Stage)'), findsNothing);
      expect(find.text('Verification Application Details'), findsOneWidget);
      expect(find.text('National Institute of Ayurveda Hospital'), findsOneWidget);
    });
  });
}
