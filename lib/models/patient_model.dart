/// PatientModel represents a verified ABHA patient's core health identity.
///
/// In production this data would come from the ABDM FHIR API.
/// In demo mode, it is sourced from [AbhaVerificationService.demoPatients].
class PatientModel {
  final String abhaId;
  final String name;
  final String dateOfBirth; // DD MMM YYYY
  final int age;
  final String gender; // 'Male' | 'Female' | 'Other'
  final String mobileNumber; // Full 10-digit, stored internally
  final String bloodGroup;
  final String state;
  final String district;

  const PatientModel({
    required this.abhaId,
    required this.name,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.mobileNumber,
    required this.bloodGroup,
    required this.state,
    required this.district,
  });

  /// Returns the mobile number with middle digits masked.
  /// e.g. 9876543210 → +91 ••••••3210
  String get maskedMobile {
    if (mobileNumber.length >= 4) {
      return '+91 ••••••${mobileNumber.substring(mobileNumber.length - 4)}';
    }
    return '+91 ••••••••••';
  }

  /// Returns first name only for greeting.
  String get firstName => name.split(' ').first;
}
