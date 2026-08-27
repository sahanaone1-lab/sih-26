const { getSupabase } = require('../config/supabase');
const bcrypt = require('bcrypt');

const registerPatient = async (patientData) => {
  const supabase = getSupabase();
  const { first_name, last_name, email, password, phone, date_of_birth, gender, abha_id, blood_group } = patientData;

  if (!email || !password || !first_name || !last_name) {
    const error = new Error('First name, last name, email, and password are required');
    error.statusCode = 400;
    throw error;
  }

  // Check if patient already exists
  const { data: existingPatient } = await supabase
    .from('patients')
    .select('id')
    .eq('email', email.trim().toLowerCase())
    .maybeSingle();

  if (existingPatient) {
    const error = new Error('A patient with this email already exists');
    error.statusCode = 409;
    throw error;
  }

  // Hash password
  const saltRounds = 10;
  const passwordHash = await bcrypt.hash(password, saltRounds);

  // Insert patient
  const { data: newPatient, error: insertError } = await supabase
    .from('patients')
    .insert({
      first_name: first_name.trim(),
      last_name: last_name.trim(),
      email: email.trim().toLowerCase(),
      password_hash: passwordHash,
      phone: phone ? phone.trim() : null,
      date_of_birth: date_of_birth || null,
      gender: gender ? gender.trim() : null,
      abha_id: abha_id ? abha_id.trim() : null,
      blood_group: blood_group ? blood_group.trim() : null,
    })
    .select('id, first_name, last_name, email')
    .single();

  if (insertError) throw insertError;
  return newPatient;
};

const loginPatient = async (email, password) => {
  const supabase = getSupabase();

  if (!email || !password) {
    const error = new Error('Email and password are required');
    error.statusCode = 400;
    throw error;
  }

  // Find patient
  const { data: patient, error: searchError } = await supabase
    .from('patients')
    .select('*')
    .eq('email', email.trim().toLowerCase())
    .maybeSingle();

  if (searchError) throw searchError;
  if (!patient) {
    const error = new Error('Invalid credentials');
    error.statusCode = 401;
    throw error;
  }

  // Compare password
  const isMatch = await bcrypt.compare(password, patient.password_hash);
  if (!isMatch) {
    const error = new Error('Invalid credentials');
    error.statusCode = 401;
    throw error;
  }

  delete patient.password_hash;
  return patient;
};

const uploadMedicalDocument = async (patientId, file, documentType, title, medicalDate) => {
  const supabase = getSupabase();
  
  if (!patientId || !file || !documentType || !title) {
    const error = new Error('Missing required fields for document upload');
    error.statusCode = 400;
    throw error;
  }

  // Assuming file is saved locally in uploads folder
  const fileUrl = `/uploads/\${file.filename}`;
  
  const { data: newDoc, error } = await supabase
    .from('medical_documents')
    .insert({
      patient_id: patientId,
      uploaded_by_type: 'PATIENT',
      uploaded_by_id: patientId,
      document_type: documentType,
      title: title,
      file_url: fileUrl,
      medical_date: medicalDate || null,
    })
    .select('*')
    .single();

  if (error) throw error;
  return newDoc;
};

module.exports = {
  registerPatient,
  loginPatient,
  uploadMedicalDocument,
};
