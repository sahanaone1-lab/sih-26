const { getSupabase } = require('../config/supabase');
const crypto = require('crypto');

const requestDoctorAccess = async (patientId, doctorId) => {
  const supabase = getSupabase();
  
  if (!patientId || !doctorId) {
    const error = new Error('Patient ID and Doctor ID are required');
    error.statusCode = 400;
    throw error;
  }

  // Generate a random access token for the 90-minute session
  const rawToken = crypto.randomBytes(32).toString('hex');
  const tokenHash = crypto.createHash('sha256').update(rawToken).digest('hex');

  const { data: session, error } = await supabase
    .from('doctor_access_sessions')
    .insert({
      patient_id: patientId,
      doctor_id: doctorId,
      access_token_hash: tokenHash,
      status: 'PENDING',
    })
    .select('*')
    .single();

  if (error) throw error;
  
  // Return the raw token only once to the client (to be turned into a QR code)
  return { session, rawToken };
};

const approveDoctorAccess = async (sessionId, patientId) => {
  const supabase = getSupabase();
  
  // Calculate expiry 90 minutes from now
  const expiresAt = new Date(Date.now() + 90 * 60 * 1000).toISOString();

  const { data: session, error } = await supabase
    .from('doctor_access_sessions')
    .update({
      status: 'ACTIVE',
      approved_at: new Date().toISOString(),
      expires_at: expiresAt,
    })
    .eq('id', sessionId)
    .eq('patient_id', patientId)
    .select('*')
    .single();

  if (error) throw error;
  return session;
};

const verifyDoctorAccess = async (doctorId, rawToken) => {
  const supabase = getSupabase();
  const tokenHash = crypto.createHash('sha256').update(rawToken).digest('hex');
  
  const { data: session, error } = await supabase
    .from('doctor_access_sessions')
    .select('*')
    .eq('doctor_id', doctorId)
    .eq('access_token_hash', tokenHash)
    .eq('status', 'ACTIVE')
    .single();

  if (error || !session) {
    const err = new Error('Invalid or expired access token');
    err.statusCode = 403;
    throw err;
  }
  
  // Check expiration manually as a fallback
  if (new Date(session.expires_at) < new Date()) {
    // Automatically revoke
    await supabase.from('doctor_access_sessions').update({ status: 'EXPIRED' }).eq('id', session.id);
    const err = new Error('Access token has expired (90 minutes limit)');
    err.statusCode = 403;
    throw err;
  }

  return session;
};

module.exports = {
  requestDoctorAccess,
  approveDoctorAccess,
  verifyDoctorAccess,
};
