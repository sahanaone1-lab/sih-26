import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/main.dart';

void main() {
  testWidgets('App renders SplashScreen and navigates automatically to HospitalRegistrationScreen',
      (WidgetTester tester) async {
    // Build app and trigger initial frame
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 600));

    // Verify SplashScreen is displayed with MediKiosk branding
    expect(find.text('MediKiosk'), findsOneWidget);
    expect(find.text('Hospital Management & Public Health Kiosk'), findsOneWidget);

    // Fast-forward past 2.5 second delay and page transition animation
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify HospitalRegistrationScreen is now displayed
    expect(find.text('AYUSH Hospital Portal Registration'), findsOneWidget);
    expect(find.text('Register Hospital'), findsOneWidget);
  });
}
