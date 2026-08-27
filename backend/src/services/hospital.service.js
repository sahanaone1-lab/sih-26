const crypto = require('crypto');
const bcrypt = require('bcrypt');
const { getSupabase } = require('../config/supabase');

/**
 * Generates a unique backend application reference ID (e.g., AYUSH-HOSP-2026-89412)
 */
const generateApplicationId = () => {
  const currentYear = new Date().getFullYear();
  const randomSuffix = crypto.randomInt(10000, 99999);
  return `AYUSH-HOSP-${currentYear}-${randomSuffix}`;
};

/**
 * Service to register an AYUSH Hospital, official, and audit history
 */
const registerHospital = async (registrationData) => {
  const supabase = getSupabase();

  const {
    facility_name,
    facility_type,
    ayush_system = 'Ayurveda',
    state,
    district,
    address,
    pin_code,
    official_email,
    official_phone,
    registration_number,
    ayush_id,
    hfr_id,
    password,
  } = registrationData;

  // Extract authorized official details (supports both nested and flat field naming)
  const officialFullName =
    registrationData.authorized_official?.full_name ||
    registrationData.authorized_person_name ||
    registrationData.official_full_name;

  const officialDesignation =
    registrationData.authorized_official?.designation ||
    registrationData.authorized_person_designation ||
    registrationData.official_designation;

  const officialEmail =
    registrationData.authorized_official?.official_email ||
    registrationData.authorized_person_email ||
    registrationData.official_contact_email;

  const officialPhone =
    registrationData.authorized_official?.official_phone ||
    registrationData.authorized_person_phone ||
    registrationData.official_contact_phone;

  // 1. Check for Duplicate Registration Number
  const { data: existingReg, error: regCheckError } = await supabase
    .from('hospitals')
    .select('id, registration_number')
    .eq('registration_number', registration_number.trim())
    .maybeSingle();

  if (regCheckError) {
    throw regCheckError;
  }

  if (existingReg) {
    const error = new Error('A hospital with this registration number already exists');
    error.statusCode = 409;
    throw error;
  }

  // 2. Check for Duplicate Official Email
  const { data: existingEmail, error: emailCheckError } = await supabase
    .from('hospitals')
    .select('id, official_email')
    .eq('official_email', official_email.trim().toLowerCase())
    .maybeSingle();

  if (emailCheckError) {
    throw emailCheckError;
  }

  if (existingEmail) {
    const error = new Error('A hospital with this official email already exists');
    error.statusCode = 409;
    throw error;
  }

  // 3. Check for Duplicate HFR ID (ONLY if provided and non-empty)
  const sanitizedHfrId = hfr_id && typeof hfr_id === 'string' && hfr_id.trim().length > 0 ? hfr_id.trim() : null;

  if (sanitizedHfrId) {
    const { data: existingHfr, error: hfrCheckError } = await supabase
      .from('hospitals')
      .select('id, hfr_id')
      .eq('hfr_id', sanitizedHfrId)
      .maybeSingle();

    if (hfrCheckError) {
      throw hfrCheckError;
    }

    if (existingHfr) {
      const error = new Error('A hospital with this HFR ID already exists');
      error.statusCode = 409;
      throw error;
    }
  }

  // 4. Generate unique application ID
  let applicationId = generateApplicationId();
  let isUnique = false;
  let attempts = 0;

  while (!isUnique && attempts < 5) {
    const { data: existingAppId } = await supabase
      .from('hospitals')
      .select('id')
      .eq('application_id', applicationId)
      .maybeSingle();

    if (!existingAppId) {
      isUnique = true;
    } else {
      applicationId = generateApplicationId();
      attempts++;
    }
  }

  // 4.5. Create Supabase Auth User
  const { data: authData, error: authError } = await supabase.auth.admin.createUser({
    email: official_email.trim().toLowerCase(),
    password: password,
    email_confirm: true,
    user_metadata: { role: 'hospital' }
  });

  if (authError) {
    if (authError.message.includes('already registered')) {
      const error = new Error('An account with this email already exists in Auth');
      error.statusCode = 409;
      throw error;
    }
    throw authError;
  }

  // 5. Insert Hospital Record (Status strictly forced to 'pending')
  const { data: newHospital, error: hospitalInsertError } = await supabase
    .from('hospitals')
    .insert({
      application_id: applicationId,
      facility_name: facility_name.trim(),
      facility_type: facility_type.trim(),
      ayush_system: ayush_system.trim(),
      state: state.trim(),
      district: district.trim(),
      address: address.trim(),
      pin_code: pin_code ? pin_code.toString().trim() : null,
      official_email: official_email.trim().toLowerCase(),
      official_phone: official_phone.trim(),
      registration_number: registration_number.trim(),
      ayush_id: ayush_id && ayush_id.trim().length > 0 ? ayush_id.trim() : null,
      hfr_id: sanitizedHfrId,
      verification_status: 'pending', // Strictly backend controlled
    })
    .select('id, application_id, verification_status')
    .single();

  if (hospitalInsertError) {
    throw hospitalInsertError;
  }

  // 6. Insert Primary Authorized Official
  const { error: officialInsertError } = await supabase
    .from('hospital_officials')
    .insert({
      hospital_id: newHospital.id,
      full_name: officialFullName.trim(),
      designation: officialDesignation.trim(),
      official_email: officialEmail.trim().toLowerCase(),
      official_phone: officialPhone.trim(),
      is_primary: true,
    });

  if (officialInsertError) {
    // Rollback hospital insert if official fails
    await supabase.from('hospitals').delete().eq('id', newHospital.id);
    throw officialInsertError;
  }

  // 7. Insert Initial Verification History Audit Record
  const { error: historyInsertError } = await supabase
    .from('hospital_verification_history')
    .insert({
      hospital_id: newHospital.id,
      previous_status: null,
      new_status: 'pending',
      action: 'registration_submitted',
      notes: 'Initial hospital onboarding registration submitted via MediKiosk Portal',
    });

  if (historyInsertError) {
    console.error('Warning: Failed to create verification history log:', historyInsertError.message);
  }

  return {
    hospital_id: newHospital.id,
    application_id: newHospital.application_id,
    verification_status: newHospital.verification_status,
  };
};

