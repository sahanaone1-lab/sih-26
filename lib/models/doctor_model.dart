class DoctorModel {
  final String id;
  final String doctorId;
  final String name;
  final String specialization;
  final String hospitalId;
  final String email;
  final String phone;
  final String status;

  DoctorModel({
    required this.id,
    required this.doctorId,
    required this.name,
    required this.specialization,
    required this.hospitalId,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      hospitalId: json['hospital_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'name': name,
      'specialization': specialization,
      'hospital_id': hospitalId,
      'email': email,
      'phone': phone,
      'status': status,
    };
  }
}
