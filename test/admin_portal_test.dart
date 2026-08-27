import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/models/hospital_model.dart';
import 'package:medical_app/screens/admin/admin_dashboard_screen.dart';
import 'package:medical_app/screens/admin/admin_hospital_details_screen.dart';
import 'package:medical_app/screens/admin/admin_hospital_list_screen.dart';
import 'package:medical_app/services/admin_hospital_service.dart';

void main() {
  setUp(() {
    AdminHospitalService().useMockData = true;
  });

  group('Flutter Admin Portal Widget Tests', () {
    testWidgets('1. AdminDashboardScreen renders statistics cards and recent registrations',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: AdminDashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Verification Management Dashboard'), findsOneWidget);
      expect(find.text('Total Hospitals'), findsOneWidget);
      expect(find.text('Pending Review'), findsWidgets);
      expect(find.text('Under Review'), findsWidgets);
      expect(find.text('Verified Active'), findsOneWidget);
      expect(find.text('Recent Hospital Registrations'), findsOneWidget);
    });

    testWidgets('2. AdminHospitalListScreen renders search field and filter bar',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const MaterialApp(home: AdminHospitalListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Hospital Directory & Reviews'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Hospitals'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Under Review'), findsWidgets);
    });

    testWidgets('3. AdminHospitalDetailsScreen renders all 5 structured sections',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final service = AdminHospitalService();
      final hospitals = await service.getHospitals();
      final pendingHospital = hospitals.firstWhere((h) => h.verificationStatus == VerificationStatus.pending);

      await tester.pumpWidget(MaterialApp(
        home: AdminHospitalDetailsScreen(hospitalId: pendingHospital.id),
      ));
      await tester.pumpAndSettle();

      expect(find.text('1. Facility Details'), findsOneWidget);
      expect(find.text('2. Regulatory & Accreditation IDs'), findsOneWidget);
      expect(find.text('3. Authorized Representative(s)'), findsOneWidget);
      expect(find.text('4. Uploaded Verification Documents'), findsOneWidget);
      expect(find.text('5. Verification Audit Trail'), findsOneWidget);
    });

    testWidgets('4. Pending hospital shows Start Verification Review action',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final service = AdminHospitalService();
      final hospitals = await service.getHospitals();
      final pendingHospital = hospitals.firstWhere((h) => h.verificationStatus == VerificationStatus.pending);

      await tester.pumpWidget(MaterialApp(
        home: AdminHospitalDetailsScreen(hospitalId: pendingHospital.id),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Start Verification Review'), findsOneWidget);
    });

    testWidgets('5. Under Review hospital shows Approve and Reject buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final service = AdminHospitalService();
      final hospitals = await service.getHospitals();
      final underReviewHospital = hospitals.firstWhere((h) => h.verificationStatus == VerificationStatus.under_review);

      await tester.pumpWidget(MaterialApp(
        home: AdminHospitalDetailsScreen(hospitalId: underReviewHospital.id),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Reject Application'), findsOneWidget);
      expect(find.text('Approve Hospital'), findsOneWidget);
    });

    testWidgets('6. Verified hospital shows verified status banner and no approval buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final service = AdminHospitalService();
      final hospitals = await service.getHospitals();
      final verifiedHospital = hospitals.firstWhere((h) => h.verificationStatus == VerificationStatus.verified);

      await tester.pumpWidget(MaterialApp(
        home: AdminHospitalDetailsScreen(hospitalId: verifiedHospital.id),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Hospital Registration Verified & Active'), findsOneWidget);
      expect(find.text('Start Verification Review'), findsNothing);
      expect(find.text('Approve Hospital'), findsNothing);
    });
  });
}