/**
 * Service to login an AYUSH Hospital
 */
const loginHospital = async (identifier, password) => {
  const supabase = getSupabase();

  if (!identifier || !password) {
    const error = new Error('Identifier and password are required');
    error.statusCode = 400;
    throw error;
  }

  // Determine email to use for Supabase Auth
  let loginEmail = identifier.trim().toLowerCase();
  
  // If identifier is not an email, assume it's a Registration ID or Application ID and look up the email
  if (!loginEmail.includes('@')) {
    const { data: lookup, error: lookupError } = await supabase
      .from('hospitals')
      .select('official_email')
      .or(`registration_number.eq.${identifier.trim()},application_id.eq.${identifier.trim()}`)
      .maybeSingle();
      
    if (lookupError) throw lookupError;
    if (!lookup) {
      const error = new Error('Invalid credentials');
      error.statusCode = 401;
      throw error;
    }
    loginEmail = lookup.official_email;
  }

  // Verify password using Supabase Auth
  const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
    email: loginEmail,
    password: password,
  });

  if (authError) {
    const error = new Error('Invalid credentials');
    error.statusCode = 401;
    throw error;
  }

  // Fetch hospital details
  const { data: hospital, error: searchError } = await supabase
    .from('hospitals')
    .select(`
      id, 
      application_id, 
      facility_name, 
      facility_type, 
      state, 
      district, 
      address, 
      official_email, 
      official_phone, 
      registration_number, 
      ayush_id, 
      verification_status,
      created_at
    `)
    .eq('official_email', loginEmail)
    .single();

  if (searchError) throw searchError;

  // Get primary authorized official
  const { data: officials } = await supabase
    .from('hospital_officials')
    .select('*')
    .eq('hospital_id', hospital.id)
    .eq('is_primary', true)
    .limit(1);

  const official = officials && officials.length > 0 ? officials[0] : null;

  return {
    ...hospital,
    primary_official: official,
  };
};

/**
 * Service to check hospital verification status quickly
 */
const checkHospitalStatus = async (applicationId) => {
  const supabase = getSupabase();

  if (!applicationId) {
    const error = new Error('Application ID is required');
    error.statusCode = 400;
    throw error;
  }

  const { data, error: searchError } = await supabase
    .from('hospitals')
    .select('verification_status')
    .eq('application_id', applicationId)
    .single();

  if (searchError) {
    const error = new Error('Hospital not found');
    error.statusCode = 404;
    throw error;
  }

  return { verification_status: data.verification_status };
};

module.exports = {
  registerHospital,
  loginHospital,
  checkHospitalStatus,
  generateApplicationId,
};
