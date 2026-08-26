import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/models/hospital_model.dart';
import 'package:medical_app/screens/auth/login_screen.dart';
import 'package:medical_app/screens/hospital/ayush_dashboard_screen.dart';
import 'package:medical_app/screens/hospital/hospital_profile_screen.dart';
import 'package:medical_app/screens/hospital/hospital_registration_screen.dart';
import 'package:medical_app/screens/hospital/registration_submitted_screen.dart';
import 'package:medical_app/screens/hospital/verification_status_screen.dart';

void main() {
  group('AYUSH Hospital Portal Tests', () {
    testWidgets('1. HospitalRegistrationScreen renders all required fields and register button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HospitalRegistrationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('1. AYUSH Facility Details'), findsOneWidget);
      expect(find.text('Register Hospital'), findsOneWidget);
      expect(find.text('Hospital Registration Certificate *'), findsOneWidget);
      expect(find.text('Authorized Person ID *'), findsOneWidget);
    });

    testWidgets('2. RegistrationSubmittedScreen renders success headline, status, and Go to Login button',
        (WidgetTester tester) async {
      final mockHospital = AyushHospital.mock(status: VerificationStatus.pending);
      await tester.pumpWidget(MaterialApp(home: RegistrationSubmittedScreen(hospital: mockHospital)));
      await tester.pumpAndSettle();

      expect(find.text('Hospital Registration Submitted Successfully'), findsOneWidget);
      expect(find.text('National Institute of Ayurveda Hospital'), findsOneWidget);
      expect(find.text('Pending Verification'), findsOneWidget);
      expect(find.text('Your hospital details will be verified before account activation.'), findsOneWidget);
      expect(find.text('Go to Login'), findsOneWidget);
    });

    testWidgets('3. LoginScreen renders dedicated hospital login inputs and buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('AYUSH Hospital Login'), findsOneWidget);
      expect(find.text('Hospital Registration ID / Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Register Hospital'), findsOneWidget);
    });

    testWidgets('4. VerificationStatusScreen displays application details and status restrictions',
        (WidgetTester tester) async {
      final pendingHospital = AyushHospital.mock(status: VerificationStatus.pending);
      await tester.pumpWidget(MaterialApp(home: VerificationStatusScreen(hospital: pendingHospital)));
      await tester.pumpAndSettle();

      expect(find.text('National Institute of Ayurveda Hospital'), findsOneWidget);
      expect(find.text('Pending Verification'), findsWidgets);
      expect(find.text('Hospital Dashboard access is locked while verification is pending.'), findsOneWidget);
    });

    testWidgets('5. AyushDashboardScreen displays welcome header, verified badge, and stat cards',
        (WidgetTester tester) async {
      final verifiedHospital = AyushHospital.mock(status: VerificationStatus.verified);
      await tester.pumpWidget(MaterialApp(home: AyushDashboardScreen(hospital: verifiedHospital)));
      await tester.pumpAndSettle();

      expect(find.text('WELCOME BACK'), findsOneWidget);
      expect(find.text('National Institute of Ayurveda Hospital'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Total Patients'), findsOneWidget);
      expect(find.text("Today's Appointments"), findsOneWidget);
      expect(find.text('MediKiosk AI Clinical Intake'), findsOneWidget);
    });

    testWidgets('6. HospitalProfileScreen renders locked regulatory fields and editable permitted fields',
        (WidgetTester tester) async {
      final verifiedHospital = AyushHospital.mock(status: VerificationStatus.verified);
      await tester.pumpWidget(MaterialApp(home: HospitalProfileScreen(hospital: verifiedHospital)));
      await tester.pumpAndSettle();

      expect(find.text('Hospital Profile'), findsOneWidget);
      expect(find.text('Locked Regulatory Details'), findsOneWidget);
      expect(find.text('Contact & Address Information'), findsOneWidget);
      expect(find.text('Edit Allowed Fields'), findsOneWidget);
    });
  });
}
