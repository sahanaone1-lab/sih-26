/**
 * Validator for Hospital Registration requests
 */

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PIN_CODE_REGEX = /^[1-9][0-9]{5}$/; // 6-digit Indian Postal PIN Code
const PHONE_REGEX = /^[6-9]\d{9}$/; // Standard 10-digit Indian Mobile number (or +91 format stripped)

/**
 * Normalizes and strips country code from phone numbers for validation
 */
const normalizePhone = (phone) => {
  if (!phone) return '';
  return phone.replace(/[\s\-()+]/g, '').replace(/^91/, '');
};

const validateHospitalRegistration = (data) => {
  const errors = [];

  // 1. Required Facility Details
  if (!data.facility_name || typeof data.facility_name !== 'string' || data.facility_name.trim().length < 3) {
    errors.push('Facility name is required and must be at least 3 characters.');
  }

  if (!data.facility_type || typeof data.facility_type !== 'string' || data.facility_type.trim().length === 0) {
    errors.push('Facility type is required (e.g., Government AYUSH Institute, Private AYUSH Hospital).');
  }

  if (!data.state || typeof data.state !== 'string' || data.state.trim().length === 0) {
    errors.push('State is required.');
  }

  if (!data.district || typeof data.district !== 'string' || data.district.trim().length === 0) {
    errors.push('District is required.');
  }

  if (!data.address || typeof data.address !== 'string' || data.address.trim().length < 5) {
    errors.push('Detailed facility address is required.');
  }

  // PIN Code Validation (Optional format check if provided)
  if (data.pin_code && !PIN_CODE_REGEX.test(data.pin_code.toString().trim())) {
    errors.push('Invalid PIN code format. Must be a 6-digit Indian postal code.');
  }

  // Facility Official Email
  if (!data.official_email || !EMAIL_REGEX.test(data.official_email.trim())) {
    errors.push('A valid official facility email address is required.');
  }

  // Facility Official Phone
  const normalizedFacilityPhone = normalizePhone(data.official_phone);
  if (!data.official_phone || !PHONE_REGEX.test(normalizedFacilityPhone)) {
    errors.push('A valid 10-digit official phone number is required.');
  }

  // 2. Regulatory IDs
  if (!data.registration_number || typeof data.registration_number !== 'string' || data.registration_number.trim().length === 0) {
    errors.push('State / Central AYUSH Registration Number is required.');
  }

  // Note: hfr_id is explicitly OPTIONAL - no required check

  // 3. Authorized Official Details (Supports both flat and nested objects)
  const officialName = data.authorized_official?.full_name || data.authorized_person_name || data.official_full_name;
  const officialDesignation = data.authorized_official?.designation || data.authorized_person_designation || data.official_designation;
  const officialEmail = data.authorized_official?.official_email || data.authorized_person_email || data.official_contact_email;
  const officialPhone = data.authorized_official?.official_phone || data.authorized_person_phone || data.official_contact_phone;

  if (!officialName || typeof officialName !== 'string' || officialName.trim().length < 2) {
    errors.push('Authorized official full name is required.');
  }

  if (!officialDesignation || typeof officialDesignation !== 'string' || officialDesignation.trim().length === 0) {
    errors.push('Authorized official designation is required (e.g., Medical Superintendent, Nodal Officer).');
  }

  if (!officialEmail || !EMAIL_REGEX.test(officialEmail.trim())) {
    errors.push('A valid official email address for the authorized representative is required.');
  }

  const normalizedOfficialPhone = normalizePhone(officialPhone);
  if (!officialPhone || !PHONE_REGEX.test(normalizedOfficialPhone)) {
    errors.push('A valid 10-digit phone number for the authorized representative is required.');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

module.exports = {
  validateHospitalRegistration,
  normalizePhone,
};
