const { getSupabase } = require('../config/supabase');
const bcrypt = require('bcrypt');

const registerDoctor = async (doctorData) => {
  const supabase = getSupabase();
  const { first_name, last_name, email, password, phone, specialization, registration_number, hospital_id } = doctorData;

  if (!email || !password || !first_name || !last_name || !specialization || !registration_number) {
    const error = new Error('First name, last name, email, password, specialization, and registration_number are required');
    error.statusCode = 400;
    throw error;
  }

  // Check if doctor already exists
  const { data: existingDoctor } = await supabase
    .from('doctors')
    .select('id')
    .or(`email.eq.${email.trim().toLowerCase()},registration_number.eq.${registration_number.trim()}`)
    .maybeSingle();

  if (existingDoctor) {
    const error = new Error('A doctor with this email or registration number already exists');
    error.statusCode = 409;
    throw error;
  }

  // Hash password
  const saltRounds = 10;
  const passwordHash = await bcrypt.hash(password, saltRounds);

  // Insert doctor
  const { data: newDoctor, error: insertError } = await supabase
    .from('doctors')
    .insert({
      first_name: first_name.trim(),
      last_name: last_name.trim(),
      email: email.trim().toLowerCase(),
      password_hash: passwordHash,
      phone: phone ? phone.trim() : null,
      specialization: specialization.trim(),
      registration_number: registration_number.trim(),
      hospital_id: hospital_id || null,
    })
    .select('id, first_name, last_name, email, specialization, registration_number')
    .single();

  if (insertError) throw insertError;
  return newDoctor;
};

const loginDoctor = async (identifier, password) => {
  const supabase = getSupabase();

  if (!identifier || !password) {
    const error = new Error('Identifier (email or registration number) and password are required');
    error.statusCode = 400;
    throw error;
  }

  const queryIdentifier = identifier.trim();

  // Find doctor
  const { data: doctor, error: searchError } = await supabase
    .from('doctors')
    .select('*')
    .or(`email.eq.${queryIdentifier.toLowerCase()},registration_number.eq.${queryIdentifier}`)
    .maybeSingle();

  if (searchError) throw searchError;
  if (!doctor) {
    const error = new Error('Invalid credentials');
    error.statusCode = 401;
    throw error;
  }

  // Compare password
  const isMatch = await bcrypt.compare(password, doctor.password_hash);
  if (!isMatch) {
    const error = new Error('Invalid credentials');
    error.statusCode = 401;
    throw error;
  }

  delete doctor.password_hash;
  return doctor;
};

const uploadConsultation = async (doctorId, rawToken, patientId, file, title, notes) => {
  const supabase = getSupabase();
  const sessionService = require('./session.service');

  // 1. Verify access token
  const session = await sessionService.verifyDoctorAccess(doctorId, rawToken);

  if (session.patient_id !== patientId) {
    const error = new Error('Access token does not match the patient ID');
    error.statusCode = 403;
    throw error;
  }

  // 2. Upload file reference to medical_documents
  const fileUrl = `/uploads/\${file.filename}`;
  
  const { data: newDoc, error } = await supabase
    .from('medical_documents')
    .insert({
      patient_id: patientId,
      uploaded_by_type: 'DOCTOR',
      uploaded_by_id: doctorId,
      document_type: 'Prescription/Consultation Note',
      title: title,
      file_url: fileUrl,
      medical_date: new Date().toISOString(),
    })
    .select('*')
    .single();

  if (error) throw error;
  
  return newDoc;
};

module.exports = {
  registerDoctor,
  loginDoctor,
  uploadConsultation,
};
