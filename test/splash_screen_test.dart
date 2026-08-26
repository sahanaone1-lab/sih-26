import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/screens/splash/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders MediKiosk branding, tagline, and medical elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Advance initial entrance animation frame
    await tester.pump(const Duration(milliseconds: 600));

    // Verify presence of application name and tagline
    expect(find.text('MediKiosk'), findsOneWidget);
    expect(find.text('Hospital Management & Public Health Kiosk'), findsOneWidget);

    // Verify presence of public health header badge and security footer text
    expect(find.textContaining('PUBLIC HEALTH INITIATIVE'), findsOneWidget);
    expect(find.textContaining('Encrypted & Secure'), findsOneWidget);

    // Verify medical icon presence
    expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);

    // Advance past navigation delay to clean up timer
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
