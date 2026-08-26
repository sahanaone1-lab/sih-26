import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/screens/hospital/registration_submitted_screen.dart';

void main() {
  testWidgets('RegistrationSubmittedScreen displays success status and application ID',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationSubmittedScreen(
          hospitalName: 'Apollo City Hospital',
          hospitalType: 'Private',
          state: 'Maharashtra',
          district: 'Mumbai',
          adminEmail: 'admin@apollo.org',
          applicationId: 'MK-HOSP-2026-001',
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify main title and hospital name
    expect(find.text('Hospital Registration Submitted Successfully'), findsOneWidget);
    expect(find.text('Apollo City Hospital'), findsOneWidget);

    // Verify Application ID and Status Pill
    expect(find.text('MK-HOSP-2026-001'), findsOneWidget);
    expect(find.text('Pending Verification'), findsOneWidget);

    // Verify review note text
    expect(
      find.text('Your hospital details will be verified before account activation.'),
      findsOneWidget,
    );

    // Verify action button: Go to Login
    expect(find.text('Go to Login'), findsOneWidget);
  });
}
