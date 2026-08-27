import 'package:flutter/material.dart';
import 'app/theme.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_hospital_list_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/hospital/hospital_registration_screen.dart';
import 'screens/patient/patient_intake_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediKiosk - AYUSH Digital Health Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/splash': (context) => const SplashScreen(),
        '/register': (context) => const HospitalRegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/hospitals': (context) => const AdminHospitalListScreen(),
        '/patient': (context) => const PatientIntakeScreen(),
      },
    );
  }
}
