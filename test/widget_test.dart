import 'package:flutter_test/flutter_test.dart';
import 'package:medical_app/main.dart';

void main() {
  testWidgets('App renders HomeScreen with Role Selection and Portals',
      (WidgetTester tester) async {
    // Build app and trigger initial frame
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify HomeScreen is displayed with MediKiosk branding and Role Selection
    expect(find.text('Smart Public Health & AYUSH Hospital Ecosystem'), findsOneWidget);
    expect(find.text('Choose Your Portal'), findsOneWidget);
    expect(find.text('Patient Portal'), findsOneWidget);
    expect(find.text('Doctor & Hospital Portal'), findsOneWidget);
    expect(find.text('Admin Verification Portal'), findsOneWidget);
  });
}
